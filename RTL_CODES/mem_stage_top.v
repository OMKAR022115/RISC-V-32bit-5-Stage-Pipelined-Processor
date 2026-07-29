`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:26:20 06/21/2026 
// Design Name: 
// Module Name:    mem_stage_top 
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
//////////////////////////////////////////////////////////////////////////////////
// Memory Stage Top
// Modified for Simple SoC Interface
//////////////////////////////////////////////////////////////////////////////////

module mem_stage_top(

    input clk,
    input rst,

    //----------------------------------------------------------------------
    // From EX/MEM Pipeline Register
    //----------------------------------------------------------------------
    input        mem_read,
    input        mem_write,
    input        reg_write,
    input        mem_to_reg,

    input [31:0] alu_result,
    input [31:0] write_data,
    input [4:0]  write_reg,

    //----------------------------------------------------------------------
    // External SoC Memory Interface
    //----------------------------------------------------------------------
    output [31:0] mem_addr,
    output [31:0] mem_wdata,
    input  [31:0] mem_rdata,

    //----------------------------------------------------------------------
    // Outputs to WB Stage
    //----------------------------------------------------------------------
    output        wb_reg_write,
    output        wb_mem_to_reg,
    output [31:0] wb_read_data,
    output [31:0] wb_alu_result,
    output [4:0]  wb_write_reg

);

    //----------------------------------------------------------------------
    // Export CPU Memory Interface
    //----------------------------------------------------------------------
    assign mem_addr  = alu_result;
    assign mem_wdata = write_data;

    //----------------------------------------------------------------------
    // MEM/WB Pipeline Register
    //----------------------------------------------------------------------
    mem_wb MEM_WB(

        .clk(clk),
        .rst(rst),

        .reg_write_in(reg_write),
        .mem_to_reg_in(mem_to_reg),

        // Data comes from external SoC memory
        .read_data_in(mem_rdata),

        .alu_result_in(alu_result),

        .write_reg_in(write_reg),

        .reg_write_out(wb_reg_write),
        .mem_to_reg_out(wb_mem_to_reg),

        .read_data_out(wb_read_data),
        .alu_result_out(wb_alu_result),

        .write_reg_out(wb_write_reg)

    );

endmodule