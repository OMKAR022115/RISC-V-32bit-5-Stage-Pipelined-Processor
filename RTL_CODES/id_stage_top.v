`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:05:53 06/21/2026 
// Design Name: 
// Module Name:    id_stage_top 
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
module id_stage_top(

    input clk,
    input rst,

    input [31:0] instruction,
 input [31:2] pc_in, // Changed from [31:0]

    // From WB Stage
    input wb_reg_write,
    input [4:0] wb_write_reg,
    input [31:0] wb_write_data,
    input branch_flush,
    // Outputs to EX Stage
    output [31:0] ex_pc,
    output [31:0] ex_rd1,
    output [31:0] ex_rd2,
    output [31:0] ex_imm,

    output [4:0] ex_rs,
    output [4:0] ex_rt,
    output [4:0] ex_rd,

    output [5:0] ex_funct,

    output ex_reg_dst,
    output ex_alu_src,
    output [1:0] ex_alu_op,

    output ex_mem_read,
    output ex_mem_write,
    output ex_branch,

    output ex_reg_write,
    output ex_mem_to_reg,
	 output pc_write,
output ifid_write

);

//==================================================
// Instruction Fields
//==================================================

wire [5:0] opcode;
wire [4:0] rs;
wire [4:0] rt;
wire [4:0] rd;
wire [15:0] imm;
wire [5:0] funct;

/////////////////////////////////////////////////
// Hazard Signals
/////////////////////////////////////////////////


wire control_flush;

assign opcode = instruction[31:26];
assign rs     = instruction[25:21];
assign rt     = instruction[20:16];
assign rd     = instruction[15:11];
assign imm    = instruction[15:0];
assign funct  = instruction[5:0];

//==================================================
// Control Signals
//==================================================

wire reg_dst;
wire alu_src;
wire mem_to_reg;
wire reg_write;
wire mem_read;
wire mem_write;
wire branch;
wire [1:0] alu_op;

//==================================================
// Register File Outputs
//==================================================

wire [31:0] rd1;
wire [31:0] rd2;

//==================================================
// Sign Extension
//==================================================

wire [31:0] imm_ext;

//==================================================
// Register File
//==================================================

register_file RF(

    .clk(clk),
    .reg_write(wb_reg_write),

    .rs(rs),
    .rt(rt),
    .rd(wb_write_reg),

    .write_data(wb_write_data),

    .read_data1(rd1),
    .read_data2(rd2)

);

//==================================================
// Control Unit
//==================================================

control_unit CU(

    .opcode(opcode),

    .reg_dst(reg_dst),
    .alu_src(alu_src),
    .mem_to_reg(mem_to_reg),
    .reg_write(reg_write),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .branch(branch),
    .alu_op(alu_op)

);

//==================================================
// Sign Extend
//==================================================

sign_extend SE(

    .imm(imm),
    .imm_ext(imm_ext)

);

//==================================================
// ID/EX Internal Wires
//==================================================

wire reg_dst_out;
wire alu_src_out;
wire [1:0] alu_op_out;

wire mem_read_out;
wire mem_write_out;
wire branch_out;

wire reg_write_out;
wire mem_to_reg_out;

wire [31:0] pc_out;
wire [31:0] rd1_out;
wire [31:0] rd2_out;
wire [31:0] imm_out;

wire [4:0] rs_out;
wire [4:0] rt_out;
wire [4:0] rd_out;

wire [5:0] funct_out;

//==================================================
// ID/EX Pipeline Register
//==================================================

id_ex ID_EX(

    .clk(clk),
    .rst(rst),

    // EX Controls
.reg_dst_in(
    (control_flush || branch_flush)
    ? 1'b0
    : reg_dst
),
.alu_src_in(
    (control_flush || branch_flush)
    ? 1'b0
    : alu_src
),

.alu_op_in(
    (control_flush || branch_flush)
    ? 2'b00
    : alu_op
),

.mem_read_in(
    (control_flush || branch_flush)
    ? 1'b0
    : mem_read
),

.mem_write_in(
    (control_flush || branch_flush)
    ? 1'b0
    : mem_write
),

.branch_in(
    (control_flush || branch_flush)
    ? 1'b0
    : branch
),

.reg_write_in(
    (control_flush || branch_flush)
    ? 1'b0
    : reg_write
),

.mem_to_reg_in(
    (control_flush || branch_flush)
    ? 1'b0
    : mem_to_reg
),
    // Datapath
    .pc_in(pc_in),

    .rd1_in(rd1),
    .rd2_in(rd2),

    .imm_in(imm_ext),

    .rs_in(rs),
    .rt_in(rt),
    .rd_in(rd),

    .funct_in(funct),

    .reg_dst_out(reg_dst_out),
    .alu_src_out(alu_src_out),
    .alu_op_out(alu_op_out),

    .mem_read_out(mem_read_out),
    .mem_write_out(mem_write_out),
    .branch_out(branch_out),

    .reg_write_out(reg_write_out),
    .mem_to_reg_out(mem_to_reg_out),

    .pc_out(pc_out),

    .rd1_out(rd1_out),
    .rd2_out(rd2_out),

    .imm_out(imm_out),

    .rs_out(rs_out),
    .rt_out(rt_out),
    .rd_out(rd_out),

    .funct_out(funct_out)

);

////////////////////
///HAZARD UNIT
//////////////////
hazard_detection_unit HDU(

    .idex_mem_read(mem_read_out),
    .idex_rt(rt_out),

    .ifid_rs(rs),
    .ifid_rt(rt),

    .pc_write(pc_write),
    .ifid_write(ifid_write),

    .control_flush(control_flush)

);
//==================================================
// Outputs To EX Stage
//==================================================

assign ex_pc         = pc_out;

assign ex_rd1        = rd1_out;
assign ex_rd2        = rd2_out;
assign ex_imm        = imm_out;

assign ex_rs         = rs_out;
assign ex_rt         = rt_out;
assign ex_rd         = rd_out;

assign ex_funct      = funct_out;

assign ex_reg_dst    = reg_dst_out;
assign ex_alu_src    = alu_src_out;
assign ex_alu_op     = alu_op_out;

assign ex_mem_read   = mem_read_out;
assign ex_mem_write  = mem_write_out;
assign ex_branch     = branch_out;

assign ex_reg_write  = reg_write_out;
assign ex_mem_to_reg = mem_to_reg_out;

endmodule

