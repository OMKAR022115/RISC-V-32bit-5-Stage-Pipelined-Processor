`timescale 1ns / 1ps

module Ethernet_FIFO_TX #
(
    parameter DATA_WIDTH = 8,
    parameter FIFO_DEPTH = 16,
    parameter ADDR_WIDTH = 4
)
(
    input wire clk,
    input wire reset,

    // Write Interface
    input wire wr_en,
    input wire [DATA_WIDTH-1:0] data_in,
 // Read Interface
    input wire rd_en,
    output reg [DATA_WIDTH-1:0] data_out,

    // Status
    output wire full,
    output wire empty,
    output reg [ADDR_WIDTH:0] fifo_count
);

    // FIFO Memory
    reg [DATA_WIDTH-1:0] fifo_mem [0:FIFO_DEPTH-1];

    // Read & Write Pointers
    reg [ADDR_WIDTH-1:0] wr_ptr;
    reg [ADDR_WIDTH-1:0] rd_ptr;
	   //-------------------------------------------------
    // Full and Empty Logic
    //-------------------------------------------------

    assign full  = (fifo_count == FIFO_DEPTH);
    assign empty = (fifo_count == 0);

    //-------------------------------------------------
    // FIFO Operation
    //-------------------------------------------------
always @(posedge clk)
    begin
        if(reset)
        begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            fifo_count <= 0;
            data_out <= 0;
        end
        else
        begin
		   // Write Operation
            //----------------------------

            if(wr_en && !full)
            begin
                fifo_mem[wr_ptr] <= data_in;
                wr_ptr <= wr_ptr + 4'd1;
                fifo_count <= fifo_count + 1;
            end
// Read Operation
            //----------------------------

            if(rd_en && !empty)
            begin
                data_out <= fifo_mem[rd_ptr];
                rd_ptr <= rd_ptr + 1;
                fifo_count <= fifo_count - 1;
            end

        end
    end

endmodule
