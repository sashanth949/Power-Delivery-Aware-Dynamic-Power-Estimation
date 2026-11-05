module mux_2(y,i1,i0,s);
output[15:0]y;
input[15:0]i0,i1;
input s;
assign y=s?i1:i0;
endmodule
