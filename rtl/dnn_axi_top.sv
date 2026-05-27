//  $clog2(41) for rx_cnt? $clog2 = ceiling log base 2 — it calculates the minimum number of bits needed to count up to that value.
// $clog2(41) = 6 bits ( 6 bits can count 0 to 63  → enough for 41)
//$clog2 automatically calculates the minimum bit width needed for a counter. 
//Using it instead of hardcoded values makes the design parametric and reusable.



module dnn_axi_top (
    input  logic clk,
    input  logic rst_n,

    // AXI4-Stream input interface
    input  logic        s_axis_tvalid,
    output logic        s_axis_tready,
    input  logic [15:0] s_axis_tdata,
    input  logic        s_axis_tlast,

    // AXI4-Stream output interface
    output logic        m_axis_tvalid,
    input  logic        m_axis_tready,
    output logic [15:0] m_axis_tdata,
    output logic        m_axis_tlast
);

    // FSM states
    typedef enum logic [1:0] {
        IDLE    = 2'b00,
        RECEIVE = 2'b01,
        COMPUTE = 2'b10,
        SEND    = 2'b11
    } state_t;

    state_t state;

    // Input buffer — store 41 features
    logic signed [15:0] x_in  [0:40];
    logic signed [15:0] y_out [0:4];
    logic [$clog2(41):0] rx_cnt;
    logic [$clog2(5):0]  tx_cnt;
    logic dnn_start;
    logic dnn_done;

    // Instantiate DNN
    dnn_top dnn (
        .clk   (clk),
        .rst_n (rst_n),
        .start (dnn_start),
        .x_in  (x_in),
        .y_out (y_out),
        .done  (dnn_done)
    );

    // AXI4-Stream FSM
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state         <= IDLE;
            rx_cnt        <= 0;
            tx_cnt        <= 0;
            dnn_start     <= 0;
            s_axis_tready <= 0;
            m_axis_tvalid <= 0;
            m_axis_tlast  <= 0;
            m_axis_tdata  <= 0;
        end
        else begin
            dnn_start <= 0;

            case (state)
                IDLE: begin
                    rx_cnt        <= 0;
                    tx_cnt        <= 0;
                    s_axis_tready <= 1;
                    m_axis_tvalid <= 0;
                    state         <= RECEIVE;
                end

                RECEIVE: begin
                    if (s_axis_tvalid && s_axis_tready) begin
                        x_in[rx_cnt] <= $signed(s_axis_tdata);
                        rx_cnt       <= rx_cnt + 1;
                        if (s_axis_tlast || rx_cnt == 40) begin
                            s_axis_tready <= 0;
                            dnn_start     <= 1;
                            state         <= COMPUTE;
                        end
                    end
                end

                COMPUTE: begin
                    if (dnn_done) begin
                        tx_cnt        <= 0;
                        m_axis_tvalid <= 1;
                        m_axis_tdata  <= y_out[0];
                        state         <= SEND;
                    end
                end

                SEND: begin
                    if (m_axis_tready && m_axis_tvalid) begin
                        tx_cnt <= tx_cnt + 1;
                        if (tx_cnt == 4) begin
                            m_axis_tlast  <= 1;
                            m_axis_tvalid <= 0;
                            state         <= IDLE;
                        end
                        else begin
                            m_axis_tdata <= y_out[tx_cnt + 1];
                            m_axis_tlast <= 0;
                        end
                    end
                end
            endcase
        end
    end

endmodule
