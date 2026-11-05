module tb_wm8;
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
.rst_n(rst_n));
always #5 clk = ~clk;   // 100 MHz
initial begin
$timeformat(-9, 0, " ns", 10);
clk=0;
rst_n=0;
a=0;
b=0;
#25;
rst_n = 1;
// Let the pipeline fill with zeros
repeat(5) @(posedge clk);
// -------- Test 1: 5 × 3 = 15 --------
@(negedge clk);
a=8'd5;
b=8'd3;
repeat(4) @(posedge clk);   // ← changed to 4
#1;
$display("Time=%0t | 5 x 3 = %0d (expected 15)", $time, p);
        // -------- Test 2: 100 × 50 = 5000 --------
@(negedge clk);
a=8'd100;
b=8'd50;
repeat(4) @(posedge clk);
#1;
$display("Time=%0t | 100 x 50 = %0d (expected 5000)", $time, p);
        // -------- Test 3: 255 × 255 = 65025 --------
@(negedge clk);
a = 8'hFF;
b = 8'hFF;
repeat(4) @(posedge clk);
#1;
$display("Time=%0t | 255 x 255 = %0d (expected 65025)", $time, p);
#30;
$stop;
end
endmodule
