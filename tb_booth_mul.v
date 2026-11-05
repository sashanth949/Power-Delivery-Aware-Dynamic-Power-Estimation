module tb_booth_mul;

    // Inputs
    reg signed [3:0] x;
    reg signed [3:0] y;

    // Output from Booth multiplier
    wire signed [7:0] z;

    // Expected result
    reg signed [7:0] expected;

    integer i;
    integer j;
    integer errors;
    integer total_tests;

    // Instantiate the Unit Under Test
    booth_mul uut (
        .x(x),
        .y(y),
        .z(z)
    );

    initial begin

        $timeformat(-9, 0, " ns", 10);

        errors = 0;
        total_tests = 0;

        $display("==================================================================");
        $display("              SIGNED 4-BIT BOOTH MULTIPLIER");
        $display("==================================================================");
        $display("%-10s | %6s | %6s | %6s | %8s | %-6s",
                 "Time", "x", "y", "z", "Expected", "Status");
        $display("------------------------------------------------------------------");

        // Exhaustive testing: all 256 signed input combinations
        for (i = -8; i <= 7; i = i + 1) begin
            for (j = -8; j <= 7; j = j + 1) begin

                x = i;
                y = j;

                // Allow combinational logic to settle
                #10;

                // Calculate expected signed product
                expected = i * j;

                total_tests = total_tests + 1;

                // Compare actual and expected outputs
if (z !== expected) begin
    errors = errors + 1;

    $display("%7t | %6d | %6d | %6d | %8d | %-6s",
             $time, x, y, z, expected, "FAIL");
end
else begin
    $display("%7t | %6d | %6d | %6d | %8d | %-6s",
             $time, x, y, z, expected, "PASS");
end

            end
        end

        // Simulation summary
        $display("==================================================================");
        $display("                    SIMULATION SUMMARY");
        $display("==================================================================");
        $display("Total test cases : %0d", total_tests);
        $display("Passed tests     : %0d", total_tests - errors);
        $display("Failed tests     : %0d", errors);
        $display("------------------------------------------------------------------");

        if (errors == 0) begin
            $display("RESULT: ALL TESTS PASSED");
        end
        else begin
            $display("RESULT: TEST FAILED - CHECK BOOTH MULTIPLIER RTL");
        end

        $display("==================================================================");

        $finish;

    end

endmodule
