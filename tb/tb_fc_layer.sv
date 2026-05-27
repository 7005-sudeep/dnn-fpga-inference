// input vector x = [1.0, 0.5, -1.0, 2.0]
// Neuron 0 — weights [1.0, 1.0, 1.0, 1.0]: 
// dot product = (1.0×1.0) + (1.0×0.5) + (1.0×-1.0) + (1.0×2.0)
            =  1.0      +  0.5      + -1.0         +  2.0
            =  2.5

//bias = 0.0
//ReLU(2.5) = 2.5  ✅ positive → passes through

//Neuron 1 — weights [1.0, -1.0, 1.0, -1.0]:
//dot product = (1.0×1.0) + (-1.0×0.5) + (1.0×-1.0) + (-1.0×2.0)
            =  1.0      +  -0.5      +  -1.0        +  -2.0
            = -2.5

bias = 0.0
ReLU(-2.5) = 0.0  ✅ negative → killed by ReLU




`timescale 1ns/1ps

module tb_fc_layer;

    // Parameters
    localparam IN_SIZE  = 4;
    localparam OUT_SIZE = 3;

    // Signals
    logic clk;
    logic rst_n;
    logic start;
    logic signed [15:0] x_in [0:IN_SIZE-1];
    logic signed [15:0] w_in [0:OUT_SIZE-1][0:IN_SIZE-1];
    logic signed [15:0] b_in [0:OUT_SIZE-1];
    logic signed [15:0] y_out [0:OUT_SIZE-1];
    logic done;

    // Instantiate FC layer
    fc_layer #(
        .IN_SIZE  (IN_SIZE),
        .OUT_SIZE (OUT_SIZE)
    ) dut (
        .clk   (clk),
        .rst_n (rst_n),
        .start (start),
        .x_in  (x_in),
        .w_in  (w_in),
        .b_in  (b_in),
        .y_out (y_out),
        .done  (done)
    );

    // Clock
    initial clk = 0;
    always #5 clk = ~clk;

    // Q8.8 conversion
    function automatic logic signed [15:0] toq;
        input real val;
        toq = $rtoi(val * 256.0);
    endfunction

    function automatic real fromq;
        input logic signed [15:0] val;
        fromq = $itor(val) / 256.0;
    endfunction

    integer errors = 0;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_fc_layer);

        // Reset
        rst_n = 0; start = 0;
        @(posedge clk); #1;
        rst_n = 1;
        @(posedge clk); #1;

        // Simple test case
        // Input: [1.0, 0.5, -1.0, 2.0]
        // Weights neuron 0: [1.0,  1.0,  1.0,  1.0]  → dot = 1+0.5-1+2 = 2.5
        // Weights neuron 1: [1.0, -1.0,  1.0, -1.0]  → dot = 1-0.5-1-2 = -2.5 → ReLU → 0
        // Weights neuron 2: [0.5,  0.5,  0.5,  0.5]  → dot = 0.5+0.25-0.5+1 = 1.25
        // Bias: [0.0, 0.0, 0.0]
        // Expected output: [2.5, 0.0, 1.25]

        x_in[0] = toq(1.0);
        x_in[1] = toq(0.5);
        x_in[2] = toq(-1.0);
        x_in[3] = toq(2.0);

        // Neuron 0 weights
        w_in[0][0] = toq(1.0);
        w_in[0][1] = toq(1.0);
        w_in[0][2] = toq(1.0);
        w_in[0][3] = toq(1.0);

        // Neuron 1 weights
        w_in[1][0] = toq(1.0);
        w_in[1][1] = toq(-1.0);
        w_in[1][2] = toq(1.0);
        w_in[1][3] = toq(-1.0);

        // Neuron 2 weights
        w_in[2][0] = toq(0.5);
        w_in[2][1] = toq(0.5);
        w_in[2][2] = toq(0.5);
        w_in[2][3] = toq(0.5);

        // Bias all zero
        b_in[0] = toq(0.0);
        b_in[1] = toq(0.0);
        b_in[2] = toq(0.0);

        // Start
        start = 1;
        @(posedge clk); #1;
        start = 0;

        // Wait for done
        wait(done == 1);
        @(posedge clk); #1;

        // Check results
        $display("=== FC LAYER TEST ===");
        $display("Neuron 0: got %.4f expected 2.5", fromq(y_out[0]));
        $display("Neuron 1: got %.4f expected 0.0 (ReLU)", fromq(y_out[1]));
        $display("Neuron 2: got %.4f expected 1.25", fromq(y_out[2]));

        if (fromq(y_out[0]) > 2.4 && fromq(y_out[0]) < 2.6)
            $display("Neuron 0: PASS");
        else begin
            $display("Neuron 0: FAIL");
            errors++;
        end

        if (y_out[1] == 0)
            $display("Neuron 1: PASS (ReLU killed negative)");
        else begin
            $display("Neuron 1: FAIL");
            errors++;
        end

        if (fromq(y_out[2]) > 1.2 && fromq(y_out[2]) < 1.3)
            $display("Neuron 2: PASS");
        else begin
            $display("Neuron 2: FAIL");
            errors++;
        end

        $display("\n================================");
        if (errors == 0)
            $display("ALL TESTS PASSED");
        else
            $display("FAILED: %0d errors", errors);
        $display("================================");

        $finish;
    end

endmodule
