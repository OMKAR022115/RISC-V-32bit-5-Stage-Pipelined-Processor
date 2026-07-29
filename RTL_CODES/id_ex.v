`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:05:23 06/21/2026 
// Design Name: 
// Module Name:    id_ex 
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

`timescale 1ns / 1ps

module id_ex(
    input clk, rst,
    // EX Controls
    input reg_dst_in, alu_src_in,
    input [1:0] alu_op_in,
    // MEM Controls
    input mem_read_in, mem_write_in, branch_in,
    // WB Controls
    input reg_write_in, mem_to_reg_in,

    // Datapath
    input [31:2] pc_in, // Changed to 30-bit input
    input [31:0] rd1_in, rd2_in, imm_in,
    input [4:0] rs_in, rt_in, rd_in,
    input [5:0] funct_in,

    output reg reg_dst_out, alu_src_out,
    output reg [1:0] alu_op_out,
    output reg mem_read_out, mem_write_out, branch_out,
    output reg reg_write_out, mem_to_reg_out,

    output [31:0] pc_out,
    output reg [31:0] rd1_out, rd2_out, imm_out,
    output reg [4:0] rs_out, rt_out, rd_out,
    output reg [5:0] funct_out
);
    reg [31:2] pc_reg;
    assign pc_out = {pc_reg, 2'b00};

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            reg_dst_out <= 0; alu_src_out <= 0; alu_op_out <= 0;
            mem_read_out <= 0; mem_write_out <= 0; branch_out <= 0;
            reg_write_out <= 0; mem_to_reg_out <= 0;
            
            pc_reg <= 30'd0; rd1_out <= 0; rd2_out <= 0; imm_out <= 0;
            rs_out <= 0; rt_out <= 0; rd_out <= 0; funct_out <= 0;
        end else begin
            reg_dst_out <= reg_dst_in; alu_src_out <= alu_src_in; alu_op_out <= alu_op_in;
            mem_read_out <= mem_read_in; mem_write_out <= mem_write_in; branch_out <= branch_in;
            reg_write_out <= reg_write_in; mem_to_reg_out <= mem_to_reg_in;
            
            pc_reg <= pc_in; 
            rd1_out <= rd1_in; rd2_out <= rd2_in; imm_out <= imm_in;
            rs_out <= rs_in; rt_out <= rt_in; rd_out <= rd_in; funct_out <= funct_in;
        end
    end
endmodule