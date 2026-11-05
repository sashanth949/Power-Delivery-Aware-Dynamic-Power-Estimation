module tb_bool_seq;
// Inputs
    reg clk;
    reg rst_n;
    reg start;
    reg signed [3:0] x;
    reg signed [3:0] y;

    // Outputs
    wire signed [7:0] z;
    wire busy;
    wire done;

    // Expected output
    reg signed [7:0] expected;

    integer i;
    integer j;
    integer errors;
    integer total_tests;
    integer timeout_count;

    // Instantiate sequential Booth multiplier
    booth_mul_seq uut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .x(x),
        .y(y),
        .z(z),
        .busy(busy),
        .done(done)
    );

    // 100 MHz clock (10 ns period)
    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        // Initialize signals
        rst_n = 1'b0;
        start = 1'b0;
        x = 4'sd0;
        y = 4'sd0;
        expected = 8'sd0;

        errors = 0;
        total_tests = 0;

        $timeformat(-9, 0, " ns", 10);

        $display("==============================================================");
        $display("       SEQUENTIAL SIGNED 4-BIT BOOTH MULTIPLIER");
        $display("==============================================================");
        $display("Clock period: 10 ns (100 MHz)");
        $display("Testing all 256 signed input combinations");
        $display("--------------------------------------------------------------");

        // Apply reset
        repeat (2) @(negedge clk);
        rst_n = 1'b1;

        // Exhaustive testing: -8 to +7
        for (i = -8; i <= 7; i = i + 1) begin
            for (j = -8; j <= 7; j = j + 1) begin

                // Apply inputs and calculate expected product
                @(negedge clk);
                x = i;
                y = j;
                expected = i * j;

                // Request multiplication
                start = 1'b1;

                // Start is sampled at the next rising edge
                @(negedge clk);
                start = 1'b0;

                // Wait for completion, with timeout protection
                timeout_count = 0;

                while ((done !== 1'b1) &&
                       (timeout_count < 10)) begin
                    @(negedge clk);
                    timeout_count = timeout_count + 1;
                end

                // Allow nonblocking assignments to settle
                #1;

                total_tests = total_tests + 1;

                if (done !== 1'b1) begin
                    errors = errors + 1;
                    $display(
                        "FAIL: TIMEOUT x=%0d y=%0d",
                        i, j
                    );
                end
                else if (z !== expected) begin
                    errors = errors + 1;
                    $display(
                        "FAIL: x=%0d y=%0d z=%0d expected=%0d",
                        i, j, z, expected
                    );
                end
                else begin
                    $display(
                        "PASS: x=%0d y=%0d z=%0d",
                        i, j, z
                    );
                end

                // Allow the multiplier to return to idle
                @(negedge clk);
            end
        end

        // Simulation summary
        $display("");
        $display("==============================================================");
        $display("                 SIMULATION SUMMARY");
        $display("==============================================================");
        $display("Total test cases : %0d", total_tests);
        $display("Passed tests     : %0d", total_tests - errors);
        $display("Failed tests     : %0d", errors);
        $display("--------------------------------------------------------------");

        if (errors == 0)
            $display("RESULT: ALL TESTS PASSED");
        else
            $display("RESULT: TEST FAILED - CHECK RTL");

        $display("==============================================================");

        $finish;
    end
endmodule
