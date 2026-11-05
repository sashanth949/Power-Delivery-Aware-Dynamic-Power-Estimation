module ha(sum,carry,p,q);
output sum,carry;
input p,q;
assign sum=p^q;
assign carry=p&q;
endmodule
