//Load 50 hex test vectors from file
    
//For each sample:
  //  Feed 41 features into DNN
    //Wait for done signal
   // Find highest output score = predicted class
   // Compare to golden expected class
  //  PASS or FAIL
    
//Print final accuracy
      


timescale 1ns/1ps
module tb_dnn_top;
logic clk;
logic rst_n;
logic start;
logic signed [15:0] x_in [0:40];
logic signed [15:0] y_out [0:4];
logic done;
dnn_top dut (
.clk(clk),
.rst_n(rst_n),
.start(start),
.x_in(x_in),
.y_out(y_out),
.done(done));
initial clk = 0;
always #5 clk = ~clk;
logic signed [15:0] test_inputs [0:49][0:40];
logic signed [15:0] test_outputs [0:49][0:4];
logic [7:0] test_labels [0:49];
integer errors = 0;
integer correct = 0;
integer i, j;
initial begin
$dumpfile("dump.vcd");
$dumpvars(0, tb_dnn_top);
$readmemh("test_vectors/inputs.hex", test_inputs);
$readmemh("test_vectors/expected_out.hex", test_outputs);
$readmemh("test_vectors/labels.hex", test_labels);
rst_n = 0; start = 0;
@(posedge clk); #1;
rst_n = 1;
@(posedge clk); #1;
$display("=== DNN TOP SELF CHECKING TESTBENCH ===");
$display("Running 50 test vectors...");
for (i = 0; i < 50; i++) begin
for (j = 0; j <= 40; j++) begin
x_in[j] = test_inputs[i][j];
end
start = 1;
@(posedge clk); #1;
start = 0;
wait(done == 1);
@(posedge clk); #1;
begin
logic signed [15:0] max_val;
integer pred_class;
integer true_class;
max_val = y_out[0];
pred_class = 0;
for (j = 1; j < 5; j++) begin
if (y_out[j] > max_val) begin
max_val = y_out[j];
pred_class = j;
end
end
true_class = test_labels[i];
if (pred_class == true_class) begin
correct++;
$display("Sample %0d: PASS pred=%0d true=%0d", i, pred_class, true_class);
end
else begin
errors++;
$display("Sample %0d: FAIL pred=%0d true=%0d", i, pred_class, true_class);
end
end
@(posedge clk); #1;
end
$display("================================");
$display("Results: %0d/50 correct", correct);
$display("Accuracy: %0d%%", correct*2);
if (errors == 0)
$display("ALL 50 SAMPLES PASSED");
else
$display("%0d errors found", errors);
$display("================================");
$finish;
end
endmodule
