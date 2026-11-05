module tb_fa;
wire s,cout;
reg a,b,cin;
fa dut(
.s(s),
.cout(cout),
.a(a),
.b(b),
.cin(cin));
initial begin
$timeformat(-9, 0, " ns", 10);
$monitor("Time=%0t |Input: a=%b, b=%b, cin=%b|Output: s=%b, cout=%b  ", $time,a,b,cin,s,cout);
a=0;b=0;cin=0;
#10;
a=0;b=0;cin=1;
#10;
a=0;b=1;cin=0;
#10;
a=0;b=1;cin=1;
#10;
a=1;b=0;cin=0;
#10;
a=1;b=0;cin=1;
#10;
a=1;b=1;cin=0;
#10;
a=1;b=1;cin=1;
#10;
$finish;
end
endmodule
