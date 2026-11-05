module tb_ha;
wire sum,carry;
reg p,q;
ha dut(
.sum(sum),
.carry(carry),
.p(p),
.q(q));
 initial begin
  $timeformat(-9, 0, " ns", 10);
// Monitor changes and print them to the console
$monitor("Time=%0t |Input: p=%b, q=%b|Output: sum=%b, carry=%b  ", $time,p,q,sum, carry);
p=0;q=0;
#10;
p=0;q=1;
#10;
p=1;q=0;
#10;
p=1;q=1;
#10;
$finish;
end
endmodule
