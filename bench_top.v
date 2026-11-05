`timescale 1ns / 1ps
//==============================================================================
// Power-benchmark tops, N-COPY version (new module names, so this file can sit
// beside bench_top.v without duplicate-module errors; use only ONE of the two
// as the design top at a time).
//
// Why: Vivado rounds every power line to 1 mW. One multiplier is only a few mW,
// so Braun / Wallace / Booth cannot be told apart. Here N independent copies
// (each with its own LFSR seed, so activity is not identical) run together.
// Measured core dynamic power is divided by N afterwards. The baseline has the
// same N generators and no multipliers, so the subtraction removes them.
//
// Pins: clk, rst, sig only (all N outputs are XOR-reduced into one flop).
// NOT simulated in the authoring environment: check it in your own behavioral
// simulation (sig must toggle) before using any number from it.
//==============================================================================

module lfsr32s #(parameter [31:0] SEED = 32'hACE1_2345) (
    input clk, input rst, output reg [31:0] q);
    always @(posedge clk or negedge rst) begin
        if (!rst) q <= SEED;
        else      q <= {q[30:0], q[31] ^ q[21] ^ q[1] ^ q[0]};
    end
endmodule

module opgen_s #(parameter HOLD = 0, parameter [31:0] SEED = 32'hACE1_2345) (
    input clk, input rst, output reg [7:0] a, output reg [7:0] b);
    wire [31:0] q;
    lfsr32s #(.SEED(SEED)) u_l (.clk(clk), .rst(rst), .q(q));
    reg [7:0] cnt;
    always @(posedge clk or negedge rst) begin
        if (!rst) begin cnt <= 8'd0; a <= 8'd0; b <= 8'd0; end
        else if (cnt == HOLD) begin cnt <= 8'd0; a <= q[7:0]; b <= q[23:16]; end
        else cnt <= cnt + 8'd1;
    end
endmodule

//---------------------------- one copy of each design -------------------------
module cell_braun #(parameter HOLD = 0, parameter [31:0] SEED = 32'hACE1_2345) (
    input clk, input rst, output reg sig);
    wire [7:0] a, b; wire [15:0] p;
    opgen_s #(.HOLD(HOLD), .SEED(SEED)) u_g (.clk(clk), .rst(rst), .a(a), .b(b));
    b_m8 dut (.p(p), .a(a), .b(b), .clk(clk));
    always @(posedge clk) sig <= ^p;
endmodule

module cell_wallace #(parameter HOLD = 0, parameter [31:0] SEED = 32'hACE1_2345) (
    input clk, input rst, output reg sig);
    wire [7:0] a, b; wire [15:0] p;
    opgen_s #(.HOLD(HOLD), .SEED(SEED)) u_g (.clk(clk), .rst(rst), .a(a), .b(b));
    w_m8 dut (.p(p), .a(a), .b(b), .clk(clk),.rst_n(rst));
    always @(posedge clk) sig <= ^p;
endmodule

module cell_booth #(parameter [31:0] SEED = 32'hACE1_2345) (
    input clk, input rst, output reg sig);
    wire [31:0] q;
    lfsr32s #(.SEED(SEED)) u_l (.clk(clk), .rst(rst), .q(q));
    reg signed [7:0] x, y;
    reg start;
    wire busy, done;
    wire signed [15:0] z;
    booth_mul_8 dut (.clk(clk), .rst(rst), .start(start),
                     .x(x), .y(y), .z(z), .busy(busy), .done(done));
    always @(posedge clk or negedge rst) begin
        if (!rst) begin x <= 8'sd0; y <= 8'sd0; start <= 1'b0; end
        else begin
            start <= 1'b0;
            if (!busy && !start) begin
                x <= q[7:0]; y <= q[23:16]; start <= 1'b1;
            end
        end
    end
    always @(posedge clk) sig <= ^z;
endmodule

module cell_base #(parameter HOLD = 0, parameter [31:0] SEED = 32'hACE1_2345) (
    input clk, input rst, output reg sig);
    wire [7:0] a, b;
    opgen_s #(.HOLD(HOLD), .SEED(SEED)) u_g (.clk(clk), .rst(rst), .a(a), .b(b));
    always @(posedge clk) sig <= ^{a, b};
endmodule

//------------------------------- N-copy tops ---------------------------------
// Seed of copy i = ACE12345 + i*13579BDF (all non-zero and distinct for N<=32).
module bench_braun_x #(parameter N = 16, parameter HOLD = 3) (
    input clk, input rst, output reg sig);
    wire [N-1:0] s;
    genvar i;
    generate for (i = 0; i < N; i = i + 1) begin : g
        cell_braun #(.HOLD(HOLD), .SEED(32'hACE1_2345 + i*32'h1357_9BDF))
            c (.clk(clk), .rst(rst), .sig(s[i]));
    end endgenerate
    always @(posedge clk) sig <= ^s;
endmodule

module bench_wallace_x #(parameter N = 16, parameter HOLD = 3) (
    input clk, input rst, output reg sig);
    wire [N-1:0] s;
    genvar i;
    generate for (i = 0; i < N; i = i + 1) begin : g
        cell_wallace #(.HOLD(HOLD), .SEED(32'hACE1_2345 + i*32'h1357_9BDF))
            c (.clk(clk), .rst(rst), .sig(s[i]));
    end endgenerate
    always @(posedge clk) sig <= ^s;
endmodule

module bench_booth_x #(parameter N = 16) (
    input clk, input rst, output reg sig);
    wire [N-1:0] s;
    genvar i;
    generate for (i = 0; i < N; i = i + 1) begin : g
        cell_booth #(.SEED(32'hACE1_2345 + i*32'h1357_9BDF))
            c (.clk(clk), .rst(rst), .sig(s[i]));
    end endgenerate
    always @(posedge clk) sig <= ^s;
endmodule

module bench_base_x #(parameter N = 16, parameter HOLD = 3) (
    input clk, input rst, output reg sig);
    wire [N-1:0] s;
    genvar i;
    generate for (i = 0; i < N; i = i + 1) begin : g
        cell_base #(.HOLD(HOLD), .SEED(32'hACE1_2345 + i*32'h1357_9BDF))
            c (.clk(clk), .rst(rst), .sig(s[i]));
    end endgenerate
    always @(posedge clk) sig <= ^s;
endmodule
