`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:02:59 06/21/2026 
// Design Name: 
// Module Name:    register_file 
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
module register_file(

    input clk,
    input reg_write,

    input [4:0] rs,
    input [4:0] rt,
    input [4:0] rd,

    input [31:0] write_data,

    output [31:0] read_data1,
    output [31:0] read_data2

);

reg [31:0] regs [0:31];

integer i;

initial begin
    for(i=0;i<32;i=i+1)
        regs[i] = 32'd0;
end

assign read_data1 = regs[rs];
assign read_data2 = regs[rt];

always @(posedge clk)
begin
    if(reg_write && (rd != 5'd0))
        regs[rd] <= write_data;
end

endmodule