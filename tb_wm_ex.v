module tb_wm_ex;
reg  [7:0] a;
reg  [7:0] b;
reg clk;
reg rst_n;
wire [15:0] p;
w_m8 uut(
.p(p),
.a(a),
.b(b),
.clk(clk),
.rst_n(rst_n)
);
always #5 clk = ~clk;          // 100 MHz
integer i, j;
integer errors = 0;
reg [15:0] expected;
initial begin
$timeformat(-9, 0, " ns", 10);
clk = 0;
rst_n=0;
a   = 0;
b   = 0;
#25;
rst_n = 1;
        // Let the pipeline fill with zeros
repeat(6) @(posedge clk);
$display("=================================================");
$display(" Starting exhaustive 8x8 Wallace multiplier test");
$display("=================================================");
for (i = 0; i < 256; i = i + 1) begin
for (j = 0; j < 256; j = j + 1) begin
                // Apply inputs on negedge (safe)
@(negedge clk);
a = i;
b = j;
                // Wait 4 clocks (3 pipeline stages + 1 for safety)
repeat(4) @(posedge clk);
#1;   // sample after the rising edge has updated the FFs
 expected = i * j;
 if (p !== expected) begin
 $display("FAIL  @ %0t  |  %2d x %2d  got %5d  expected %5d",
 $time, i, j, p, expected);
 errors = errors + 1;
  end
 else begin
 $display("PASS  @ %0t  |  %2d x %2d = %5d", $time, i, j, p);
  end
 end
  end
$display("=================================================");
 if (errors == 0)
 $display(" SUCCESS: All 65536 cases passed!");
 else
 $display(" FAILED : %0d errors found", errors);
 $display("=================================================");
 #20 $finish;
 end
endmodule
