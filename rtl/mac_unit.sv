// MAC Unit — Multiply Accumulate
// Inputs:  two Q8.8 fixed point values (16-bit signed)
// Output:  accumulated sum (32-bit signed to avoid overflow)

module mac_unit (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        en,
    input  logic        clear,
    input  logic signed [15:0] a,
    input  logic signed [15:0] b,
    output logic signed [31:0] acc_out
);

    // Internal accumulator
    logic signed [31:0] acc;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            acc <= 32'sd0;
        end
        else if (clear) begin
            acc <= 32'sd0;
        end
        else if (en) begin
            acc <= acc + (a * b);
        end
    end

    assign acc_out = acc;

endmodule
