module tb_booth8;

    reg                clk;
    reg                rst;          // active-low reset (change if your RTL uses rst)
    reg                start;
    reg  signed [7:0]  x;
    reg  signed [7:0]  y;

    wire signed [15:0] z;
    wire               busy;
    wire               done;

    reg  signed [15:0] expected;       // ← 16-bit!
    integer i, j;
    integer errors, total_tests, timeout_count;

    // Instantiate your 8×8 Booth module
    booth_mul_8 uut (            // ← use the correct module name
        .clk(clk),
        .rst(rst),                 // change to .rst(rst) if needed
        .start(start),
        .x(x),
        .y(y),
        .z(z),
        .busy(busy),
        .done(done)
    );

    // 100 MHz clock
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $timeformat(-9, 0, " ns", 10);
        rst  = 0;
        start  = 0;
        x      = 0;
        y      = 0;
        errors = 0;
        total_tests = 0;

        $display("==============================================================");
        $display("     SEQUENTIAL SIGNED 8×8 BOOTH MULTIPLIER - EXHAUSTIVE");
        $display("==============================================================");

        // Reset
        repeat(3) @(negedge clk);
        rst = 1;
        repeat(2) @(negedge clk);

        //----------------------------------------------------------
        // Full exhaustive test: -128 to +127  (65536 cases)
        //----------------------------------------------------------
        for (i = -128; i <= 127; i = i + 1) begin
            for (j = -128; j <= 127; j = j + 1) begin

                @(negedge clk);
                x = i;
                y = j;
                expected = i * j;          // 16-bit result in simulation

                // Pulse start
                start = 1;
                @(negedge clk);
                start = 0;

                // Wait for done (with timeout)
                timeout_count = 0;
                while ((done !== 1'b1) && (timeout_count < 20)) begin
                    @(negedge clk);
                    timeout_count = timeout_count + 1;
                end

                #1;   // let non-blocking assignments settle
                total_tests = total_tests + 1;

                if (done !== 1'b1) begin
                    errors = errors + 1;
                    $display("FAIL: TIMEOUT  x=%0d  y=%0d", i, j);
                end
                else if (z !== expected) begin
                    errors = errors + 1;
                    $display("FAIL: x=%0d y=%0d  got=%0d  expected=%0d",
                             i, j, z, expected);
                end
                // Uncomment the next line if you want to see every PASS
                // else $display("PASS: x=%0d y=%0d = %0d", i, j, z);

                // Small gap before next test
                @(negedge clk);
            end
        end

        // Summary
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
