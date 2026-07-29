`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:25:53 06/21/2026 
// Design Name: 
// Module Name:    mem_wb 
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
module mem_wb(

    input clk,
    input rst,

    input reg_write_in,
    input mem_to_reg_in,

    input [31:0] read_data_in,
    input [31:0] alu_result_in,

    input [4:0] write_reg_in,

    output reg reg_write_out,
    output reg mem_to_reg_out,

    output reg [31:0] read_data_out,
    output reg [31:0] alu_result_out,

    output reg [4:0] write_reg_out

);

always @(posedge clk or posedge rst)
begin

    if(rst)
    begin
        reg_write_out <= 0;
        mem_to_reg_out <= 0;

        read_data_out <= 0;
        alu_result_out <= 0;

        write_reg_out <= 0;
    end
    else
    begin
        reg_write_out <= reg_write_in;
        mem_to_reg_out <= mem_to_reg_in;

        read_data_out <= read_data_in;
        alu_result_out <= alu_result_in;

        write_reg_out <= write_reg_in;
    end

end

endmodule
