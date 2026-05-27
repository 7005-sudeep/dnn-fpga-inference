`timescale 1ns/1ps

module tb_relu;

    logic        clk;
    logic        rst_n;
    logic signed [31:0] data_in;
    logic signed [31:0] data_out;

    relu dut (
        .clk      (clk),
        .rst_n    (rst_n),
        .data_in  (data_in),
        .data_out (data_out)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    integer errors = 0;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_relu);

        rst_n   = 0;
        data_in = 0;
        @(posedge clk); #1;
        rst_n = 1;
        @(posedge clk); #1;

        // Test 1: positive number passes through
        $display("Test 1: positive 6.0 passes through");
        data_in = 32'sd393216;
        @(posedge clk); #1;
        if (data_out == 32'sd393216)
            $display("  PASS: data_out = %0d", data_out);
        else begin
            $display("  FAIL: expected 393216 got %0d", data_out);
            errors++;
        end

        // Test 2: negative number becomes 0
        $display("Test 2: negative -2.0 becomes 0");
        data_in = -32'sd131072;
        @(posedge clk); #1;
        if (data_out == 32'sd0)
            $display("  PASS: data_out = 0");
        else begin
            $display("  FAIL: expected 0 got %0d", data_out);
            errors++;
        end

        // Test 3: zero stays zero
        $display("Test 3: zero stays zero");
        data_in = 32'sd0;
        @(posedge clk); #1;
        if (data_out == 32'sd0)
            $display("  PASS: data_out = 0");
        else begin
            $display("  FAIL: expected 0 got %0d", data_out);
            errors++;
        end

        // Test 4: reset works
        $display("Test 4: reset drives output to 0");
        data_in = 32'sd999999;
        rst_n   = 0;
        @(posedge clk); #1;
        if (data_out == 32'sd0)
            $display("  PASS: reset works");
        else begin
            $display("  FAIL: expected 0 got %0d", data_out);
            errors++;
        end
        rst_n = 1;

        $display("\n================================");
        if (errors == 0)
            $display("ALL TESTS PASSED");
        else
            $display("FAILED: %0d errors", errors);
        $display("================================");

        $finish;
    end

endmodule
