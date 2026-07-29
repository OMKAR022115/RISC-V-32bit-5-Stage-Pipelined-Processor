`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:30:30 06/21/2026 
// Design Name: 
// Module Name:    wb_mux 
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
module wb_mux(

    input mem_to_reg,

    input [31:0] read_data,
    input [31:0] alu_result,

    output [31:0] wb_data

);

assign wb_data =
        (mem_to_reg) ?
        read_data :
        alu_result;

endmodule
