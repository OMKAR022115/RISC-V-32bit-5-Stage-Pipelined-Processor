`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    04:55:24 06/22/2026 
// Design Name: 
// Module Name:    hazard_detection_unit 
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
module hazard_detection_unit(

    input idex_mem_read,

    input [4:0] idex_rt,

    input [4:0] ifid_rs,
    input [4:0] ifid_rt,

    output reg pc_write,
    output reg ifid_write,
    output reg control_flush

);

always @(*)
begin

if(idex_mem_read &&
   (idex_rt != 5'd0) &&
   ((idex_rt == ifid_rs) ||
    (idex_rt == ifid_rt)))
    begin

        pc_write      = 1'b0;
        ifid_write    = 1'b0;
        control_flush = 1'b1;

    end
    else
    begin

        pc_write      = 1'b1;
        ifid_write    = 1'b1;
        control_flush = 1'b0;

    end

end

endmodule