`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:04:03 06/21/2026 
// Design Name: 
// Module Name:    control_unit 
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
module control_unit(

    input [5:0] opcode,

    output reg reg_dst,
    output reg alu_src,
    output reg mem_to_reg,
    output reg reg_write,
    output reg mem_read,
    output reg mem_write,
    output reg branch,
    output reg [1:0] alu_op

);

always @(*)
begin

    reg_dst    = 0;
    alu_src    = 0;
    mem_to_reg = 0;
    reg_write  = 0;
    mem_read   = 0;
    mem_write  = 0;
    branch     = 0;
    alu_op     = 2'b00;

    case(opcode)

    6'b000000:
    begin
        reg_dst   = 1;
        reg_write = 1;
        alu_op    = 2'b10;
    end

    6'b001000:
    begin
        alu_src   = 1;
        reg_write = 1;
        alu_op    = 2'b00;
    end

    6'b100011:
    begin
        alu_src    = 1;
        mem_to_reg = 1;
        reg_write  = 1;
        mem_read   = 1;
        alu_op     = 2'b00;
    end

    6'b101011:
    begin
        alu_src   = 1;
        mem_write = 1;
        alu_op    = 2'b00;
    end

    6'b000100:
    begin
        branch = 1;
        alu_op = 2'b01;
    end

    endcase

end

endmodule