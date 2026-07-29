`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   17:17:09 06/21/2026
// Design Name:   ex_stage_top
// Module Name:   /mnt/hgfs/Project/major_risc/Risc/ex_stage_tb.v
// Project Name:  Risc
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: ex_stage_top
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module ex_stage_tb;
    // Inputs
    reg clk;
    reg rst;
    reg [31:0] pc_in;
    reg [31:0] rd1_in;
    reg [31:0] rd2_in;
    reg [31:0] imm_in;
    reg [4:0] rt_in;
    reg [4:0] rd_in;
    reg reg_dst;
    reg alu_src;
    reg [1:0] alu_op;
    reg mem_read;
    reg mem_write;
    reg branch;
    reg reg_write;
    reg mem_to_reg;
    reg [5:0] funct;
    reg [4:0] rs_in; // Added rs_in for forwarding

    // Outputs
    wire [31:0] mem_alu_result;
    wire [31:0] mem_write_data;
    wire [4:0] mem_write_reg;
    wire mem_read_out;
    wire mem_write_out;
    wire reg_write_out;
    wire mem_to_reg_out;
    wire branch_taken;
    wire [31:0] branch_target;

    /////////////////////////////////////////////////
    // DUT
    /////////////////////////////////////////////////
    ex_stage_top DUT(
        .clk(clk),
        .rst(rst),
        .pc_in(pc_in),
        .rd1_in(rd1_in),
        .rd2_in(rd2_in),
        .imm_in(imm_in),
        .rt_in(rt_in),
        .rd_in(rd_in),
        .rs_in(rs_in), 
        .reg_dst(reg_dst),
        .alu_src(alu_src),
        .alu_op(alu_op),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .branch(branch),
        .reg_write(reg_write),
        .mem_to_reg(mem_to_reg),
        .funct(funct),
        
        // Dummy values for forwarding in TB
        .exmem_reg_write(1'b0),
        .exmem_write_reg(5'd0),
        .exmem_alu_result(32'd0),
        .memwb_reg_write(1'b0),
        .memwb_write_reg(5'd0),
        .memwb_write_data(32'd0),

        .mem_alu_result(mem_alu_result),
        .mem_write_data(mem_write_data),
        .mem_write_reg(mem_write_reg),
        .mem_read_out(mem_read_out),
        .mem_write_out(mem_write_out),
        .reg_write_out(reg_write_out),
        .mem_to_reg_out(mem_to_reg_out),
        .branch_taken(branch_taken),
        .branch_target(branch_target)
    );

    /////////////////////////////////////////////////
    // Clock
    /////////////////////////////////////////////////
    always #5 clk = ~clk;

    /////////////////////////////////////////////////
    // Stimulus
    /////////////////////////////////////////////////
    initial begin
        clk = 0;
        rst = 1;
        pc_in = 32'd0; rd1_in = 32'd0; rd2_in = 32'd0; imm_in = 32'd0;
        rs_in = 0; rt_in = 0; rd_in = 0;
        reg_dst = 0; alu_src = 0; alu_op = 0;
        mem_read = 0; mem_write = 0; branch = 0;
        reg_write = 0; mem_to_reg = 0; funct = 0;

        #20;
        rst = 0;

        // ADD: R3 = R1 + R2
        rd1_in = 32'd10; rd2_in = 32'd20; rd_in  = 5'd3;
        reg_dst = 1; alu_src = 0; alu_op = 2'b10; funct  = 6'b100000; reg_write = 1;
        #20;

        // SUB
        rd1_in = 32'd50; rd2_in = 32'd20; rd_in  = 5'd4;
        reg_dst = 1; alu_src = 0; alu_op = 2'b10; funct  = 6'b100010;
        #20;

        // ADDI
        rd1_in = 32'd25; imm_in = 32'd5; rt_in = 5'd5;
        reg_dst = 0; alu_src = 1; alu_op = 2'b00;
        #20;

        // BEQ (Branch Taken test)
        mem_read = 0; mem_write = 0; reg_write = 0; mem_to_reg = 0;
        pc_in = 32'd100; rd1_in = 32'd25; rd2_in = 32'd25; imm_in = 32'd4;
        alu_src = 0; branch = 1; alu_op = 2'b01;
        #20;

        $finish;
    end

    /////////////////////////////////////////////////
    // Monitor
    /////////////////////////////////////////////////
    initial begin
        $monitor(
        "T=%0t ALU=%d BR_TAKEN=%b BR_TARGET=%d WR_REG=%d MEM_RD=%b",
        $time, mem_alu_result, branch_taken, branch_target, mem_write_reg, mem_read_out
        );
    end
endmodule