`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:29:37 06/21/2026 
// Design Name: 
// Module Name:    if_id 
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

module if_id(
    input clk,
    input rst,
    input flush,
    input ifid_write,

    input  [31:2] pc_in, // Changed to 30-bit input
    input  [31:0] instr_in,

    output [31:0] pc_out,
    output reg [31:0] instr_out
);
    reg [31:2] pc_reg;
    
    assign pc_out = {pc_reg, 2'b00};

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            pc_reg    <= 30'd0;
            instr_out <= 32'd0;
        end
        else if(flush) begin
            pc_reg    <= 30'd0;
            instr_out <= 32'd0;
        end
        else if(ifid_write) begin
            pc_reg    <= pc_in;
            instr_out <= instr_in;
        end
    end
endmodule