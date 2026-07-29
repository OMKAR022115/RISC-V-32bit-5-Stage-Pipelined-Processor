`timescale 1ns / 1ps

module Ethernet_Controller (
    input  wire clk,
    input  wire reset,
    
    input  wire tx_request,
    input  wire rx_request,
    
    output reg  tx_start,
    output reg  rx_start,
    
    input  wire tx_done,
    input  wire rx_done,
    
    output reg  busy,
    output reg  tx_complete,
    output reg  rx_complete
);

    localparam [2:0] 
        ST_IDLE     = 3'd0,
        ST_TX_START = 3'd1,
        ST_TX_WAIT  = 3'd2,
        ST_RX_START = 3'd3,
        ST_RX_WAIT  = 3'd4,
        ST_DONE     = 3'd5;

    reg [2:0] state;
    reg       is_tx_op;
    reg       is_rx_op;

    always @(posedge clk) begin
        if (reset) begin
            state       <= ST_IDLE;
            is_tx_op    <= 1'b0;
            is_rx_op    <= 1'b0;
            
            tx_start    <= 1'b0;
            rx_start    <= 1'b0;
            busy        <= 1'b0;
            tx_complete <= 1'b0;
            rx_complete <= 1'b0;
        end else begin
            tx_start    <= 1'b0;
            rx_start    <= 1'b0;
            tx_complete <= 1'b0;
            rx_complete <= 1'b0;
            busy        <= 1'b1; 

            case (state)
                ST_IDLE: begin
                    busy     <= 1'b0;
                    is_tx_op <= 1'b0;
                    is_rx_op <= 1'b0;

                    if (tx_request) begin
                        state <= ST_TX_START;
                    end else if (rx_request) begin
                        state <= ST_RX_START;
                    end else begin
                        state <= ST_IDLE;
                    end
                end

                ST_TX_START: begin
                    tx_start <= 1'b1;
                    is_tx_op <= 1'b1;
                    is_rx_op <= 1'b0;
                    state    <= ST_TX_WAIT;
                end

                ST_TX_WAIT: begin
                    if (tx_done) begin
                        state <= ST_DONE;
                    end else begin
                        state <= ST_TX_WAIT;
                    end
                end

                ST_RX_START: begin
                    rx_start <= 1'b1;
                    is_rx_op <= 1'b1;
                    is_tx_op <= 1'b0;
                    state    <= ST_RX_WAIT;
                end

                ST_RX_WAIT: begin
                    if (rx_done) begin
                        state <= ST_DONE;
                    end else begin
                        state <= ST_RX_WAIT;
                    end
                end

                ST_DONE: begin
                    if (is_tx_op) begin
                        tx_complete <= 1'b1;
                        rx_complete <= 1'b0;
                    end else if (is_rx_op) begin
                        tx_complete <= 1'b0;
                        rx_complete <= 1'b1;
                    end else begin
                        tx_complete <= 1'b0;
                        rx_complete <= 1'b0;
                    end
                    state <= ST_IDLE;
                end

                default: begin
                    state <= ST_IDLE;
                end
            endcase
        end
    end

endmodule