`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:26:42 06/21/2026 
// Design Name: 
// Module Name:    pc 
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

module pc (
    input clk,
    input rst,
    input pc_write,
    input [31:2] next_pc, // Changed to 30-bit input
    output [31:0] pc
);
    reg [31:2] pc_reg;
    
    // Hardwire the bottom 2 bits to 0
    assign pc = {pc_reg, 2'b00};

    always @(posedge clk or posedge rst) begin
        if(rst)
            pc_reg <= 30'd0;
        else if(pc_write)
            pc_reg <= next_pc; // Direct assignment, no slicing needed inside
    end
endmodule