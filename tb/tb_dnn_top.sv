//Load 50 hex test vectors from file
    
//For each sample:
  //  Feed 41 features into DNN
    //Wait for done signal
   // Find highest output score = predicted class
   // Compare to golden expected class
  //  PASS or FAIL
    
//Print final accuracy
      
module dnn_top (
    input  logic clk,
    input  logic rst_n,
    input  logic start,
    input  logic signed [15:0] x_in [0:40],
    output logic signed [15:0] y_out [0:4],
    output logic done
);

logic signed [15:0] w1 [0:127][0:40];
logic signed [15:0] b1 [0:127];
logic signed [15:0] y1 [0:127];
logic done1;

logic signed [15:0] w2 [0:63][0:127];
logic signed [15:0] b2 [0:63];
logic signed [15:0] y2 [0:63];
logic done2;

logic signed [15:0] w3 [0:4][0:63];
logic signed [15:0] b3 [0:4];
logic done3;

logic start2, start3;

fc_layer #(.IN_SIZE(41), .OUT_SIZE(128)) layer1 (
.clk(clk),.rst_n(rst_n),.start(start),
.x_in(x_in),.w_in(w1),.b_in(b1),
.y_out(y1),.done(done1));

fc_layer #(.IN_SIZE(128), .OUT_SIZE(64)) layer2 (
.clk(clk),.rst_n(rst_n),.start(start2),
.x_in(y1),.w_in(w2),.b_in(b2),
.y_out(y2),.done(done2));

fc_layer #(.IN_SIZE(64), .OUT_SIZE(5)) layer3 (
.clk(clk),.rst_n(rst_n),.start(start3),
.x_in(y2),.w_in(w3),.b_in(b3),
.y_out(y_out),.done(done3));

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        start2 <= 0;
        start3 <= 0;
        done   <= 0;
    end
    else begin
        start2 <= done1;
        start3 <= done2;
        done   <= done3;
    end
end

initial begin
    $readmemh("W1.hex", w1);
    $readmemh("b1.hex", b1);
    $readmemh("W2.hex", w2);
    $readmemh("b2.hex", b2);
    $readmemh("W3.hex", w3);
    $readmemh("b3.hex", b3);
end

endmodule
