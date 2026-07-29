`timescale 1ns / 1ps

module cpu_top_tb;

reg clk;
reg rst;

cpu_top DUT(
    .clk(clk),
    .rst(rst)
);

/////////////////////////////////////////////////
// Clock
/////////////////////////////////////////////////

always #5 clk = ~clk;

/////////////////////////////////////////////////
// Reset
/////////////////////////////////////////////////

initial begin
    clk = 0;
    rst = 1;

    #20 rst = 0;

    #300;

    $display("\n--------------------------------");
    $display("FINAL RESULTS");
    $display("--------------------------------");

    $display("R1 = %d", DUT.ID_STAGE.RF.regs[1]);
    $display("R2 = %d", DUT.ID_STAGE.RF.regs[2]);
    $display("R3 = %d", DUT.ID_STAGE.RF.regs[3]);
    $display("R4 = %d", DUT.ID_STAGE.RF.regs[4]);
    $display("R5 = %d", DUT.ID_STAGE.RF.regs[5]);

    $display("MEM[0] = %d", DUT.MEM_STAGE.DM.memory[0]);
    $display("MEM[1] = %d", DUT.MEM_STAGE.DM.memory[1]);

    $finish;
end

/////////////////////////////////////////////////
// Compact Execution Trace
/////////////////////////////////////////////////

always @(posedge clk)
begin
    $display(
      "T=%0t PC=%h INSTR=%h R1=%d R2=%d R3=%d",
      $time,
      DUT.pc_current,
      DUT.ifid_instr,
      DUT.ID_STAGE.RF.regs[1],
      DUT.ID_STAGE.RF.regs[2],
      DUT.ID_STAGE.RF.regs[3]
    );
end

endmodule