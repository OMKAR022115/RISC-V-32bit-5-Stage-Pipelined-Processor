`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:25:25 06/21/2026 
// Design Name: 
// Module Name:    data_memory 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module data_memory(
    input clk,
    input mem_read,
    input mem_write,
    input [7:0] address, // Changed to 8-bit
    input [31:0] write_data,
    output reg [31:0] read_data
	 
);

    reg [31:0] memory [0:255];
    integer i;

    initial begin
        for(i=0; i<256; i=i+1)
            memory[i] = 32'd0;
        memory[0] = 32'd10;
    end

    always @(posedge clk) begin
        if(mem_write)
           memory[address] <= write_data; // Uses exact 8-bit address
    end

    always @(*) begin
        if(mem_read)
            read_data = memory[address];
        else
            read_data = 32'd0;
    end

endmodule