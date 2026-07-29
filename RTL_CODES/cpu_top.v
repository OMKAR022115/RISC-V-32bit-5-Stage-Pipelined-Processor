`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name:   cpu_top 
// Description:   Top-level pipeline module for 32-bit CPU.
//                Refactored for structural clarity and readability.
//////////////////////////////////////////////////////////////////////////////////
module cpu_top(

    input clk,
    input rst,

    //================ SoC Interface =================
    output [31:0] mem_addr,
    output [31:0] mem_wdata,
    input  [31:0] mem_rdata,
    output        mem_read,
    output        mem_write,
    //================================================

    output [31:0] debug_pc,
    output [31:0] debug_instr,
    output [31:0] debug_wb_data,
    output [4:0]  debug_wb_reg
);

    // =========================================================================
    // Wire Declarations (Grouped by Pipeline Flow)
    // =========================================================================

    // --- IF Stage Wires ---
    wire [31:0] pc_current;
    wire [31:0] pc_plus4;
    wire [31:0] pc_next;
    wire [31:0] instruction;
    wire [31:0] ifid_pc;
    wire [31:0] ifid_instr;
    wire        pc_write_int;
    wire        ifid_write_int;
    wire        branch_flush;

    // --- ID Stage Wires ---
    wire [31:0] ex_pc;
    wire [31:0] ex_rd1;
    wire [31:0] ex_rd2;
    wire [31:0] ex_imm;
    wire [4:0]  ex_rs;
    wire [4:0]  ex_rt;
    wire [4:0]  ex_rd;
    wire [5:0]  ex_funct;
    wire        ex_reg_dst;
    wire        ex_alu_src;
    wire [1:0]  ex_alu_op;
    wire        ex_mem_read;
    wire        ex_mem_write;
    wire        ex_branch;
    wire        ex_reg_write;
    wire        ex_mem_to_reg;
    wire        ex_branch_taken;
    wire [31:0] ex_branch_target;

    // --- EX Stage Wires ---
    wire [31:0] mem_alu_result;
    wire [31:0] mem_write_data;
    wire [4:0]  mem_write_reg;
    wire        mem_read_out;
    wire        mem_write_out;
    wire        reg_write_out;
    wire        mem_to_reg_out;

    // --- MEM & WB Stage Wires ---
    wire        wb_reg_write;
    wire        wb_mem_to_reg;
    wire [31:0] wb_read_data;
    wire [31:0] wb_alu_result;
    wire [4:0]  wb_write_reg;
    
    // --- Final Write-Back (Feedback) Wires ---
    wire        wb_reg_write_final;
    wire [4:0]  wb_write_reg_final;
    wire [31:0] wb_write_data_final;


    // =========================================================================
    // Core Logic & Combinatorial Assignments
    // =========================================================================

    assign branch_flush  = ex_branch_taken;
    assign pc_plus4      = pc_current + 32'd4;
    assign pc_next       = ex_branch_taken ? ex_branch_target : pc_plus4;

    assign debug_pc      = pc_current;
    assign debug_instr   = ifid_instr;
    assign debug_wb_data = wb_write_data_final;
    assign debug_wb_reg  = wb_write_reg_final;

    assign mem_read  = mem_read_out;
    assign mem_write = mem_write_out;
    // =========================================================================
    // Module Instantiations
    // =========================================================================

    // -------------------------------------------------------------------------
    // Instruction Fetch (IF) Stage
    // -------------------------------------------------------------------------
    pc PC (
        .clk        (clk),
        .rst        (rst),
        .pc_write   (pc_write_int),
        .next_pc    (pc_next[31:2]),  
        .pc         (pc_current)
    );

    instruction_memory IM (
        .addr       (pc_current[9:2]), 
        .instruction(instruction)
    );

    if_id IF_ID (
        .clk        (clk),
        .rst        (rst),
        .flush      (branch_flush),
        .ifid_write (ifid_write_int),
        .pc_in      (pc_plus4[31:2]),  
        .instr_in   (instruction),
        .pc_out     (ifid_pc),
        .instr_out  (ifid_instr)
    );

    // -------------------------------------------------------------------------
    // Instruction Decode (ID) Stage
    // -------------------------------------------------------------------------
    id_stage_top ID_STAGE (
        .clk            (clk),
        .rst            (rst),
        .instruction    (ifid_instr),
        .pc_in          (ifid_pc[31:2]),
        .pc_write       (pc_write_int),
        .ifid_write     (ifid_write_int),
        
        // Write-Back Feedback
        .wb_reg_write   (wb_reg_write_final),
        .wb_write_reg   (wb_write_reg_final),
        .wb_write_data  (wb_write_data_final),
        .branch_flush   (ex_branch_taken),
        
        // Outputs to EX
        .ex_pc          (ex_pc),
        .ex_rd1         (ex_rd1),
        .ex_rd2         (ex_rd2),
        .ex_imm         (ex_imm),
        .ex_rs          (ex_rs),
        .ex_rt          (ex_rt),
        .ex_rd          (ex_rd),
        .ex_funct       (ex_funct),
        .ex_reg_dst     (ex_reg_dst),
        .ex_alu_src     (ex_alu_src),
        .ex_alu_op      (ex_alu_op),
        .ex_mem_read    (ex_mem_read),
        .ex_mem_write   (ex_mem_write),
        .ex_branch      (ex_branch),
        .ex_reg_write   (ex_reg_write),
        .ex_mem_to_reg  (ex_mem_to_reg)
    );

    // -------------------------------------------------------------------------
    // Execution (EX) Stage
    // -------------------------------------------------------------------------
    ex_stage_top EX_STAGE (
        .clk              (clk),
        .rst              (rst),
        
        // Inputs from ID
        .pc_in            (ex_pc),
        .rd1_in           (ex_rd1),
        .rd2_in           (ex_rd2),
        .imm_in           (ex_imm),
        .rs_in            (ex_rs),
        .rt_in            (ex_rt),
        .rd_in            (ex_rd),
        .funct            (ex_funct),
        
        // Control Signals
        .reg_dst          (ex_reg_dst),
        .alu_src          (ex_alu_src),
        .alu_op           (ex_alu_op),
        .mem_read         (ex_mem_read),
        .mem_write        (ex_mem_write),
        .branch           (ex_branch),
        .reg_write        (ex_reg_write),
        .mem_to_reg       (ex_mem_to_reg),
        
        // Forwarding Signals
        .exmem_reg_write  (reg_write_out),
        .exmem_write_reg  (mem_write_reg),
        .exmem_alu_result (mem_alu_result),
        .memwb_reg_write  (wb_reg_write_final),
        .memwb_write_reg  (wb_write_reg_final),
        .memwb_write_data (wb_write_data_final),
        
        // Branching Outputs
        .branch_taken     (ex_branch_taken),
        .branch_target    (ex_branch_target),
        
        // Outputs to MEM
        .mem_alu_result   (mem_alu_result),
        .mem_write_data   (mem_write_data),
        .mem_write_reg    (mem_write_reg),
        .mem_read_out     (mem_read_out),
        .mem_write_out    (mem_write_out),
        .reg_write_out    (reg_write_out),
        .mem_to_reg_out   (mem_to_reg_out)
    );
mem_stage_top MEM_STAGE(

    .clk(clk),
    .rst(rst),

    .mem_read(mem_read_out),
    .mem_write(mem_write_out),

    .reg_write(reg_write_out),
    .mem_to_reg(mem_to_reg_out),

    .alu_result(mem_alu_result),
    .write_data(mem_write_data),
    .write_reg(mem_write_reg),

    .mem_addr(mem_addr),
    .mem_wdata(mem_wdata),
    .mem_rdata(mem_rdata),

    .wb_reg_write(wb_reg_write),
    .wb_mem_to_reg(wb_mem_to_reg),
    .wb_read_data(wb_read_data),
    .wb_alu_result(wb_alu_result),
    .wb_write_reg(wb_write_reg)

);

    // -------------------------------------------------------------------------
    // Write-Back (WB) Stage
    // -------------------------------------------------------------------------
    wb_stage_top WB_STAGE (
        // Inputs from MEM
        .reg_write        (wb_reg_write),
        .mem_to_reg       (wb_mem_to_reg),
        .read_data        (wb_read_data),
        .alu_result       (wb_alu_result),
        .write_reg        (wb_write_reg),
        
        // Final Outputs (Feedback to ID)
        .wb_reg_write     (wb_reg_write_final),
        .wb_data          (wb_write_data_final),
        .wb_write_reg     (wb_write_reg_final)
    );

endmodule