`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   10:37:33 06/22/2026
// Design Name:   cpu_debug
// Module Name:   /mnt/hgfs/Project/major_risc/Risc/debug_tb.v
// Project Name:  Risc
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: cpu_debug
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module debug_tb;

/////////////////////////////////////////////////
// Inputs
/////////////////////////////////////////////////

reg clk;
reg rst;

/////////////////////////////////////////////////
// Outputs from cpu_debug
/////////////////////////////////////////////////

wire [31:0] dbg_pc;
wire [31:0] dbg_instr;

wire [31:0] dbg_r1;
wire [31:0] dbg_r2;
wire [31:0] dbg_r3;
wire [31:0] dbg_r5;

wire dbg_branch_taken;
wire [31:0] dbg_branch_target;

wire [31:0] dbg_alu_result;
wire [31:0] dbg_wb_data;

/////////////////////////////////////////////////
// DUT
/////////////////////////////////////////////////

cpu_debug DUT(

    .clk(clk),
    .rst(rst),

    .dbg_pc(dbg_pc),
    .dbg_instr(dbg_instr),

    .dbg_r1(dbg_r1),
    .dbg_r2(dbg_r2),
    .dbg_r3(dbg_r3),
    .dbg_r5(dbg_r5),

    .dbg_branch_taken(dbg_branch_taken),
    .dbg_branch_target(dbg_branch_target),

    .dbg_alu_result(dbg_alu_result),
    .dbg_wb_data(dbg_wb_data)

);

/////////////////////////////////////////////////
// Clock
/////////////////////////////////////////////////

always #5 clk = ~clk;

/////////////////////////////////////////////////
// Reset
/////////////////////////////////////////////////

initial begin

    clk = 0;
    rst = 1;

    #20;
    rst = 0;

    #300;

    $display("\n--------------------------------");
    $display("FINAL RESULTS");
    $display("--------------------------------");

    $display("R1 = %d", dbg_r1);
    $display("R2 = %d", dbg_r2);
    $display("R3 = %d", dbg_r3);
    $display("R5 = %d", dbg_r5);

    $display("ALU RESULT    = %d", dbg_alu_result);
    $display("WB DATA       = %d", dbg_wb_data);

    $display("BRANCH TAKEN  = %b", dbg_branch_taken);
    $display("BRANCH TARGET = %h", dbg_branch_target);

    $finish;

end

/////////////////////////////////////////////////
// Compact Execution Trace
/////////////////////////////////////////////////

always @(posedge clk)
begin

    $display(
      "T=%0t PC=%h INSTR=%h R1=%d R2=%d R3=%d R5=%d",
      $time,
      dbg_pc,
      dbg_instr,
      dbg_r1,
      dbg_r2,
      dbg_r3,
      dbg_r5
    );

end

endmodule