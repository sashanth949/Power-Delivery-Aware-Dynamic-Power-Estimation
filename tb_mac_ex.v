module tb_mac_ex;
    reg clk = 0, rst_n = 0;
    reg [7:0] a = 0, b = 0;
    wire [15:0] product;
    wire [23:0] accum_out;
    always #5 clk = ~clk;
    mac_unit uut (.clk(clk), .rst_n(rst_n), .a(a), .b(b), .product(product), .accum_out(accum_out));

    integer t, i, N, errors = 0, perr = 0;
    reg [23:0] ref_sum;
    // product-port check: product must equal a*b of 4 clocks earlier
    reg [15:0] e0, e1, e2, e3;
    always @(posedge clk) begin e0 <= a * b; e1 <= e0; e2 <= e1; e3 <= e2; end
    reg chk = 0;
    always @(negedge clk) if (chk && product !== e3) begin
        perr = perr + 1;
        if (perr <= 5) $display("PRODUCT MISMATCH t=%0t product=%h expected=%h", $time, product, e3);
    end

    initial begin
        for (t = 0; t < 300; t = t + 1) begin
            chk = 0; a = 0; b = 0; rst_n = 0;
            repeat (3) @(negedge clk);
            rst_n = 1;
            repeat (12) @(negedge clk);          // pipeline holds zeros
            ref_sum = 24'd0; chk = 1;
            N = (t == 0) ? 300 : (t < 4) ? 1 : (t < 8) ? 2 : 1 + ($urandom % 150);
            for (i = 0; i < N; i = i + 1) begin
                if (t == 0)      begin a = 8'hFF; b = 8'hFF; end
                else if (t == 1) begin a = 8'h00; b = 8'hFF; end
                else if (t == 2) begin a = 8'h01; b = 8'h01; end
                else             begin a = $urandom; b = $urandom; end
                ref_sum = ref_sum + a * b;
                @(negedge clk);
            end
            a = 0; b = 0;
            repeat (12) @(negedge clk);          // drain
            if (accum_out !== ref_sum) begin
                errors = errors + 1;
                if (errors <= 10) $display("FAIL trial %0d N=%0d accum=%h expected=%h", t, N, accum_out, ref_sum);
            end
        end
        $display("======================================");
        $display(" MAC: 300 trials, %0d accumulator errors, %0d product-port errors", errors, perr);
        if (errors == 0 && perr == 0) $display(" MAC TEST PASSED"); else $display(" MAC TEST FAILED");
        $display("======================================");
        $finish;
    end
endmodule
