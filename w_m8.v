module w_m8(p,a,b,clk,rst_n);
output reg[15:0]p;
input[7:0]a,b;
input clk;
input rst_n;
reg[7:0]a_r,b_r;
always@(posedge clk or negedge rst_n)begin
if(!rst_n)begin
a_r<=8'b0;
b_r<=8'b0;
end else begin
a_r<=a;
b_r<=b;
end
end
wire[7:0]pp0,pp1,pp2,pp3;
w_m p0(.p(pp0),.a(a_r[3:0]),.b(b_r[3:0]),.clk(clk),.rst_n(rst_n));
w_m p1(.p(pp1),.a(a_r[3:0]),.b(b_r[7:4]),.clk(clk),.rst_n(rst_n));
w_m p2(.p(pp2),.a(a_r[7:4]),.b(b_r[3:0]),.clk(clk),.rst_n(rst_n));
w_m p3(.p(pp3),.a(a_r[7:4]),.b(b_r[7:4]),.clk(clk),.rst_n(rst_n));
wire [15:0] p_next = {pp3, 8'b0}          // A_H*B_H << 8
                      + {4'b0, pp1, 4'b0}    // A_L*B_H << 4
                       + {4'b0, pp2, 4'b0}    // A_H*B_L << 4
                       + {8'b0, pp0};         // A_L*B_L
always@(posedge clk or negedge rst_n)begin
if(!rst_n)begin
p<=16'b0;
end else begin
p<=p_next;
end
end
endmodule
