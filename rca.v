module rca(sum,c,a,b,cin);
output[8:0]sum;
output c;
input[8:0]a,b;
input cin;
wire[8:1]carry;
fa fa1(sum[0],carry[1],a[0],b[0],cin);
fa fa2(sum[1],carry[2],a[1],b[1],carry[1]);
fa fa3(sum[2],carry[3],a[2],b[2],carry[2]);
fa fa4(sum[3],carry[4],a[3],b[3],carry[3]);
fa fa5(sum[4],carry[5],a[4],b[4],carry[4]);
fa fa6(sum[5],carry[6],a[5],b[5],carry[5]);
fa fa7(sum[6],carry[7],a[6],b[6],carry[6]);
fa fa8(sum[7],carry[8],a[7],b[7],carry[7]);
fa fa9(sum[8],c,a[8],b[8],carry[8]);
endmodule
