//==============================================================================
// Output-register wrapper for the ALU (which already registers its own inputs),
// used ONLY for LUT/FF counts and a register-to-register Fmax:
//   input regs (inside alu) -> alu logic -> output regs (here).
// Requires alu.v (the version with clk and input registers) and mux_2.
//==============================================================================
module alu_reg (
    input         clk,
    input  [7:0]  a_in,
    input  [7:0]  b_in,
    input         c_in,
    input  [3:0]  op_code,
    output reg [15:0] result_out,
    output reg        c_out
);
    wire [15:0] res;
    wire        co;
    alu u_alu (.result_out(res), .c_out(co), .a_in(a_in), .b_in(b_in),
               .c_in(c_in), .op_code(op_code), .clk(clk));
    always @(posedge clk) begin
        result_out <= res;
        c_out      <= co;
    end
endmodule
