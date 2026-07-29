`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:15:15 06/21/2026 
// Design Name: 
// Module Name:    ex_stage_top 
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

module ex_stage_top(
    input clk,
    input rst,

    // From ID/EX
    input [31:0] pc_in,
    input [31:0] rd1_in,
    input [31:0] rd2_in,
    input [31:0] imm_in,
    input [4:0] rt_in,
    input [4:0] rd_in,
    input [4:0] rs_in,

    // Controls
    input reg_dst,
    input alu_src,
    input [1:0] alu_op,
    input mem_read,
    input mem_write,
    input branch,
    input reg_write,
    input mem_to_reg,
    input [5:0] funct,

    // Forwarding Inputs
    input exmem_reg_write,
    input [4:0] exmem_write_reg,
    input [31:0] exmem_alu_result,
    input memwb_reg_write,
    input [4:0] memwb_write_reg,
    input [31:0] memwb_write_data,

    // Outputs to MEM stage
    output [31:0] mem_alu_result,
    output [31:0] mem_write_data,
    output [4:0] mem_write_reg,

    output mem_read_out,
    output mem_write_out,
    output reg_write_out,
    output mem_to_reg_out,

    // Branch Resolution
    output branch_taken,
    output [31:0] branch_target
);

wire [3:0] alu_ctrl;
wire [31:0] alu_a;
wire [31:0] alu_b_pre;
wire [31:0] alu_b;
wire [1:0] forward_a;
wire [1:0] forward_b;
wire [31:0] alu_result_wire;
wire [31:0] branch_addr_wire;
wire zero_wire;
wire [4:0] write_reg_wire;

assign branch_target = branch_addr_wire;
assign branch_taken  = branch & zero_wire;

alu_control ALU_CONTROL(.alu_op(alu_op), .funct(funct), .alu_ctrl(alu_ctrl));

forwarding_unit FU(
    .exmem_reg_write(exmem_reg_write),
    .exmem_rd(exmem_write_reg),
    .memwb_reg_write(memwb_reg_write),
    .memwb_rd(memwb_write_reg),
    .idex_rs(rs_in),
    .idex_rt(rt_in),
    .forward_a(forward_a),
    .forward_b(forward_b)
);

assign alu_a = (forward_a == 2'b00) ? rd1_in :
               (forward_a == 2'b10) ? exmem_alu_result :
               (forward_a == 2'b01) ? memwb_write_data : rd1_in;

assign alu_b_pre = (forward_b == 2'b00) ? rd2_in :
                   (forward_b == 2'b10) ? exmem_alu_result :
                   (forward_b == 2'b01) ? memwb_write_data : rd2_in;

assign alu_b = (alu_src) ? imm_in : alu_b_pre;

alu ALU(
    .a(alu_a),
    .b(alu_b),
    .alu_ctrl(alu_ctrl),
    .result(alu_result_wire),
    .zero(zero_wire)
);

assign write_reg_wire = (reg_dst) ? rd_in : rt_in;
assign branch_addr_wire = pc_in + (imm_in << 2);

ex_mem EX_MEM(
    .clk(clk),
    .rst(rst),
    .mem_read_in(mem_read),
    .mem_write_in(mem_write),
    .reg_write_in(reg_write),
    .mem_to_reg_in(mem_to_reg),
    .alu_result_in(alu_result_wire),
    .write_data_in(alu_b_pre),
    .write_reg_in(write_reg_wire),
    
    .mem_read_out(mem_read_out),
    .mem_write_out(mem_write_out),
    .reg_write_out(reg_write_out),
    .mem_to_reg_out(mem_to_reg_out),
    .alu_result_out(mem_alu_result),
    .write_data_out(mem_write_data),
    .write_reg_out(mem_write_reg)
);

endmodule

