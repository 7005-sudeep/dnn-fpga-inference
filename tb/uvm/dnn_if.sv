interface dnn_if (input logic clk);
    logic        rst_n;
    logic        start;
    logic        done;
    logic signed [15:0] x_in  [0:40];
    logic signed [15:0] y_out [0:4];
endinterface
