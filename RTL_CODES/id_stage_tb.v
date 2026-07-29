`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   17:09:40 06/21/2026
// Design Name:   id_stage_top
// Module Name:   /mnt/hgfs/Project/major_risc/Risc/id_stage_tb.v
// Project Name:  Risc
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: id_stage_top
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module id_stage_tb;
    // Inputs
    reg clk;
    reg rst;
    reg [31:0] instruction;
    reg [31:2] pc_in; // Changed to 30-bit input

    // Outputs from ID stage
    wire [31:0] ex_pc;
    wire [31:0] ex_rd1;
    wire [31:0] ex_rd2;
    wire [31:0] ex_imm;
    wire [4:0] ex_rs;
    wire [4:0] ex_rt;
    wire [4:0] ex_rd;
    wire [5:0] ex_funct;
    wire ex_reg_dst;
    wire ex_alu_src;
    wire [1:0] ex_alu_op;
    wire ex_mem_read;
    wire ex_mem_write;
    wire ex_branch;
    wire ex_reg_write;
    wire ex_mem_to_reg;
    wire pc_write;
    wire ifid_write;

    //////////////////////////////////////////////////
    // DUT
    //////////////////////////////////////////////////
    id_stage_top DUT(
        .clk(clk),
        .rst(rst),
        .instruction(instruction),
        .pc_in(pc_in),
        .wb_reg_write(1'b0),
        .wb_write_reg(5'd0),
        .wb_write_data(32'd0),
        .branch_flush(1'b0),
        
        .ex_pc(ex_pc),
        .ex_rd1(ex_rd1),
        .ex_rd2(ex_rd2),
        .ex_imm(ex_imm),
        .ex_rs(ex_rs),
        .ex_rt(ex_rt),
        .ex_rd(ex_rd),
        .ex_funct(ex_funct),
        .ex_reg_dst(ex_reg_dst),
        .ex_alu_src(ex_alu_src),
        .ex_alu_op(ex_alu_op),
        .ex_mem_read(ex_mem_read),
        .ex_mem_write(ex_mem_write),
        .ex_branch(ex_branch),
        .ex_reg_write(ex_reg_write),
        .ex_mem_to_reg(ex_mem_to_reg),
        .pc_write(pc_write),
        .ifid_write(ifid_write)
    );

    //////////////////////////////////////////////////
    // Clock
    //////////////////////////////////////////////////
    always #5 clk = ~clk;

    //////////////////////////////////////////////////
    // Stimulus
    //////////////////////////////////////////////////
    initial begin
        clk = 0;
        rst = 1;
        instruction = 32'd0;
        pc_in = 30'd1; // Equivalent to PC=4 (4 >> 2)

        #20;
        rst = 0;

        // ADDI R1,R0,5
        instruction = 32'h20010005;
        #20;

        // LW R2,4(R1)
        instruction = 32'h8C220004;
        #20;

        // SW R2,8(R1)
        instruction = 32'hAC220008;
        #20;

        // BEQ R1,R2,1
        instruction = 32'h10220001;
        #20;

        $finish;
    end

    //////////////////////////////////////////////////
    // Monitor
    //////////////////////////////////////////////////
    initial begin
        $monitor(
        "TIME=%0t | PC=%h | IMM=%h | RS=%d RT=%d RD=%d | ALUSRC=%b REGWRITE=%b",
        $time, ex_pc, ex_imm, ex_rs, ex_rt, ex_rd, ex_alu_src, ex_reg_write
        );
    end
endmodule