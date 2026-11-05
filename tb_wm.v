module tb_wm;
reg[3:0]a;
reg[3:0]b;
reg clk;
wire[7:0]p;
w_m uut(
.p(p),
.a(a),
.b(b),
.clk(clk)
);
always #5 clk=~clk;
initial begin
clk=0;
a=0;
b=0;
// WAIT for the FPGA's internal reset to release
#110; 
@(negedge clk);
a=4'd10; b=4'd13;
repeat(2) @(posedge clk);
 #1;
$display("Time=%0t | 10 x 13 = %0d", $time, p);
@(negedge clk);
a=4'd7; b=4'd5;
repeat(2) @(posedge clk);
#1;
$display("Time=%0t | 7 x 5 = %0d", $time, p);
@(negedge clk);
a=4'd15;b=4'd15;
repeat(2) @(posedge clk);
 #1;
 $display("Time=%0t | 15 x 15 = %0d", $time, p);
@(negedge clk);
a=4'd8;b=4'd8;
repeat(2) @(posedge clk);
 #1;
$display("Time=%0t | 8 x 8 = %0d", $time, p);
@(negedge clk);
a=4'd1;b=4'd15;
repeat(2) @(posedge clk);
 #1;
$display("Time=%0t | 1 x 15 = %0d", $time, p);
@(negedge clk)
a=4'd2;b=4'd13;
repeat(2) @(posedge clk);
 #1;
$display("Time=%0t | 2 x 13 = %0d", $time, p);
@(negedge clk);
a=4'd5;b=4'd4;
repeat(2) @(posedge clk);
 #1;
$display("Time=%0t | 5 x 4 = %0d", $time, p);
#20 $stop;
end
endmodule
