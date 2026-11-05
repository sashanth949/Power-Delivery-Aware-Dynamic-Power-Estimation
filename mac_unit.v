module mac_unit(
    input clk,
    input rst_n,
    input [7:0] a,
    input [7:0] b,
    output[15:0] product,
    output reg [23:0] accum_out
);

    // 1. Multiplier Instantiatio
    w_m8 multiplier_inst(
        .p(product),
        .a(a),
        .b(b),
        .clk(clk),
        .rst_n(rst_n)
    );

    // 2. 24-bit CSA Signals
    // A CSA adds 3 operands: current accumulator, zero-extended product, and zero (or carry-in)
    wire [23:0] csa_sum;
    wire [23:0] csa_cout;
    
    // Behavioral or instantiated 24-bit CSA logic
    // sum = A ^ B ^ C
    // cout = (A & B) | (B & C) | (C & A)
    wire [23:0] ext_product = {8'b0, product};
    
    assign csa_sum  = accum_out ^ ext_product ^ 24'b0;
    assign csa_cout = (accum_out & ext_product) | (ext_product & 24'b0) | (24'b0 & accum_out);

    // 3. Final Carry-Propagate Adder (RCA / CPA) to combine Sum and Carry
    wire [23:0] next_accum;
    assign next_accum = csa_sum + (csa_cout << 1);

    // 4. Accumulator Register with Synchronous/Asynchronous Reset
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            accum_out <= 24'b0;
        end else begin
            accum_out <= next_accum;
        end
    end

endmodule
