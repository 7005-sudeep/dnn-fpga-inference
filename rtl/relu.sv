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
