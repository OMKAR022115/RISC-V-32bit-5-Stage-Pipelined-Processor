`timescale 1ns / 1ps
module Ethernet_RX(

    input wire clk,
    input wire reset,
    // PHY Interface
    input wire [7:0] rx_data,
    input wire rx_valid,
    // FIFO Interface
    output reg fifo_wr,
    output reg [7:0] fifo_data,
    // CRC Control
    output reg crc_enable,
    // Status
    output reg rx_done
);
// State Declaration
//------------------------------------------------------

parameter IDLE      = 3'd0;
parameter PREAMBLE  = 3'd1;
parameter SFD       = 3'd2;
parameter PAYLOAD   = 3'd3;
parameter CRC       = 3'd4;
parameter DONE      = 3'd5;

reg [2:0] state;
reg [2:0] preamble_count;
// State Machine
//------------------------------------------------------

always @(posedge clk)
begin
    if(reset)
    begin
        state <= IDLE;
        fifo_wr <= 0;
        fifo_data <= 8'd0;
        crc_enable <= 0;
        rx_done <= 0;
        preamble_count <= 0;
    end
	    else
    begin
        fifo_wr <= 0;
        crc_enable <= 0;
        rx_done <= 0;
        case(state)
        IDLE:
        begin
            if(rx_valid && rx_data==8'h55)
            begin
                state <= PREAMBLE;
                preamble_count <= 1;
            end
        end
		  
		  PREAMBLE:
        begin
            if(rx_valid)
            begin
                if(rx_data==8'h55)
                begin
                    if(preamble_count==7)
                        state <= SFD;
                    else
                        preamble_count <= preamble_count + 1; 
								 end
                else
                    state <= IDLE;
            end
        end
		  
        SFD:
        begin
            if(rx_valid)
            begin
                if(rx_data==8'hD5)
                    state <= PAYLOAD;
                else
                    state <= IDLE;
            end
        end
		  
  PAYLOAD:
        begin
            if(rx_valid)
            begin
                fifo_data <= rx_data;
                fifo_wr <= 1;
                crc_enable <= 1;
            end
            else
            begin
                state <= CRC;
            end
        end
		  
		   CRC:
        begin
            // CRC verification will be added later
            state <= DONE;
        end
		  
		   DONE:
        begin
            rx_done <= 1;
            state <= IDLE;
        end
		   default:
            state <= IDLE;
        endcase
    end
end
endmodule
