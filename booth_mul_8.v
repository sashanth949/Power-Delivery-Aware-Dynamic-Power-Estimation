module booth_mul_8(
input clk,
input rst,
input start,
input signed[7:0]x,
input signed[7:0]y,
output reg signed[15:0]z,
output reg busy,
output reg done
    );
reg signed[7:0]acc;
reg [7:0]multiplier;
reg E1;
reg signed[8:0]m;
reg[3:0]count;
reg signed[8:0]a_temp;
reg signed[17:0]combined;
always@(posedge clk or negedge rst)begin
if (!rst) begin
acc<= 9'sd0;
multiplier<= 8'd0;
E1<= 1'b0;
m<= 9'sd0;
count<= 4'd0;
z<= 16'sd0;
busy<= 1'b0;
done<= 1'b0;
end else begin
done<=1'b0;
if(start&&!busy)begin
acc<= 9'sd0;
multiplier<= y;
E1<= 1'b0;
m<= {x[7], x};   // sign-extend multiplicand
count<= 4'd0;
busy<= 1'b1;
end
else if (busy) begin
                // 1. Examine the two bits (Q0, E1)
a_temp = acc;
case ({multiplier[0], E1})
2'b01: a_temp = acc + m;   // +M
2'b10: a_temp = acc - m;   // -M
default: a_temp = acc;     // 00 or 11 → do nothing
endcase
                // 2. Arithmetic right shift of {A, Q, E1}
combined = {a_temp, multiplier, E1};
combined = combined >>> 1;     // arithmetic shift
                // 3. Update registers
acc<= combined[17:9];  // new A (9 bits)
multiplier<= combined[8:1];   // new Q (8 bits)
E1<= combined[0];     // new E1

                // 4. Check if finished (8 iterations: count = 0..7)
if (count == 4'd7) begin
                    // Final 16-bit product = {A[7:0], Q}
z<={combined[16:9],combined[8:1]};
busy <= 1'b0;
done <= 1'b1;
end else begin
count <= count + 1'b1;
end
end
end
end
endmodule
