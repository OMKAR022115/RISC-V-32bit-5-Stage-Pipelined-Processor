`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:14:10 06/21/2026 
// Design Name: 
// Module Name:    alu_control 
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
module alu_control(

    input [1:0] alu_op,
    input [5:0] funct,

    output reg [3:0] alu_ctrl

);

always @(*)
begin

    case(alu_op)

        2'b00:
            alu_ctrl = 4'b0010;

        2'b01:
            alu_ctrl = 4'b0110;

        2'b10:
        begin

            case(funct)

                6'b100000: alu_ctrl = 4'b0010; // ADD
                6'b100010: alu_ctrl = 4'b0110; // SUB
                6'b100100: alu_ctrl = 4'b0000; // AND
                6'b100101: alu_ctrl = 4'b0001; // OR
                6'b100110: alu_ctrl = 4'b0011; // XOR

                default:   alu_ctrl = 4'b0010;

            endcase

        end

        default:
            alu_ctrl = 4'b0010;

    endcase

end

endmodule
