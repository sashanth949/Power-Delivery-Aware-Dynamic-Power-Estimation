`timescale 1ns / 1ps
// N-copy power benchmark for YOUR mac_unit (Wallace multiplier + accumulator).
// Needs lfsr32s and opgen_s from bench_top_x.v, and mac_unit/w_m8/w_m (rst_n versions).
// Same generator structure as cell_braun/cell_wallace, so the existing baseline
// bench_base_x (core 0.010 W) removes the generators. Reset pin rst drives rst_n.
module cell_macw #(parameter [31:0] SEED = 32'hACE1_2345) (
    input clk, input rst, output reg sig);
    wire [7:0] a, b; wire [15:0] product; wire [23:0] acc;
    opgen_s #(.HOLD(0), .SEED(SEED)) u_g (.clk(clk), .rst(rst), .a(a), .b(b));
    mac_unit dut (.clk(clk), .rst_n(rst), .a(a), .b(b), .product(product), .accum_out(acc));
    always @(posedge clk) sig <= (^acc) ^ (^product);
endmodule

module bench_macw_x #(parameter N = 16) (input clk, input rst, output reg sig);
    wire [N-1:0] s;
    genvar i;
    generate for (i = 0; i < N; i = i + 1) begin : g
        cell_macw #(.SEED(32'hACE1_2345 + i*32'h1357_9BDF))
            c (.clk(clk), .rst(rst), .sig(s[i]));
    end endgenerate
    always @(posedge clk) sig <= ^s;
endmodule
