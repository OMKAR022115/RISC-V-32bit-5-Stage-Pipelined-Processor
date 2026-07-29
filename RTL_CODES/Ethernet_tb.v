`timescale 1ns / 1ps

module Ethernet_tb;

    //--------------------------------------------------
    // Inputs
    //--------------------------------------------------

    reg clk;
    reg reset;
    reg tx_request;
    reg rx_request;
    reg tx_fifo_wr;
    reg [7:0] tx_fifo_data;
    reg rx_fifo_rd;
	 reg [7:0] phy_rx_data;
    reg phy_rx_valid;
	 
    // Outputs
    wire [7:0] rx_fifo_data;
    wire [7:0] phy_tx_data;
    wire phy_tx_valid;
    wire busy;
    wire tx_complete;
    wire rx_complete;
    reg rx_done;
	 
	  // DUT
	  Ethernet_Top DUT(
        .clk(clk),
        .reset(reset),
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

 // Clock Generation
   always #5 clk = ~clk;
	
	 // Test Procedure
	  initial
    begin
        clk = 0;
        reset = 1;
        tx_request = 0;
        rx_request = 0;
        tx_fifo_wr = 0;
        tx_fifo_data = 0;
        rx_fifo_rd = 0;
        phy_rx_data = 0;
        phy_rx_valid = 0;
		  
		   // Reset
        #20;
        reset = 0;

 // Load TX FIFO
        //----------------------------------------

        #10;
        tx_fifo_wr = 1;
        tx_fifo_data = 8'h48;   // H
        #10;
        tx_fifo_data = 8'h45;   // E
        #10;
        tx_fifo_data = 8'h4C;   // L
        #10;
        tx_fifo_data = 8'h4C;   // L
        #10;
        tx_fifo_data = 8'h4F;   // O
        #10;
        tx_fifo_wr = 0;

 // Start Transmission
  tx_request = 1;
        #10;
        tx_request = 0;
       
        // Wait
        #200;

 // Simulate Receive
  phy_rx_valid = 1;
        phy_rx_data = 8'h55;
        #10;
        phy_rx_data = 8'h55;
        #10;
        phy_rx_data = 8'h55;
        #10;
        phy_rx_data = 8'h55;
        #10;
        phy_rx_data = 8'h55;
        #10;
        phy_rx_data = 8'h55;
        #10;
		  phy_rx_data = 8'h55;
        #10;
        phy_rx_data = 8'hD5;
        #10;
        phy_rx_data = 8'h48;
        #10;
        phy_rx_data = 8'h45;
        #10;
        phy_rx_data = 8'h4C;
        #10;
        phy_rx_data = 8'h4C;
        #10;
        phy_rx_data = 8'h4F;
        #10;
		   phy_rx_valid = 0;

        // Read RX FIFO
        rx_fifo_rd = 1;
        #60;
        rx_fifo_rd = 0;
        #100;
        // RX Test
#20;
rx_request = 1;
#10;
rx_request = 0;

#50;
rx_done = 1;
#10;
rx_done = 0;

#50;
        $finish;
    end
	 
	 // Monitor
	 initial
    begin
        $monitor(
        "Time=%0t | Busy=%b | TX=%h | TX_Valid=%b | RX=%h | TX_Done=%b | RX_Done=%b",
        $time,
        busy,
        phy_tx_data,
        phy_tx_valid,
        rx_fifo_data,
        tx_complete,
        rx_complete
        );
    end
	 endmodule
	 