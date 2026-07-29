`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:45:40 06/28/2026 
// Design Name: 
// Module Name:    ethernet_apb_slave 
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


module ethernet_apb_slave(

    input PCLK,
    input PRESET,

    //---------------- APB ----------------//

    input PSEL,
    input PENABLE,
    input PWRITE,

    input [31:0] PADDR,
    input [31:0] PWDATA,

    output reg [31:0] PRDATA,
    output PREADY,

    //---------------- PHY ----------------//

    input [7:0] phy_rx_data,
    input phy_rx_valid,

    output [7:0] phy_tx_data,
    output phy_tx_valid

);

//////////////////////////////////////////////////////////
// Registers
//////////////////////////////////////////////////////////

reg tx_request;
reg rx_request;

reg tx_fifo_wr;
reg rx_fifo_rd;

reg [7:0] tx_fifo_data;

wire [7:0] rx_fifo_data;

wire busy;
wire tx_complete;
wire rx_complete;

//////////////////////////////////////////////////////////
// Ethernet Core
//////////////////////////////////////////////////////////

Ethernet_Top ETH(

    .clk(PCLK),
    .reset(PRESET),

    .tx_request(tx_request),
    .rx_request(rx_request),

    .tx_fifo_wr(tx_fifo_wr),
    .tx_fifo_data(tx_fifo_data),

    .rx_fifo_rd(rx_fifo_rd),
    .rx_fifo_data(rx_fifo_data),

    .phy_rx_data(phy_rx_data),
    .phy_rx_valid(phy_rx_valid),

    .phy_tx_data(phy_tx_data),
    .phy_tx_valid(phy_tx_valid),

    .busy(busy),
    .tx_complete(tx_complete),
    .rx_complete(rx_complete)

);

//////////////////////////////////////////////////////////
// APB Write
//////////////////////////////////////////////////////////

always @(posedge PCLK or posedge PRESET)
begin

    if(PRESET)
    begin

        tx_request <= 0;
        rx_request <= 0;

        tx_fifo_wr <= 0;
        rx_fifo_rd <= 0;

        tx_fifo_data <= 8'd0;

    end

    else
    begin

        tx_request <= 0;
        rx_request <= 0;

        tx_fifo_wr <= 0;
        rx_fifo_rd <= 0;

        if(PSEL && PENABLE && PWRITE)
        begin

            case(PADDR)

            //----------------------------------
            // TX DATA
            //----------------------------------

            32'h10000000:

            begin

                tx_fifo_data <= PWDATA[7:0];
                tx_fifo_wr <= 1'b1;

            end

            //----------------------------------
            // CONTROL
            //----------------------------------

            32'h10000004:

            begin

                tx_request <= PWDATA[0];
                rx_request <= PWDATA[1];

            end

            endcase

        end

    end

end

//////////////////////////////////////////////////////////
// APB Read
//////////////////////////////////////////////////////////

always @(*)
begin

    PRDATA = 32'd0;

    case(PADDR)

    //--------------------------------------
    // STATUS
    //--------------------------------------

    32'h10000008:

        PRDATA = {29'd0,
                  rx_complete,
                  tx_complete,
                  busy};

    //--------------------------------------
    // RX DATA
    //--------------------------------------

    32'h1000000C:

        PRDATA = {24'd0,rx_fifo_data};

    default:

        PRDATA = 32'd0;

    endcase

end

//////////////////////////////////////////////////////////
// Read Pulse
//////////////////////////////////////////////////////////

always @(posedge PCLK)
begin

    rx_fifo_rd <= 0;

    if(PSEL && PENABLE && !PWRITE)

        if(PADDR==32'h1000000C)

            rx_fifo_rd <= 1;

end

//////////////////////////////////////////////////////////

assign PREADY = 1'b1;

endmodule
