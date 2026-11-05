module csa(
output[9:0]s,
output cout,
input[7:0]a,
input[7:0]b,
input[7:0]c);
wire[7:0]sum,carry;
fa fa1(sum[0],carry[0],a[0],b[0],c[0]);
fa fa2(sum[1],carry[1],a[1],b[1],c[1]);
fa fa3(sum[2],carry[2],a[2],b[2],c[2]);
fa fa4(sum[3],carry[3],a[3],b[3],c[3]);
fa fa5(sum[4],carry[4],a[4],b[4],c[4]);
fa fa6(sum[5],carry[5],a[5],b[5],c[5]);
fa fa7(sum[6],carry[6],a[6],b[6],c[6]);
fa fa8(sum[7],carry[7],a[7],b[7],c[7]);
rca rca1(
.sum(s[8:0]),
.c(s[9]),
.a({1'b0,sum}),
.b({carry,1'b0}),
.cin(1'b0));
assign cout=s[9];
endmodule
