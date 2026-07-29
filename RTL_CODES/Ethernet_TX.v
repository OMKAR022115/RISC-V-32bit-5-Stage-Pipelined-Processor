`timescale 1ns / 1ps
module Ethernet_TX(

    input wire clk,
    input wire reset,

    // Control
    input wire tx_start,
    // FIFO Interface
    input wire fifo_empty,
    input wire [7:0] fifo_data,
    output reg fifo_rd,
	  // CRC
    output reg crc_enable,
    // Output to PHY
    output reg [7:0] tx_data,
    output reg tx_valid,
    // Status
    output reg tx_done
);
// State Encoding
//----------------------------------------------------

parameter IDLE      = 3'd0;
parameter PREAMBLE  = 3'd1;
parameter SFD       = 3'd2;
parameter PAYLOAD   = 3'd3;
parameter CRC       = 3'd4;
parameter DONE      = 3'd5;

reg [2:0] state;
reg [2:0] preamble_count;
// State Machine
//----------------------------------------------------

always @(posedge clk)
begin

    if(reset)
    begin
        state <= IDLE;
        tx_data <= 8'd0;
        tx_valid <= 1'b0;
        tx_done <= 1'b0;
		  fifo_rd <= 1'b0;
        crc_enable <= 1'b0;

        preamble_count <= 3'd0;
    end
    else
    begin
        fifo_rd <= 0;
        crc_enable <= 0;
        tx_done <= 0;
        case(state)
 IDLE:
        begin
            tx_valid <= 0;
            if(tx_start)
            begin
                state <= PREAMBLE;
                preamble_count <= 0;
            end
        end
		  
		    PREAMBLE:
        begin
            tx_valid <= 1;
            tx_data <= 8'h55;
            if(preamble_count == 6)
                state <= SFD;
            else
                preamble_count <= preamble_count + 1;
        end
		  
		   SFD:
        begin
            tx_data <= 8'hD5;
            state <= PAYLOAD;
        end

        PAYLOAD:
        begin
            if(!fifo_empty)
            begin
                fifo_rd <= 1;
                tx_data <= fifo_data;
                crc_enable <= 1;
            end
            else
            begin
                state <= CRC;
           end
        end

        CRC:
        begin
            tx_valid <= 1;
            // CRC bytes will be connected later
            tx_data <= 8'h00;
            state <= DONE;
      		end
				
 DONE:
        begin
            tx_done <= 1;
            tx_valid <= 0;
            state <= IDLE;
        end
default:

            state <= IDLE;

        endcase

    end

end

endmodule
