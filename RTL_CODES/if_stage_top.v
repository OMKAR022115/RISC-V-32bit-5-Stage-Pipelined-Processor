`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:30:14 06/21/2026 
// Design Name: 
// Module Name:    if_stage_top 
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

module if_stage_top(
    input clk,
    input rst,
    output [31:0] pc_out,
    output [31:0] instruction_out
);

    wire [31:0] pc_current;
    wire [31:0] pc_plus4;
    wire [31:0] instruction;

    wire [31:0] ifid_pc;
    wire [31:0] ifid_instr;

    /////////////////////////////////////////////////
    // PC
    /////////////////////////////////////////////////
    pc PC(
        .clk(clk),
        .rst(rst),
        .pc_write(1'b1),
        .next_pc(pc_plus4[31:2]), // Sliced for 30-bit input
        .pc(pc_current)
    );

    /////////////////////////////////////////////////
    // Instruction Memory
    /////////////////////////////////////////////////
    instruction_memory IM(
        .addr(pc_current[9:2]), // Sliced for 8-bit input
        .instruction(instruction)
    );

    /////////////////////////////////////////////////
    // PC + 4
    /////////////////////////////////////////////////
    assign pc_plus4 = pc_current + 32'd4;

    /////////////////////////////////////////////////
    // IF/ID Register
    /////////////////////////////////////////////////
    if_id IF_ID(
        .clk(clk),
        .rst(rst),
        .flush(1'b0),
        .ifid_write(1'b1),
        .pc_in(pc_plus4[31:2]), // Sliced for 30-bit input
        .instr_in(instruction),
        .pc_out(ifid_pc),
        .instr_out(ifid_instr)
    );

    assign pc_out = ifid_pc;
    assign instruction_out = ifid_instr;

endmodule