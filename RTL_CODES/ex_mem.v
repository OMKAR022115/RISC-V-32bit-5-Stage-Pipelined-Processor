`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:14:41 06/21/2026 
// Design Name: 
// Module Name:    ex_mem 
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

module ex_mem(
    input clk,
    input rst,

    // MEM control
    input mem_read_in,
    input mem_write_in,

    // WB control
    input reg_write_in,
    input mem_to_reg_in,

    // Datapath
    input [31:0] alu_result_in,
    input [31:0] write_data_in,
    input [4:0] write_reg_in,

    // Outputs
    output reg mem_read_out,
    output reg mem_write_out,

    output reg reg_write_out,
    output reg mem_to_reg_out,

    output reg [31:0] alu_result_out,
    output reg [31:0] write_data_out,
    output reg [4:0] write_reg_out
);

always @(posedge clk or posedge rst) begin
    if(rst) begin
        mem_read_out   <= 0;
        mem_write_out  <= 0;
        reg_write_out  <= 0;
        mem_to_reg_out <= 0;
        alu_result_out <= 0;
        write_data_out <= 0;
        write_reg_out  <= 0;
    end else begin
        mem_read_out   <= mem_read_in;
        mem_write_out  <= mem_write_in;
        reg_write_out  <= reg_write_in;
        mem_to_reg_out <= mem_to_reg_in;
        alu_result_out <= alu_result_in;
        write_data_out <= write_data_in;
        write_reg_out  <= write_reg_in;
    end
end

endmodule
