//--f data_in[31] = 1 → number is negative → output 0
//--If data_in[31] = 0 → number is positive → pass data_in through to output
//--bit31 = 1 → negative number → ReLU kills it → output 0
//--bit31 = 0 → positive number → ReLU passes it → output = input




module relu (
    input  logic clk,
    input  logic rst_n,
    input  logic signed [31:0] data_in,
    output logic signed [31:0] data_out
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            data_out <= 32'sd0;
        else begin
            if (data_in[31] == 1'b1)
                data_out <= 32'sd0;
            else
                data_out <= data_in;
        end
    end

endmodule
