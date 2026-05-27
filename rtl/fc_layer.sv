//parameter IN_SIZE=41, OUT_SIZE=128
//Makes the module reusable — Layer 1 is 41→128, Layer 2 is 128→64, Layer 3 is 64→5. Same module, different parameters
//$clog2(IN_SIZE) Automatically calculates how many bits needed for counter. log2(41) = 6 bits.
//x_in [0:IN_SIZE-1] This is your input vector — one network packet's 41 features.
//w_in [0:OUT_SIZE-1][0:IN_SIZE-1] This is your weight matrix — a 2D array.
//b_in [0:OUT_SIZE-1] This is your bias vector — one bias per output neuron.
// y_out [0:OUT_SIZE-1] This is your output vector — result after MAC + bias + ReLU.


module fc_layer #(
    parameter IN_SIZE  = 41,
    parameter OUT_SIZE = 128
)(
    input  logic clk,
    input  logic rst_n,
    input  logic start,
    input  logic signed [15:0] x_in  [0:IN_SIZE-1],
    input  logic signed [15:0] w_in  [0:OUT_SIZE-1][0:IN_SIZE-1],
    input  logic signed [15:0] b_in  [0:OUT_SIZE-1],
    output logic signed [15:0] y_out [0:OUT_SIZE-1],
    output logic done
);

    typedef enum logic [1:0] {
        IDLE    = 2'b00,
        COMPUTE = 2'b01,
        OUTPUT  = 2'b10,
        DONE    = 2'b11
    } state_t;

    state_t state;

    logic signed [31:0] acc      [0:OUT_SIZE-1];
    logic signed [31:0] with_bias;
    logic [$clog2(IN_SIZE):0] cnt;
    integer n;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            cnt   <= 0;
            done  <= 0;
        end
        else begin
            case (state)
                IDLE: begin
                    done <= 0;
                    cnt  <= 0;
                    if (start)
                        state <= COMPUTE;
                end

                COMPUTE: begin
                    for (n = 0; n < OUT_SIZE; n++) begin
                        if (cnt == 0)
                            acc[n] <= $signed(w_in[n][cnt]) * $signed(x_in[cnt]);
                        else
                            acc[n] <= acc[n] + $signed(w_in[n][cnt]) * $signed(x_in[cnt]);
                    end
                    cnt <= cnt + 1;
                    if (cnt == IN_SIZE - 1)
                        state <= OUTPUT;
                end

                OUTPUT: begin
                    for (n = 0; n < OUT_SIZE; n++) begin
                        with_bias = acc[n] + ($signed(b_in[n]) <<< 8);
                        if (with_bias[31] == 1'b1)
                            y_out[n] <= 16'sd0;
                        else
                            y_out[n] <= with_bias[23:8];
                    end
                    done  <= 1;
                    state <= DONE;
                end

                DONE: begin
                    done  <= 0;
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule
