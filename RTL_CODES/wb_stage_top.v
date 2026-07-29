`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:31:08 06/21/2026 
// Design Name: 
// Module Name:    wb_stage_top 
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
module wb_stage_top(

    input reg_write,
    input mem_to_reg,

    input [31:0] read_data,
    input [31:0] alu_result,

    input [4:0] write_reg,

    output wb_reg_write,

    output [31:0] wb_data,

    output [4:0] wb_write_reg

);

/////////////////////////////////////////////////
// Write Back MUX
/////////////////////////////////////////////////

wb_mux WB_MUX(

    .mem_to_reg(mem_to_reg),

    .read_data(read_data),
    .alu_result(alu_result),

    .wb_data(wb_data)

);

assign wb_reg_write = reg_write;

assign wb_write_reg = write_reg;

endmodule