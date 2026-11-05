module tb_mac;
    reg clk;
    reg rst_n;
    reg [7:0] a;
    reg [7:0] b;
    wire[15:0]product;
    wire [23:0] accum_out;
    integer file_handle;

    // Instantiate Unit Under Test (UUT)
    mac_unit uut (
        .clk(clk),
        .rst_n(rst_n),
        .a(a),
        .b(b),
        .product(product),
        .accum_out(accum_out)
    );

    // Clock Generation (10ns period)
    always begin
        #5 clk = ~clk;
    end

    initial begin
        // Open CSV results file
        file_handle = $fopen("MAC_simulation_results.csv", "w");
        $fdisplay(file_handle, "Time(ps),clk,rst_n,a,b,product,accum_out_dec,accum_out_hex");

        $fmonitor(file_handle, "%0t,%b,%b,%0d,%0d,%0d,%0d,0x%06h",
                  $time, clk, rst_n, a, b,product, accum_out, accum_out);

        // -------- Initialize Signals --------
        clk   = 0;
        rst_n = 0;
        a     = 8'd0;    
        b     = 8'd0;

        // Hold reset for 2 cycles
        repeat(2) @(posedge clk);  
        rst_n = 1;
        @(posedge clk);

        // -------- Stimulus Sequence --------
        // Apply test vector 1: 12 * 15 = 180
        a = 8'd12; b = 8'd15; 
        repeat(3) @(posedge clk); // Hold input through pipeline latency

        // Apply test vector 2: 25 * 4 = 100
        a = 8'd25; b = 8'd4;  
        repeat(3) @(posedge clk);

        // Apply test vector 3: 100 * 2 = 200
        a = 8'd100; b = 8'd2; 
        repeat(3) @(posedge clk);

        // Clear inputs to let final products accumulate
        a = 8'd0; b = 8'd0;
        repeat(4) @(posedge clk);

        // -------- Second Sequence (Optional post-reset check) --------
        // Assert clean reset at the beginning of sequence 2 if desired
        rst_n = 0; @(posedge clk);
        rst_n = 1; @(posedge clk);

        a = 8'd50; b = 8'd3; // 50 * 3 = 150
        repeat(3) @(posedge clk);

        a = 8'd0; b = 8'd0;
        
        // Final settle time to observe accumulated output
        repeat(5) @(posedge clk);

        // Close file and finish
        $fclose(file_handle);
        $display("Simulation finished. Results saved to MAC_simulation_results.csv");
        $finish;
    end
endmodule
