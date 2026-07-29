`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   16:31:01 06/21/2026
// Design Name:   if_stage_top
// Module Name:   /mnt/hgfs/Project/major_risc/Risc/if_stage_tb.v
// Project Name:  Risc
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: if_stage_top
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module if_stage_tb;

    // Inputs
    reg clk;
    reg rst;

    // Outputs
    wire [31:0] pc_out;
    wire [31:0] instruction_out;

    // DUT
    if_stage_top uut (
        .clk(clk),
        .rst(rst),
        .pc_out(pc_out),
        .instruction_out(instruction_out)
    );

    //////////////////////////////////////////////////
    // Clock Generation (10 ns period)
    //////////////////////////////////////////////////
    always #5 clk = ~clk;

    //////////////////////////////////////////////////
    // Stimulus
    //////////////////////////////////////////////////
    initial begin

        clk = 0;
        rst = 1;

        // Hold reset
        #20;

        rst = 0;

        // Run for several cycles
        #100;

        $finish;

    end

    //////////////////////////////////////////////////
    // Monitor
    //////////////////////////////////////////////////
    initial begin
        $monitor("Time=%0t  PC=%h  INSTR=%h",
                 $time,
                 pc_out,
                 instruction_out);
    end

endmodule