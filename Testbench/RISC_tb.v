`timescale 1ns / 1ps

module RV32I_tb;

reg clk;
reg rst;
initial
begin
    $display("****************************************");
    $display(" NEW TESTBENCH COMPILED ");
    $display("****************************************");
end

/////////////////////////////////////////////////
// DUT
/////////////////////////////////////////////////
wire [31:0] debug_pc;
wire [31:0] debug_wb;

RV32I_CORE DUT(
    .clk(clk),
    .rst(rst),
    .debug_pc(debug_pc),
    .debug_wb(debug_wb)
);

/////////////////////////////////////////////////
// CLOCK GENERATION
/////////////////////////////////////////////////

initial
begin
    clk = 1'b0;
    forever #5 clk = ~clk;   // 10 ns clock period
end
// RESET
/////////////////////////////////////////////////

initial
begin
    rst = 1'b1;

    #20;
    rst = 1'b0;
end
// PROGRAM LOAD
/////////////////////////////////////////////////
integer i;
initial
begin
    for(i=0;i<256;i=i+1)
        DUT.FETCH.IMEM.memory[i] = 32'h00000013; // NOP

    DUT.FETCH.IMEM.memory[0] = 32'h00500093;
    DUT.FETCH.IMEM.memory[1] = 32'h00A00113;
    DUT.FETCH.IMEM.memory[2] = 32'h002081B3;
    DUT.FETCH.IMEM.memory[3] = 32'h40118233;
    DUT.FETCH.IMEM.memory[4] = 32'h0020F2B3;
    DUT.FETCH.IMEM.memory[5] = 32'h0020E333;
    DUT.FETCH.IMEM.memory[6] = 32'h0020C3B3;
end
// WAVEFORM SIGNALS
/////////////////////////////////////////////////

initial
begin
    $dumpfile("RV32I_Core.vcd");
    $dumpvars(0, RV32I_tb);
end
// MONITOR PIPELINE
/////////////////////////////////////////////////

initial
begin

    $monitor(
    "T=%0t | PC=%h | IF_Inst=%h | ID_Inst=%h | EX_ALU=%h | MEM_ALU=%h | WB=%h",
    $time,
    DUT.pc_if,
    DUT.instruction_if,
    DUT.instruction_id,
    DUT.alu_result_ex,
    DUT.alu_result_mem,
    DUT.write_back_data
    );

end
// END SIMULATION
/////////////////////////////////////////////////

initial
begin

    $display("Simulation Started");

    #300;

    $display("");
    $display("=================================");
    $display("FINAL REGISTER DUMP");
    $display("=================================");
	     $display("x0 = %0d", DUT.DECODE.RF.regfile[0]);
    $display("x1 = %0d", DUT.DECODE.RF.regfile[1]);
    $display("x2 = %0d", DUT.DECODE.RF.regfile[2]);
    $display("x3 = %0d", DUT.DECODE.RF.regfile[3]);
    $display("x4 = %0d", DUT.DECODE.RF.regfile[4]);
    $display("x5 = %0d", DUT.DECODE.RF.regfile[5]);
    $display("x6 = %0d", DUT.DECODE.RF.regfile[6]);
    $display("x7 = %0d", DUT.DECODE.RF.regfile[7]);
    $display("");
    $display("Expected:");
    $display("x1 = 5");
    $display("x2 = 10");
    $display("x3 = 15");
    $display("x4 = 10");
    $display("x5 = 0");
    $display("x6 = 15");
    $display("x7 = 15");

    $display("");
    $display("Simulation Finished @ %0t ns", $time);

    $finish;

end
always @(posedge clk)
begin
    $display(
    "PC=%h IF=%h ID=%h EX=%h WB=%h",
    DUT.pc_if,
    DUT.instruction_if,
    DUT.instruction_id,
    DUT.alu_result_ex,
    DUT.write_back_data
    );
end



endmodule