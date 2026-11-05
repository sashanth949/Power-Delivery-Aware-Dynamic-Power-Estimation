`timescale 1ns / 1ps
// Power-benchmark testbench for the N-copy tops (module name tb_bench1).
// SAIF paths: /tb_bench1/dut/*  and  -strip_path tb_bench1/dut
// HALF = half clock period in ns:  10 -> 50 MHz | 5 -> 100 MHz | 2.5 -> 200 MHz
module tb_bench1;
    parameter CYCLES = 50000;
    parameter HALF=2.5;          // CHANGE 1: new parameter
    reg clk = 0, rst = 0;
    wire sig;
    always #(HALF) clk = ~clk;       // CHANGE 2: was  always #5 clk = ~clk;

    // ---- pick ONE of these instances (comment out the others) ----
     //bench_braun_x   #(.N(16), .HOLD(3)) dut (.clk(clk), .rst(rst), .sig(sig));
      // bench_wallace_x #(.N(16), .HOLD(3)) dut (.clk(clk), .rst(rst), .sig(sig));
   // bench_booth_x   #(.N(16))           dut (.clk(clk), .rst(rst), .sig(sig));
    // bench_base_x    #(.N(16), .HOLD(3)) dut (.clk(clk), .rst(rst), .sig(sig));
    // bench_alu_x     #(.N(16))           dut (.clk(clk), .rst(rst), .sig(sig));
    // bench_alubase_x #(.N(16))           dut (.clk(clk), .rst(rst), .sig(sig));
     bench_macw_x    #(.N(16))           dut (.clk(clk), .rst(rst), .sig(sig));

    integer cycles = 0;
    always @(posedge clk) if (rst) cycles <= cycles + 1;

    initial begin
        #50 rst = 1;
        #(2*HALF*CYCLES);            // CHANGE 3: was  #(10 * CYCLES);
        $display("cycles simulated = %0d", cycles);
        $finish;
    end
endmodule
