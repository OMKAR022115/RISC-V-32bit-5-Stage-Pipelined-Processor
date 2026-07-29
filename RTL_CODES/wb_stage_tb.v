`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   17:31:59 06/21/2026
// Design Name:   wb_stage_top
// Module Name:   /mnt/hgfs/Project/major_risc/Risc/wb_stage_tb.v
// Project Name:  Risc
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: wb_stage_top
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module wb_stage_tb;

reg reg_write;
reg mem_to_reg;

reg [31:0] read_data;
reg [31:0] alu_result;

reg [4:0] write_reg;

wire wb_reg_write;
wire [31:0] wb_data;
wire [4:0] wb_write_reg;

/////////////////////////////////////////////////
// DUT
/////////////////////////////////////////////////

wb_stage_top DUT(

    .reg_write(reg_write),
    .mem_to_reg(mem_to_reg),

    .read_data(read_data),
    .alu_result(alu_result),

    .write_reg(write_reg),

    .wb_reg_write(wb_reg_write),
    .wb_data(wb_data),
    .wb_write_reg(wb_write_reg)

);

/////////////////////////////////////////////////
// Stimulus
/////////////////////////////////////////////////

initial begin

    //////////////////////////////////////////////////
    // ALU Write Back
    //////////////////////////////////////////////////

    reg_write = 1;
    mem_to_reg = 0;

    alu_result = 32'd30;
    read_data  = 32'd1234;

    write_reg = 5'd3;

    #20;

    //////////////////////////////////////////////////
    // Memory Write Back
    //////////////////////////////////////////////////

    mem_to_reg = 1;

    read_data = 32'd1234;

    write_reg = 5'd7;

    #20;

    $finish;

end

/////////////////////////////////////////////////
// Monitor
/////////////////////////////////////////////////

initial begin

    $monitor(
    "T=%0t WB_DATA=%d WR_REG=%d REGWRITE=%b",
    $time,
    wb_data,
    wb_write_reg,
    wb_reg_write
    );

end

endmodule
