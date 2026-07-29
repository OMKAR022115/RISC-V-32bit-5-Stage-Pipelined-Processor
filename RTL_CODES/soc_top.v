`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    05:42:34 07/02/2026 
// Design Name: 
// Module Name:    soc_top 
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
//////////////////////////////////////////////////////////////////////////////////
// Project : RISC + Ethernet Simple SoC
//////////////////////////////////////////////////////////////////////////////////
module soc_top(

    input  wire clk,
    input  wire reset,

    input  wire [7:0] phy_rx_data,
    input  wire       phy_rx_valid,

    output wire [7:0] phy_tx_data,
    output wire       phy_tx_valid

);
    //----------------------------------------------------------------------
    // CPU Memory Interface
    //----------------------------------------------------------------------
    wire [31:0] cpu_mem_addr;
    wire [31:0] cpu_mem_wdata;
    wire [31:0] cpu_mem_rdata;
    wire        cpu_mem_read;
    wire        cpu_mem_write;

    //----------------------------------------------------------------------
    // Address Decoder
    //----------------------------------------------------------------------
    wire mem_select;
    wire eth_select;

    //----------------------------------------------------------------------
    // Slave Read Data
    //----------------------------------------------------------------------
    wire [31:0] ram_rdata;
    wire [31:0] eth_rdata;


    



    //----------------------------------------------------------------------
    // Read Data Multiplexer
    //----------------------------------------------------------------------
    assign cpu_mem_rdata =
            mem_select ? ram_rdata :
            eth_select ? eth_rdata :
            32'h00000000;

    //----------------------------------------------------------------------
    // Address Decoder
    //----------------------------------------------------------------------
    address_decoder ADDRESS_DECODER(

        .address(cpu_mem_addr),

        .mem_select(mem_select),

        .eth_select(eth_select)

    );

    //----------------------------------------------------------------------
    // CPU
    //----------------------------------------------------------------------
    cpu_top CPU(

        .clk(clk),
        .rst(reset),

        .mem_addr(cpu_mem_addr),
        .mem_wdata(cpu_mem_wdata),
        .mem_rdata(cpu_mem_rdata),
        .mem_read(cpu_mem_read),
        .mem_write(cpu_mem_write),

        // Debug Ports
        .debug_pc(),
        .debug_instr(),
        .debug_wb_data(),
        .debug_wb_reg()

    );

    //----------------------------------------------------------------------
    // Data Memory
    //----------------------------------------------------------------------
    data_memory DATA_MEMORY(

        .clk(clk),

        .mem_read(cpu_mem_read & mem_select),

        .mem_write(cpu_mem_write & mem_select),

        .address(cpu_mem_addr[7:0]),

        .write_data(cpu_mem_wdata),

        .read_data(ram_rdata)

    );

    //----------------------------------------------------------------------
    // Ethernet Controller
    //----------------------------------------------------------------------
    Ethernet_Top ETHERNET(

        .clk(clk),
        .reset(reset),

        // Memory Mapped Interface
        .cs(eth_select),

        .write_enable(cpu_mem_write & eth_select),

        .read_enable(cpu_mem_read & eth_select),

        .address(cpu_mem_addr[7:0]),

        .write_data(cpu_mem_wdata),

        .read_data(eth_rdata),

        // PHY Interface
        .phy_rx_data(phy_rx_data),
        .phy_rx_valid(phy_rx_valid),

        .phy_tx_data(phy_tx_data),
        .phy_tx_valid(phy_tx_valid),

        // Status
        .busy(),
        .tx_complete(),
        .rx_complete()

    );

endmodule
