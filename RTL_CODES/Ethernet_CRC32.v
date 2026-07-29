`timescale 1ns / 1ps
module Ethernet_CRC32(
    input wire clk,
    input wire reset,
    input wire enable,
    input wire [7:0] data_in,

    output reg [31:0] crc_out
);

reg [31:0] crc;
reg [31:0] next_crc;
integer i;

always @(posedge clk)
begin
  if(reset)
    begin
        crc <= 32'hFFFFFFFF;
    end
    else if(enable)
    begin

        next_crc = crc ^ {data_in,24'b0};
		 for(i=0;i<8;i=i+1)
        begin
            if(next_crc[31])
                next_crc = (next_crc << 1) ^ 32'h04C11DB7;
            else
                next_crc = next_crc << 1;
        end
		  crc<= next_crc;

    end
end

always @(posedge clk)
begin
    if(reset)
        crc_out <= 32'hFFFFFFFF;
    else
        crc_out <= ~crc;
end
endmodule
