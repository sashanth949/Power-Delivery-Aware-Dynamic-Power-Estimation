`timescale 1ns / 1ps
//==============================================================================
// N-copy power benchmark for the ALU (same method as bench_top_x.v).
// Needs lfsr32s from bench_top_x.v (keep that file in Design Sources) and alu.v.
// Each cell: LFSR -> input regs (a, b, c_in, op_code, a NEW random op every
// clock, so activity is averaged over all 16 op codes) -> alu -> output regs.
// Baseline cell: identical LFSR, registers and a second register stage (the alu's input
// registers), NO alu logic (output regs just load
// {a,b} and a parity bit), so the subtraction removes the common overhead.
// Only clk, rst and 'sig' are pins. NOT simulated in the authoring environment.
//==============================================================================
module cell_alu #(parameter [31:0] SEED = 32'hACE1_2345) (
    input clk, input rst, output reg sig);
    wire [31:0] q;
    lfsr32s #(.SEED(SEED)) u_l (.clk(clk), .rst(rst), .q(q));
    reg [7:0] a, b;
    reg       c;
    reg [3:0] op;
    always @(posedge clk or negedge rst) begin
        if (!rst) begin a <= 8'd0; b <= 8'd0; c <= 1'b0; op <= 4'd0; end
        else begin a <= q[7:0]; b <= q[23:16]; c <= q[8]; op <= q[31:28]; end
    end
    wire [15:0] res;
    wire        co;
    alu dut (.result_out(res), .c_out(co), .a_in(a), .b_in(b), .c_in(c), .op_code(op), .clk(clk));
    reg [15:0] r_res;
    reg        r_co;
    always @(posedge clk) begin r_res <= res; r_co <= co; end
    always @(posedge clk) sig <= (^r_res) ^ r_co;
endmodule

module cell_alubase #(parameter [31:0] SEED = 32'hACE1_2345) (
    input clk, input rst, output reg sig);
    wire [31:0] q;
    lfsr32s #(.SEED(SEED)) u_l (.clk(clk), .rst(rst), .q(q));
    reg [7:0] a, b;
    reg       c;
    reg [3:0] op;
    always @(posedge clk or negedge rst) begin
        if (!rst) begin a <= 8'd0; b <= 8'd0; c <= 1'b0; op <= 4'd0; end
        else begin a <= q[7:0]; b <= q[23:16]; c <= q[8]; op <= q[31:28]; end
    end
    // second register stage = the alu's own 21 input registers, so the subtraction removes them
    reg [7:0] a2, b2; reg c2; reg [3:0] op2;
    always @(posedge clk) begin a2 <= a; b2 <= b; c2 <= c; op2 <= op; end
    reg [15:0] r_res;
    reg        r_co;
    always @(posedge clk) begin r_res <= {a2, b2}; r_co <= c2 ^ (^op2); end
    always @(posedge clk) sig <= (^r_res) ^ r_co;
endmodule

module bench_alu_x #(parameter N = 16) (input clk, input rst, output reg sig);
    wire [N-1:0] s;
    genvar i;
    generate for (i = 0; i < N; i = i + 1) begin : g
        cell_alu #(.SEED(32'hACE1_2345 + i*32'h1357_9BDF))
            c (.clk(clk), .rst(rst), .sig(s[i]));
    end endgenerate
    always @(posedge clk) sig <= ^s;
endmodule

module bench_alubase_x #(parameter N = 16) (input clk, input rst, output reg sig);
    wire [N-1:0] s;
    genvar i;
    generate for (i = 0; i < N; i = i + 1) begin : g
        cell_alubase #(.SEED(32'hACE1_2345 + i*32'h1357_9BDF))
            c (.clk(clk), .rst(rst), .sig(s[i]));
    end endgenerate
    always @(posedge clk) sig <= ^s;
endmodule
