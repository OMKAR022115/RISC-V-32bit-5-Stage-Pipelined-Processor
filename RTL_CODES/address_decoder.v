`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    05:32:41 07/02/2026 
// Design Name: 
// Module Name:    address_decoder 
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
module address_decoder (
    input  wire [31:0] address,
    output wire        mem_select,
    output wire        eth_select
);
    // 0x00000000 - 0x00000FFF for Data Memory
    assign mem_select = (address < 32'h00001000) ? 1'b1 : 1'b0;
    
    // 0x00001000 and above for Ethernet Registers
    assign eth_select = (address >= 32'h00001000) ? 1'b1 : 1'b0;

endmodule
