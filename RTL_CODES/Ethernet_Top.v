`timescale 1ns / 1ps
module Ethernet_Top(

    input wire clk,
    input wire reset,
	 
//================ Memory Mapped CPU Interface =================
input  wire        cs,
input  wire        write_enable,
input  wire        read_enable,
input  wire [7:0]  address,
input  wire [31:0] write_data,
output reg  [31:0] read_data,
//==============================================================
	 
 // PHY Interface
    input wire [7:0] phy_rx_data,
    input wire phy_rx_valid,
    output wire [7:0] phy_tx_data,
    output wire phy_tx_valid,
	 
	 // Status
    output wire busy,
    output wire tx_complete,
    output wire rx_complete
);
//------------------------------------------------------------
// Memory Mapped Registers
//------------------------------------------------------------
reg tx_request_reg;
reg rx_request_reg;
reg tx_fifo_wr_reg;
reg rx_fifo_rd_reg;
reg [7:0] tx_fifo_data_reg;
wire [7:0] rx_fifo_data;
// Internal Wires
//---------------- TX FIFO ----------------

wire [7:0] tx_fifo_out;
wire tx_fifo_full;
wire tx_fifo_empty;
wire [4:0] tx_fifo_count;
wire tx_fifo_rd;

//---------------- RX FIFO ----------------

wire rx_fifo_full;
wire rx_fifo_empty;
wire [4:0] rx_fifo_count;
wire rx_fifo_wr;

//---------------- Controller ----------------

wire tx_start;
wire rx_start;
wire tx_done;
wire rx_done;

//---------------- CRC ----------------

wire crc_enable;
wire [31:0] crc_out;

// TX FIFO
Ethernet_FIFO_TX TX_FIFO(
    .clk(clk),
    .reset(reset),
    .wr_en(tx_fifo_wr_reg),
    .data_in(tx_fifo_data_reg),
    .rd_en(tx_fifo_rd),
    .data_out(tx_fifo_out),
    .full(tx_fifo_full),
    .empty(tx_fifo_empty),
    .fifo_count(tx_fifo_count)
);
// RX FIFO
Ethernet_FIFO_RX RX_FIFO(
    .clk(clk),
    .reset(reset),
.wr_en(tx_fifo_wr_reg),
.data_in(tx_fifo_data_reg),
.rd_en(rx_fifo_rd_reg),
    .data_out(rx_fifo_data),
    .full(rx_fifo_full),
    .empty(rx_fifo_empty),
    .fifo_count(rx_fifo_count)
);

// CRC Generator
Ethernet_CRC32 CRC(
    .clk(clk),
    .reset(reset),
    .enable(crc_enable),
    .data_in(tx_fifo_out),
    .crc_out(crc_out)
);

// Ethernet Transmitter

Ethernet_TX TX(
    .clk(clk),
    .reset(reset),
    .tx_start(tx_start),
    .fifo_empty(tx_fifo_empty),
    .fifo_data(tx_fifo_out),
    .fifo_rd(tx_fifo_rd),
    .crc_enable(crc_enable),
    .tx_data(phy_tx_data),
    .tx_valid(phy_tx_valid),
    .tx_done(tx_done)
);

// Ethernet Receiver
Ethernet_RX RX(
    .clk(clk),
    .reset(reset),
    .rx_data(phy_rx_data),
    .rx_valid(phy_rx_valid),
    .fifo_wr(rx_fifo_wr),
    .fifo_data(rx_fifo_in),
    .crc_enable(),
    .rx_done(rx_done)
);

// Controller
Ethernet_Controller CONTROLLER(
    .clk(clk),
    .reset(reset),
.tx_request(tx_request_reg),
.rx_request(rx_request_reg),
    .tx_start(tx_start),
    .rx_start(rx_start),
    .tx_done(tx_done),
    .rx_done(rx_done),
    .busy(busy),
    .tx_complete(tx_complete),
    .rx_complete(rx_complete)
);
//------------------------------------------------------------
// CPU Write Interface
//------------------------------------------------------------
always @(posedge clk or posedge reset)
begin

    if(reset)
    begin

        tx_request_reg   <= 1'b0;
        rx_request_reg   <= 1'b0;
        tx_fifo_wr_reg   <= 1'b0;
        rx_fifo_rd_reg   <= 1'b0;
        tx_fifo_data_reg <= 8'd0;

    end

    else
    begin

        tx_request_reg <= 1'b0;
        rx_request_reg <= 1'b0;
        tx_fifo_wr_reg <= 1'b0;
        rx_fifo_rd_reg <= 1'b0;

        if(cs && write_enable)
        begin

            case(address)

            8'h00:
            begin
                tx_fifo_data_reg <= write_data[7:0];
                tx_fifo_wr_reg   <= 1'b1;
            end

            8'h04:
            begin
                tx_request_reg <= 1'b1;
            end

            8'h08:
            begin
                rx_request_reg <= 1'b1;
            end

            8'h0C:
            begin
                rx_fifo_rd_reg <= 1'b1;
            end

            endcase

        end

    end

end
//------------------------------------------------------------
// CPU Read Interface
//------------------------------------------------------------
always @(*)
begin

    read_data = 32'd0;

    if(cs && read_enable)
    begin

        case(address)

        8'h00:
            read_data = {24'd0,rx_fifo_data};

        8'h04:
            read_data = {29'd0,rx_complete,tx_complete,busy};

        default:
            read_data = 32'd0;

        endcase

    end

end
endmodule
