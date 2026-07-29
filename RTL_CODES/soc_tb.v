`timescale 1ns/1ps

module soc_tb;

reg clk;
reg reset;
reg [7:0] phy_rx_data;
reg        phy_rx_valid;

wire [7:0] phy_tx_data;
wire        phy_tx_valid;

integer error_count;
integer warning_count;
integer reset_count;
integer cpu_read_count;
integer cpu_write_count;
integer eth_read_count;
integer eth_write_count;
integer mem_read_count;
integer mem_write_count;
integer packets_tx_count;
integer packets_rx_drive_count;
integer tx_valid_byte_count;
integer rx_valid_byte_count;
integer branch_taken_count;
integer hazard_stall_count;
integer invalid_addr_count;
integer decoder_mem_count;
integer decoder_eth_count;
integer tx_fifo_full_hit_count;
integer rx_fifo_empty_read_count;
integer cpu_rw_conflict_count;
integer boundary_first_count;
integer boundary_last_count;
integer random_access_count;
integer sequential_access_count;
integer repeated_access_count;
integer execution_done;
integer start_time;
integer end_time;
integer temp_i;
integer seed;
integer last_mem_addr;
integer last_eth_addr;
integer tx_packet_active;
integer tx_packet_seen_bytes;
integer ctrl_prev_state;
integer tx_prev_state;
integer rx_prev_state;

integer ctrl_state_hit_0, ctrl_state_hit_1, ctrl_state_hit_2;
integer ctrl_state_hit_3, ctrl_state_hit_4, ctrl_state_hit_5;
integer tx_state_hit_0, tx_state_hit_1, tx_state_hit_2;
integer tx_state_hit_3, tx_state_hit_4, tx_state_hit_5;
integer rx_state_hit_0, rx_state_hit_1, rx_state_hit_2;
integer rx_state_hit_3, rx_state_hit_4, rx_state_hit_5;
integer ctrl_transition_count;
integer tx_transition_count;
integer rx_transition_count;

reg [31:0] read_data_capture;
reg [31:0] expected_data;
reg [31:0] observed_data;
reg [31:0] rand_word;
reg [7:0]  rand_byte;

soc_top DUT(
    .clk(clk),
    .reset(reset),
    .phy_rx_data(phy_rx_data),
    .phy_rx_valid(phy_rx_valid),
    .phy_tx_data(phy_tx_data),
    .phy_tx_valid(phy_tx_valid)
);

function [7:0] pattern_byte;
    input integer mode;
    input integer idx;
    input integer plen;
    begin
        case (mode)
            0: pattern_byte = 8'h55;
            1: pattern_byte = 8'hAA;
            2: pattern_byte = idx[7:0];
            3: pattern_byte = (plen - 1 - idx) & 8'hFF;
            4: pattern_byte = (8'h01 << (idx % 8));
            5: pattern_byte = ~(8'h01 << (idx % 8));
            default: pattern_byte = $random(seed);
        endcase
    end
endfunction

function integer visited6;
    input integer h0, h1, h2, h3, h4, h5;
    begin
        visited6 = 0;
        if (h0 > 0) visited6 = visited6 + 1;
        if (h1 > 0) visited6 = visited6 + 1;
        if (h2 > 0) visited6 = visited6 + 1;
        if (h3 > 0) visited6 = visited6 + 1;
        if (h4 > 0) visited6 = visited6 + 1;
        if (h5 > 0) visited6 = visited6 + 1;
    end
endfunction

function [31:0] abs32;
    input [31:0] value;
    begin
        if (value[31])
            abs32 = (~value) + 1'b1;
        else
            abs32 = value;
    end
endfunction

task init_counters;
    begin
        error_count = 0;
        warning_count = 0;
        reset_count = 0;
        cpu_read_count = 0;
        cpu_write_count = 0;
        eth_read_count = 0;
        eth_write_count = 0;
        mem_read_count = 0;
        mem_write_count = 0;
        packets_tx_count = 0;
        packets_rx_drive_count = 0;
        tx_valid_byte_count = 0;
        rx_valid_byte_count = 0;
        branch_taken_count = 0;
        hazard_stall_count = 0;
        invalid_addr_count = 0;
        decoder_mem_count = 0;
        decoder_eth_count = 0;
        tx_fifo_full_hit_count = 0;
        rx_fifo_empty_read_count = 0;
        cpu_rw_conflict_count = 0;
        boundary_first_count = 0;
        boundary_last_count = 0;
        random_access_count = 0;
        sequential_access_count = 0;
        repeated_access_count = 0;
        execution_done = 0;
        seed = 32'h13579BDF;
        last_mem_addr = -1;
        last_eth_addr = -1;
        tx_packet_active = 0;
        tx_packet_seen_bytes = 0;
        ctrl_prev_state = -1;
        tx_prev_state = -1;
        rx_prev_state = -1;
        ctrl_transition_count = 0;
        tx_transition_count = 0;
        rx_transition_count = 0;
        ctrl_state_hit_0 = 0; ctrl_state_hit_1 = 0; ctrl_state_hit_2 = 0;
        ctrl_state_hit_3 = 0; ctrl_state_hit_4 = 0; ctrl_state_hit_5 = 0;
        tx_state_hit_0 = 0; tx_state_hit_1 = 0; tx_state_hit_2 = 0;
        tx_state_hit_3 = 0; tx_state_hit_4 = 0; tx_state_hit_5 = 0;
        rx_state_hit_0 = 0; rx_state_hit_1 = 0; rx_state_hit_2 = 0;
        rx_state_hit_3 = 0; rx_state_hit_4 = 0; rx_state_hit_5 = 0;
    end
endtask

task apply_reset_cycles;
    input integer cycles;
    begin
        reset = 1'b1;
        phy_rx_valid = 1'b0;
        phy_rx_data  = 8'h00;
        reset_count = reset_count + 1;
        repeat(cycles) @(posedge clk);
        reset = 1'b0;
        @(posedge clk);
    end
endtask

task soc_write;
    input [31:0] addr;
    input [31:0] data;
    begin
        @(negedge clk);
        force DUT.cpu_mem_addr  = addr;
        force DUT.cpu_mem_wdata = data;
        force DUT.cpu_mem_write = 1'b1;
        force DUT.cpu_mem_read  = 1'b0;
        @(posedge clk);
        #1;
        release DUT.cpu_mem_addr;
        release DUT.cpu_mem_wdata;
        release DUT.cpu_mem_write;
        release DUT.cpu_mem_read;
        @(posedge clk);
    end
endtask

task soc_read;
    input [31:0] addr;
    output [31:0] data;
    begin
        @(negedge clk);
        force DUT.cpu_mem_addr  = addr;
        force DUT.cpu_mem_wdata = 32'h00000000;
        force DUT.cpu_mem_write = 1'b0;
        force DUT.cpu_mem_read  = 1'b1;
        @(posedge clk);
        #1 data = DUT.cpu_mem_rdata;
        release DUT.cpu_mem_addr;
        release DUT.cpu_mem_wdata;
        release DUT.cpu_mem_write;
        release DUT.cpu_mem_read;
        @(posedge clk);
    end
endtask

task wait_ctrl_idle;
    input integer max_cycles;
    integer k;
    integer seen;
    begin
        seen = 0;
        for (k = 0; k < max_cycles; k = k + 1) begin
            @(posedge clk);
            if (DUT.ETHERNET.CONTROLLER.state == 3'd0) begin
                seen = 1;
                k = max_cycles;
            end
        end
        if (!seen) begin
            error_count = error_count + 1;
            $display("ERROR: controller did not return to IDLE by time %0t", $time);
        end
    end
endtask

task wait_tx_done;
    input integer max_cycles;
    integer k;
    integer seen;
    begin
        seen = 0;
        for (k = 0; k < max_cycles; k = k + 1) begin
            @(posedge clk);
            if (DUT.ETHERNET.tx_complete) begin
                seen = 1;
                k = max_cycles;
            end
        end
        if (!seen) begin
            error_count = error_count + 1;
            $display("ERROR: tx_complete timeout at %0t", $time);
        end
    end
endtask

task wait_rx_done;
    input integer max_cycles;
    integer k;
    integer seen;
    begin
        seen = 0;
        for (k = 0; k < max_cycles; k = k + 1) begin
            @(posedge clk);
            if (DUT.ETHERNET.rx_complete || DUT.ETHERNET.RX.rx_done) begin
                seen = 1;
                k = max_cycles;
            end
        end
        if (!seen) begin
            warning_count = warning_count + 1;
            $display("WARNING: rx_done timeout at %0t", $time);
        end
    end
endtask

task send_rx_packet;
    input integer plen;
    input integer mode;
    input integer use_eight_preamble;
    input integer insert_payload_idles;
    integer i;
    integer pcount;
    begin
        packets_rx_drive_count = packets_rx_drive_count + 1;
        pcount = use_eight_preamble ? 8 : 7;
        @(negedge clk);
        for (i = 0; i < pcount; i = i + 1) begin
            phy_rx_valid = 1'b1;
            phy_rx_data  = 8'h55;
            @(posedge clk);
            if (insert_payload_idles && (i == 2)) begin
                @(negedge clk);
                phy_rx_valid = 1'b0;
                phy_rx_data  = 8'h00;
                @(posedge clk);
                @(negedge clk);
            end else begin
                @(negedge clk);
            end
        end
        phy_rx_valid = 1'b1;
        phy_rx_data  = 8'hD5;
        @(posedge clk);
        @(negedge clk);
        for (i = 0; i < plen; i = i + 1) begin
            phy_rx_valid = 1'b1;
            phy_rx_data  = pattern_byte(mode, i, plen);
            @(posedge clk);
            if (insert_payload_idles && ((i % 3) == 1)) begin
                @(negedge clk);
                phy_rx_valid = 1'b0;
                phy_rx_data  = 8'h00;
                @(posedge clk);
            end
            @(negedge clk);
        end
        phy_rx_valid = 1'b0;
        phy_rx_data  = 8'h00;
        @(posedge clk);
    end
endtask

task request_rx_and_send_packet;
    input integer plen;
    input integer mode;
    begin
        soc_write(32'h00001008, 32'h00000001);
        @(posedge clk);
        send_rx_packet(plen, mode, 1, 0);
        wait_rx_done(60);
        wait_ctrl_idle(60);
    end
endtask

task send_bad_rx_sequence;
    begin
        @(negedge clk);
        phy_rx_valid = 1'b1;
        phy_rx_data  = 8'h55; @(posedge clk);
        @(negedge clk);
        phy_rx_data  = 8'h54; @(posedge clk);
        @(negedge clk);
        phy_rx_data  = 8'hD5; @(posedge clk);
        @(negedge clk);
        phy_rx_valid = 1'b0;
        phy_rx_data  = 8'h00;
        @(posedge clk);
    end
endtask

task start_tx_packet;
    input integer plen;
    input integer mode;
    integer i;
    reg [31:0] local_rd;
    begin
        for (i = 0; i < plen; i = i + 1) begin
            soc_write(32'h00001000, {24'h0, pattern_byte(mode, i, plen)});
        end
        soc_write(32'h00001004, 32'h00000001);
        soc_read(32'h00001004, local_rd);
        wait_tx_done(80);
        wait_ctrl_idle(40);
    end
endtask

task memory_write_read_check;
    input [31:0] addr;
    input [31:0] data;
    reg [31:0] rd;
    begin
        soc_write(addr, data);
        soc_read(addr, rd);
        if (rd !== data) begin
            error_count = error_count + 1;
            $display("ERROR: memory mismatch addr=%h exp=%h got=%h time=%0t", addr, data, rd, $time);
        end
    end
endtask

task ethernet_register_sweep;
    reg [31:0] rd;
    begin
        soc_write(32'h00001000, 32'h000000A5);
        soc_write(32'h00001004, 32'h00000001);
        soc_write(32'h00001008, 32'h00000001);
        soc_write(32'h0000100C, 32'h00000000);
        soc_read(32'h00001000, rd);
        soc_read(32'h00001004, rd);
        soc_read(32'h00001008, rd);
        soc_read(32'h0000100C, rd);
        wait_ctrl_idle(50);
    end
endtask

task random_memory_burst;
    input integer count;
    integer i;
    reg [31:0] a;
    reg [31:0] d;
    reg [31:0] rd;
    begin
        for (i = 0; i < count; i = i + 1) begin
            a = {$random(seed)} & 32'h000000FF;
            d = $random(seed);
            soc_write(a, d);
            soc_read(a, rd);
            if (rd !== d) begin
                error_count = error_count + 1;
                $display("ERROR: random memory mismatch addr=%h exp=%h got=%h", a, d, rd);
            end
        end
    end
endtask

task random_resets;
    input integer count;
    integer i;
    integer gap;
    integer width;
    begin
        for (i = 0; i < count; i = i + 1) begin
            gap = (({$random(seed)} & 32'hF) + 2);
            width = (({$random(seed)} & 32'h3) + 1);
            repeat(gap) @(posedge clk);
            apply_reset_cycles(width);
        end
    end
endtask

// =========================================================================
// ENHANCED TASKS: Pushing Toggle & FEC/Condition Coverage to >92%
// =========================================================================
task memory_toggle_sweep;
    integer i;
    reg [31:0] data;
    reg [31:0] addr;
    reg [31:0] rd;
    begin
        // 1. Data Bus Toggle (Walking 1s and 0s) - using mapped memory space
        for (i = 0; i < 32; i = i + 1) begin
            data = 32'h1 << i;
            memory_write_read_check(32'h00000010, data);
        end
        for (i = 0; i < 32; i = i + 1) begin
            data = ~(32'h1 << i);
            memory_write_read_check(32'h00000014, data);
        end
        
        // 2. Data Bus Alternating Bits
        memory_write_read_check(32'h00000018, 32'h55555555);
        memory_write_read_check(32'h0000001C, 32'hAAAAAAAA);
        
        // 3. Address Bus Toggle Coverage (Walking 1s across all 32-bits)
        // This intentionally exercises the decoder's default case (unmapped branches)
        for (i = 0; i < 32; i = i + 1) begin
            addr = 32'h1 << i;
            soc_write(addr, 32'hBEEFCAFE);
            soc_read(addr, rd); // Read back to toggle address lines on read channel
        end
        
        // 4. Address Bus Toggle Coverage (Walking 0s across all 32-bits)
        for (i = 0; i < 32; i = i + 1) begin
            addr = ~(32'h1 << i);
            soc_write(addr, 32'hDEADBEEF);
            soc_read(addr, rd);
        end
    end
endtask

task condition_stress;
    integer i;
    reg [31:0] rdata;
    begin
        // Condition: Overfill TX FIFO 
        // Triggers the tx_fifo_full branch logic repeatedly
        for (i = 0; i < 40; i = i + 1) begin
            soc_write(32'h00001000, 32'h000000FF);
        end
        
        // Condition: Start TX after Overfill to hit edge cases
        soc_write(32'h00001004, 32'h00000001); 
        
        // Read Status repeatedly while busy (Forces controller FSM to output busy conditions)
        for (i = 0; i < 15; i = i + 1) begin
            soc_read(32'h00001004, rdata);
        end
        wait_tx_done(150);
        wait_ctrl_idle(50);
        
        // Condition: Read empty RX FIFO
        // Triggers rx_fifo_empty_read condition check
        for (i = 0; i < 8; i = i + 1) begin
            soc_write(32'h0000100C, 32'h00000001); // RX FIFO Read Reg
            soc_read(32'h00001000, rdata);         // RX FIFO Data Reg
        end
        
        // Condition: Simultaneous RX and TX Request from CPU
        // Stresses priority encoding in the Controller FSM
        soc_write(32'h00001000, 32'h000000AB);
        soc_write(32'h00001000, 32'h000000CD);
        soc_write(32'h00001004, 32'h00000001); // TX Start
        soc_write(32'h00001008, 32'h00000001); // RX Start
        wait_ctrl_idle(100);
    end
endtask
// =========================================================================

initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
end

always @(posedge clk) begin
    if (!execution_done) begin
        if (DUT.mem_select) decoder_mem_count = decoder_mem_count + 1;
        if (DUT.eth_select) decoder_eth_count = decoder_eth_count + 1;

        if (DUT.cpu_mem_write) begin
            cpu_write_count = cpu_write_count + 1;
            if (DUT.mem_select) mem_write_count = mem_write_count + 1;
            if (DUT.eth_select) eth_write_count = eth_write_count + 1;
            if (DUT.cpu_mem_addr[31:8] == 24'h0) begin
                if (last_mem_addr == DUT.cpu_mem_addr[7:0]) repeated_access_count = repeated_access_count + 1;
                else if (last_mem_addr >= 0 && DUT.cpu_mem_addr[7:0] == ((last_mem_addr + 1) & 8'hFF)) sequential_access_count = sequential_access_count + 1;
                else random_access_count = random_access_count + 1;
                last_mem_addr = DUT.cpu_mem_addr[7:0];
                if (DUT.cpu_mem_addr[7:0] == 8'h00) boundary_first_count = boundary_first_count + 1;
                if (DUT.cpu_mem_addr[7:0] == 8'hFF) boundary_last_count = boundary_last_count + 1;
            end
        end

        if (DUT.cpu_mem_read) begin
            cpu_read_count = cpu_read_count + 1;
            if (DUT.mem_select) mem_read_count = mem_read_count + 1;
            if (DUT.eth_select) eth_read_count = eth_read_count + 1;
            if (DUT.cpu_mem_addr[31:8] == 24'h0) begin
                if (DUT.cpu_mem_addr[7:0] == 8'h00) boundary_first_count = boundary_first_count + 1;
                if (DUT.cpu_mem_addr[7:0] == 8'hFF) boundary_last_count = boundary_last_count + 1;
            end
        end

        if (DUT.cpu_mem_read && DUT.cpu_mem_write) begin
            cpu_rw_conflict_count = cpu_rw_conflict_count + 1;
            error_count = error_count + 1;
            $display("ERROR: simultaneous cpu_mem_read/cpu_mem_write at %0t", $time);
        end

        if (DUT.CPU.ex_branch_taken)
            branch_taken_count = branch_taken_count + 1;
        if (!DUT.CPU.pc_write_int || !DUT.CPU.ifid_write_int)
            hazard_stall_count = hazard_stall_count + 1;
    end
end

always @(posedge clk) begin
    if (phy_tx_valid)
        tx_valid_byte_count = tx_valid_byte_count + 1;
    if (phy_rx_valid)
        rx_valid_byte_count = rx_valid_byte_count + 1;

    if (!tx_packet_active && phy_tx_valid) begin
        tx_packet_active = 1;
        tx_packet_seen_bytes = 1;
        packets_tx_count = packets_tx_count + 1;
    end else if (tx_packet_active && phy_tx_valid) begin
        tx_packet_seen_bytes = tx_packet_seen_bytes + 1;
    end else if (tx_packet_active && !phy_tx_valid) begin
        tx_packet_active = 0;
    end
end

always @(posedge clk) begin
    case (DUT.ETHERNET.CONTROLLER.state)
        3'd0: ctrl_state_hit_0 = ctrl_state_hit_0 + 1;
        3'd1: ctrl_state_hit_1 = ctrl_state_hit_1 + 1;
        3'd2: ctrl_state_hit_2 = ctrl_state_hit_2 + 1;
        3'd3: ctrl_state_hit_3 = ctrl_state_hit_3 + 1;
        3'd4: ctrl_state_hit_4 = ctrl_state_hit_4 + 1;
        3'd5: ctrl_state_hit_5 = ctrl_state_hit_5 + 1;
    endcase
    case (DUT.ETHERNET.TX.state)
        3'd0: tx_state_hit_0 = tx_state_hit_0 + 1;
        3'd1: tx_state_hit_1 = tx_state_hit_1 + 1;
        3'd2: tx_state_hit_2 = tx_state_hit_2 + 1;
        3'd3: tx_state_hit_3 = tx_state_hit_3 + 1;
        3'd4: tx_state_hit_4 = tx_state_hit_4 + 1;
        3'd5: tx_state_hit_5 = tx_state_hit_5 + 1;
    endcase
    case (DUT.ETHERNET.RX.state)
        3'd0: rx_state_hit_0 = rx_state_hit_0 + 1;
        3'd1: rx_state_hit_1 = rx_state_hit_1 + 1;
        3'd2: rx_state_hit_2 = rx_state_hit_2 + 1;
        3'd3: rx_state_hit_3 = rx_state_hit_3 + 1;
        3'd4: rx_state_hit_4 = rx_state_hit_4 + 1;
        3'd5: rx_state_hit_5 = rx_state_hit_5 + 1;
    endcase

    if (!reset) begin
        if ((ctrl_prev_state >= 0) && (ctrl_prev_state != DUT.ETHERNET.CONTROLLER.state))
            ctrl_transition_count = ctrl_transition_count + 1;
        if ((tx_prev_state >= 0) && (tx_prev_state != DUT.ETHERNET.TX.state))
            tx_transition_count = tx_transition_count + 1;
        if ((rx_prev_state >= 0) && (rx_prev_state != DUT.ETHERNET.RX.state))
            rx_transition_count = rx_transition_count + 1;
    end
    ctrl_prev_state = DUT.ETHERNET.CONTROLLER.state;
    tx_prev_state   = DUT.ETHERNET.TX.state;
    rx_prev_state   = DUT.ETHERNET.RX.state;

    if (DUT.ETHERNET.tx_fifo_wr_reg && DUT.ETHERNET.tx_fifo_full)
        tx_fifo_full_hit_count = tx_fifo_full_hit_count + 1;
    if (DUT.ETHERNET.rx_fifo_rd_reg && DUT.ETHERNET.rx_fifo_empty)
        rx_fifo_empty_read_count = rx_fifo_empty_read_count + 1;
end

always @(posedge clk) begin
    if (!reset) begin
        if ((phy_tx_valid !== 1'b0) && (phy_tx_valid !== 1'b1)) begin
            error_count = error_count + 1;
            $display("ERROR: X/Z on phy_tx_valid at %0t", $time);
        end
        if ((phy_rx_valid !== 1'b0) && (phy_rx_valid !== 1'b1)) begin
            error_count = error_count + 1;
            $display("ERROR: X/Z on phy_rx_valid at %0t", $time);
        end
        if (^phy_tx_data === 1'bx) begin
            error_count = error_count + 1;
            $display("ERROR: X/Z on phy_tx_data at %0t", $time);
        end
        if (^phy_rx_data === 1'bx) begin
            error_count = error_count + 1;
            $display("ERROR: X/Z on phy_rx_data at %0t", $time);
        end
        if (^DUT.cpu_mem_addr === 1'bx) begin
            error_count = error_count + 1;
            $display("ERROR: X/Z on cpu_mem_addr at %0t", $time);
        end
        if (DUT.mem_select && DUT.eth_select) begin
            error_count = error_count + 1;
            $display("ERROR: decoder selected RAM and ETH simultaneously at %0t", $time);
        end
        if ((DUT.cpu_mem_read || DUT.cpu_mem_write) && !(DUT.mem_select || DUT.eth_select)) begin
            invalid_addr_count = invalid_addr_count + 1;
            warning_count = warning_count + 1;
            // Removed specific display output here to reduce clutter, but metric is logged
        end
    end
end

initial begin
    $dumpfile("soc.vcd");
    $dumpvars(0, soc_tb);
end

initial begin
    init_counters;
    start_time = $time;
    clk = 1'b0;
    reset = 1'b1;
    phy_rx_data = 8'h00;
    phy_rx_valid = 1'b0;

    $display("------------------------------------------");
    $display(" RTL-aware SoC verification started ");
    $display("------------------------------------------");

    apply_reset_cycles(4);

    memory_write_read_check(32'h00000000, 32'h11223344);
    memory_write_read_check(32'h00000001, 32'h55667788);
    memory_write_read_check(32'h000000FF, 32'hA5A55A5A);
    memory_write_read_check(32'h00000020, 32'hCAFEBABE);
    random_memory_burst(6);

    // --- Enhanced Toggle & Condition Execution ---
    memory_toggle_sweep;
    condition_stress;
    // ---------------------------------------------

    ethernet_register_sweep;
    start_tx_packet(1, 0);
    start_tx_packet(4, 1);
    start_tx_packet(8, 2);
    start_tx_packet(16, 3);
    start_tx_packet(8, 4);
    start_tx_packet(8, 5);
    start_tx_packet(6, 6);

    send_bad_rx_sequence;
    request_rx_and_send_packet(0, 0);
    request_rx_and_send_packet(1, 0);
    request_rx_and_send_packet(4, 1);
    request_rx_and_send_packet(8, 2);
    send_rx_packet(8, 3, 1, 0);
    send_rx_packet(8, 4, 1, 0);
    send_rx_packet(8, 5, 1, 0);
    send_rx_packet(6, 6, 1, 1);
    send_rx_packet(5, 2, 0, 0);

    // --- Concurrent TX/RX FSM Cross-Coverage Stress ---
    fork
        begin
            start_tx_packet(12, 2);
        end
        begin
            send_rx_packet(12, 3, 1, 0);
        end
    join

    repeat(3) @(posedge clk);
    apply_reset_cycles(1);

    @(negedge clk);
    phy_rx_valid = 1'b1;
    phy_rx_data  = 8'h55;
    @(posedge clk);
    @(negedge clk);
    phy_rx_data  = 8'h55;
    @(posedge clk);
    apply_reset_cycles(2);

    random_resets(3);

    repeat(180) @(posedge clk);

    soc_read(32'h00001004, observed_data);
    soc_read(32'h00001000, observed_data);
    soc_read(32'h00001008, observed_data);
    soc_read(32'h0000100C, observed_data);

    end_time = $time;
    execution_done = 1;

    $display("------------------------------------------");
    if ((error_count == 0) &&
        (visited6(ctrl_state_hit_0, ctrl_state_hit_1, ctrl_state_hit_2, ctrl_state_hit_3, ctrl_state_hit_4, ctrl_state_hit_5) == 6) &&
        (visited6(tx_state_hit_0, tx_state_hit_1, tx_state_hit_2, tx_state_hit_3, tx_state_hit_4, tx_state_hit_5) == 6) &&
        (visited6(rx_state_hit_0, rx_state_hit_1, rx_state_hit_2, rx_state_hit_3, rx_state_hit_4, rx_state_hit_5) >= 5))
        $display("FINAL RESULT : PASS");
    else
        $display("FINAL RESULT : FAIL");
    $display("------------------------------------------");
    $display("Execution time          = %0t ns", end_time - start_time);
    $display("Reset count             = %0d", reset_count);
    $display("CPU writes              = %0d", cpu_write_count);
    $display("CPU reads               = %0d", cpu_read_count);
    $display("Memory writes           = %0d", mem_write_count);
    $display("Memory reads            = %0d", mem_read_count);
    $display("Ethernet writes         = %0d", eth_write_count);
    $display("Ethernet reads          = %0d", eth_read_count);
    $display("TX packets              = %0d", packets_tx_count);
    $display("Driven RX packets       = %0d", packets_rx_drive_count);
    $display("TX valid bytes          = %0d", tx_valid_byte_count);
    $display("RX valid bytes          = %0d", rx_valid_byte_count);
    $display("Branch taken count      = %0d", branch_taken_count);
    $display("Hazard stall count      = %0d", hazard_stall_count);
    $display("Boundary first hits     = %0d", boundary_first_count);
    $display("Boundary last hits      = %0d", boundary_last_count);
    $display("Sequential accesses     = %0d", sequential_access_count);
    $display("Random accesses         = %0d", random_access_count);
    $display("Repeated accesses       = %0d", repeated_access_count);
    $display("TX FIFO full hits       = %0d", tx_fifo_full_hit_count);
    $display("RX FIFO empty reads     = %0d", rx_fifo_empty_read_count);
    $display("RW conflicts            = %0d", cpu_rw_conflict_count);
    $display("Warnings                = %0d", warning_count);
    $display("Errors                  = %0d", error_count);
    $display("CTRL state coverage     = %0d/6 states, transitions=%0d", visited6(ctrl_state_hit_0, ctrl_state_hit_1, ctrl_state_hit_2, ctrl_state_hit_3, ctrl_state_hit_4, ctrl_state_hit_5), ctrl_transition_count);
    $display("TX state coverage       = %0d/6 states, transitions=%0d", visited6(tx_state_hit_0, tx_state_hit_1, tx_state_hit_2, tx_state_hit_3, tx_state_hit_4, tx_state_hit_5), tx_transition_count);
    $display("RX state coverage       = %0d/6 states, transitions=%0d", visited6(rx_state_hit_0, rx_state_hit_1, rx_state_hit_2, rx_state_hit_3, rx_state_hit_4, rx_state_hit_5), rx_transition_count);
    $display("RAM[00]                 = %h", DUT.DATA_MEMORY.memory[8'h00]);
    $display("RAM[01]                 = %h", DUT.DATA_MEMORY.memory[8'h01]);
    $display("RAM[20]                 = %h", DUT.DATA_MEMORY.memory[8'h20]);
    $display("RAM[FF]                 = %h", DUT.DATA_MEMORY.memory[8'hFF]);
    $display("ETH status read         = %h", DUT.eth_rdata);
    $display("CTRL/TX/RX states       = %0d/%0d/%0d", DUT.ETHERNET.CONTROLLER.state, DUT.ETHERNET.TX.state, DUT.ETHERNET.RX.state);
    $display("------------------------------------------");
    $finish;
end

endmodule