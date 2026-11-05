module tb_b1;
reg  [3:0] a, b;
reg        clk;
wire [7:0] p;
    // DUT
b_m uut (
.p  (p),
.a  (a),
.b  (b),
.clk(clk)
    );
    // 100 MHz clock
always #5 clk = ~clk;
integer i, j;
integer errors = 0;
reg [7:0] expected;
initial begin
$timeformat(-9, 0, " ns", 10);
clk = 0;
a   = 0;
b   = 0;
        // Wait for any internal reset / power-up
#110;
@(negedge clk);
$display("=================================================");
$display(" Starting exhaustive 4x4 Braun multiplier test");
$display("=================================================");
for (i = 0; i < 16; i = i + 1) begin
for (j = 0; j < 16; j = j + 1) begin
                // Apply new inputs on negedge (safe)
@(negedge clk);
a = i;
b = j;
                // Wait 2 clock cycles for the registered output
repeat (2) @(posedge clk)
#1;                         // small delay so we sample after the FF updates
expected = i * j;
if (p !== expected) begin
$display("FAIL  @ %0t  |  %2d x %2d  got %3d  expected %3d",$time, i, j, p, expected);
errors = errors + 1;
end
else $display("PASS  @ %0t  |  %2d x %2d = %3d", $time, i, j, p);
end
end
$display("=================================================");
if (errors == 0)
$display(" SUCCESS: All 256 cases passed!");
else
$display(" FAILED : %0d errors found", errors);
$display("=================================================");
#20 $finish;
end
endmodule
