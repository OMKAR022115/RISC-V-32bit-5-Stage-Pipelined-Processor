`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   17:27:51 06/21/2026
// Design Name:   mem_stage_top
// Module Name:   /mnt/hgfs/Project/major_risc/Risc/mem_stage_tb.v
// Project Name:  Risc
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: mem_stage_top
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module mem_stage_tb;
    // Inputs
    reg clk;
    reg rst;
    reg mem_read;
    reg mem_write;
    reg reg_write;
    reg mem_to_reg;
    reg [31:0] alu_result;
    reg [31:0] write_data;
    reg [4:0] write_reg;

    // Outputs
    wire wb_reg_write;
    wire wb_mem_to_reg;
    wire [31:0] wb_read_data;
    wire [31:0] wb_alu_result;
    wire [4:0] wb_write_reg;

    //////////////////////////////////////////////////
    // DUT
    //////////////////////////////////////////////////
    mem_stage_top DUT(
        .clk(clk),
        .rst(rst),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .reg_write(reg_write),
        .mem_to_reg(mem_to_reg),
        .alu_result(alu_result),
        .write_data(write_data),
        .write_reg(write_reg),
        .wb_reg_write(wb_reg_write),
        .wb_mem_to_reg(wb_mem_to_reg),
        .wb_read_data(wb_read_data),
        .wb_alu_result(wb_alu_result),
        .wb_write_reg(wb_write_reg)
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
        mem_read = 0; mem_write = 0;
        reg_write = 0; mem_to_reg = 0;
        alu_result = 0; write_data = 0; write_reg = 0;

        #20;
        rst = 0;

        // TEST 1 : STORE
        alu_result = 32'd16; // Address
        write_data = 32'd1234;
        mem_write = 1;
        #20;
        mem_write = 0;

        // TEST 2 : LOAD
        alu_result = 32'd16;
        mem_read = 1;
        reg_write = 1;
        mem_to_reg = 1;
        write_reg = 5'd7;
        #20;

        $finish;
    end

    //////////////////////////////////////////////////
    // Monitor
    //////////////////////////////////////////////////
    initial begin
        $monitor(
        "T=%0t READ_DATA=%d ALU=%d WR_REG=%d",
        $time, wb_read_data, wb_alu_result, wb_write_reg
        );
    end
endmodule