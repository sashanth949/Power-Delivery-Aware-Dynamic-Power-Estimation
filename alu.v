module alu(
output[15:0]result_out,
output reg c_out,
input[7:0]a_in,
input[7:0]b_in,
input c_in,
input[3:0]op_code,
input clk);
reg[7:0]a_r;
reg[7:0]b_r;
reg cin_r;
reg[3:0]opcode_r;
reg[15:0]result_out_a;
reg[15:0]result_out_b;
always@(posedge clk)begin
a_r<=a_in;
b_r<=b_in;
cin_r<=c_in;
opcode_r<=op_code;
end
always @(*)begin
c_out=1'b0;
result_out_a=16'b0;
result_out_b=16'b0;
if(opcode_r[3]==1'b0)begin
result_out_b=16'b0;
case(opcode_r[2:0])
3'b000:begin
result_out_a = {{8{a_r[7]}}, a_r};
end
3'b001:begin
{c_out, result_out_a[7:0]} = a_r + b_r + cin_r;
result_out_a[15:8] = {8{result_out_a[7]}}; 
end
3'b010:begin
{c_out, result_out_a[7:0]} = a_r - b_r - cin_r;
result_out_a[15:8] = {8{result_out_a[7]}};
end
3'b011:begin
{c_out, result_out_a[7:0]} = a_r + 1;
result_out_a[15:8] = {8{result_out_a[7]}};
end
3'b100:begin
{c_out, result_out_a[7:0]} = b_r + 1;
result_out_a[15:8] = {8{result_out_a[7]}};
end
default:begin
result_out_a = 16'b0;
end
endcase
end else begin
result_out_a=16'b0;
case(opcode_r[2:0])
3'b000:begin
result_out_b = {8'b0, a_r ^ b_r};
end
3'b001:begin
result_out_b = {8'b0, a_r & b_r};
end
3'b010:begin
result_out_b = {8'b0, a_r | b_r};
end
3'b011:begin
result_out_b = {8'b0, ~a_r};
end
3'b100:begin
result_out_b = {8'b0, ~b_r};
end
3'b101:begin
result_out_b = {8'b0, a_r} << b_r[2:0];
end
3'b110:begin
result_out_b = {8'b0, a_r} >> b_r[2:0];
end
default:begin
result_out_b = 16'b0;
end
endcase
end
end
mux_2 m1(.y(result_out),.i1(result_out_b),.i0(result_out_a),.s(opcode_r[3]));
endmodule 
