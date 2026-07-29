`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    03:43:39 06/22/2026 
// Design Name: 
// Module Name:    forwardin_unit 
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
module forwarding_unit(

    input exmem_reg_write,
    input [4:0] exmem_rd,

    input memwb_reg_write,
    input [4:0] memwb_rd,

    input [4:0] idex_rs,
    input [4:0] idex_rt,

    output reg [1:0] forward_a,
    output reg [1:0] forward_b

);

always @(*)
begin

    forward_a = 2'b00;
    forward_b = 2'b00;

    // EX hazard

    if(exmem_reg_write &&
       (exmem_rd != 0) &&
       (exmem_rd == idex_rs))
        forward_a = 2'b10;

    if(exmem_reg_write &&
       (exmem_rd != 0) &&
       (exmem_rd == idex_rt))
        forward_b = 2'b10;

    // MEM hazard

    if(memwb_reg_write &&
       (memwb_rd != 0) &&
       !(exmem_reg_write &&
         (exmem_rd != 0) &&
         (exmem_rd == idex_rs)) &&
       (memwb_rd == idex_rs))
        forward_a = 2'b01;

    if(memwb_reg_write &&
       (memwb_rd != 0) &&
       !(exmem_reg_write &&
         (exmem_rd != 0) &&
         (exmem_rd == idex_rt)) &&
       (memwb_rd == idex_rt))
        forward_b = 2'b01;

end

endmodule