`timescale 1ns/1ps

module tb_mac_unit;

    // Inputs
    logic        clk;
    logic        rst_n;
    logic        en;
    logic        clear;
    logic signed [15:0] a;
    logic signed [15:0] b;

    // Output
    logic signed [31:0] acc_out;

    // Instantiate MAC unit
    mac_unit dut (
        .clk     (clk),
        .rst_n   (rst_n),
        .en      (en),
        .clear   (clear),
        .a       (a),
        .b       (b),
        .acc_out (acc_out)
    );

    // Clock generation — 10ns period = 100MHz
    initial clk = 0;
    always #5 clk = ~clk;

    // Q8.8 conversion function
    function automatic logic signed [15:0] to_q88;
        input real val;
        to_q88 = $rtoi(val * 256.0);
    endfunction

    // Test
    integer errors = 0;

    initial begin
        // Init
        rst_n = 0; en = 0; clear = 0;
        a = 0; b = 0;
        @(posedge clk); #1;
        rst_n = 1;
        @(posedge clk); #1;

        // Test 1: 2.0 * 3.0 = 6.0
        $display("Test 1: 2.0 * 3.0 = 6.0");
        clear = 1; @(posedge clk); #1;
        clear = 0;
        a = to_q88(2.0);
        b = to_q88(3.0);
        en = 1; @(posedge clk); #1;
        en = 0;
        if (acc_out == to_q88(6.0) * 256)
            $display("  PASS: acc = %0d", acc_out);
        else begin
            $display("  FAIL: expected %0d got %0d", to_q88(6.0)*256, acc_out);
            errors++;
        end

        // Test 2: accumulate 1.0*1.0 three times = 3.0
        $display("Test 2: accumulate 1.0*1.0 three times = 3.0");
        clear = 1; @(posedge clk); #1;
        clear = 0;
        a = to_q88(1.0);
        b = to_q88(1.0);
        en = 1;
        @(posedge clk); #1;
        @(posedge clk); #1;
        @(posedge clk); #1;
        en = 0;
        if (acc_out == to_q88(1.0) * to_q88(1.0) * 3)
            $display("  PASS: acc = %0d", acc_out);
        else begin
            $display("  FAIL: expected %0d got %0d", to_q88(1.0)*to_q88(1.0)*3, acc_out);
            errors++;
        end

        // Test 3: negative number -1.0 * 2.0 = -2.0
        $display("Test 3: -1.0 * 2.0 = -2.0");
        clear = 1; @(posedge clk); #1;
        clear = 0;
        a = to_q88(-1.0);
        b = to_q88(2.0);
        en = 1; @(posedge clk); #1;
        en = 0;
        if (acc_out == to_q88(-1.0) * to_q88(2.0))
            $display("  PASS: acc = %0d", acc_out);
        else begin
            $display("  FAIL: expected %0d got %0d", to_q88(-1.0)*to_q88(2.0), acc_out);
            errors++;
        end

        // Test 4: clear works
        $display("Test 4: clear resets accumulator");
        clear = 1; @(posedge clk); #1;
        clear = 0; @(posedge clk); #1;
        if (acc_out == 0)
            $display("  PASS: acc cleared to 0");
        else begin
            $display("  FAIL: clear did not work, acc = %0d", acc_out);
            errors++;
        end

        // Summary
        $display("\n================================");
        if (errors == 0)
            $display("ALL TESTS PASSED");
        else
            $display("FAILED: %0d errors", errors);
        $display("================================");

        $finish;
    end

endmodule
