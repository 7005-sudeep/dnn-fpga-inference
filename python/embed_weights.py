def hex_to_signed(h):
    v = int(h, 16)
    if v >= 32768:
        v -= 65536
    return v

def read_hex(path):
    with open(path) as f:
        return [hex_to_signed(l.strip()) for l in f if l.strip()]

inputs = []
labels = []
with open('test_vectors/inputs.hex') as f:
    for line in f:
        vals = line.strip().split()
        inputs.append([hex_to_signed(v) for v in vals])
with open('test_vectors/labels.hex') as f:
    for line in f:
        labels.append(int(line.strip(), 16))

sv = []
sv.append('`timescale 1ns/1ps')
sv.append('module tb_dnn_embedded;')
sv.append('logic clk;')
sv.append('logic rst_n;')
sv.append('logic start;')
sv.append('logic signed [15:0] x_in [0:40];')
sv.append('logic signed [15:0] y_out [0:4];')
sv.append('logic done;')
sv.append('dnn_top dut(.clk(clk),.rst_n(rst_n),.start(start),.x_in(x_in),.y_out(y_out),.done(done));')
sv.append('initial clk = 0;')
sv.append('always #5 clk = ~clk;')
sv.append('integer errors = 0;')
sv.append('integer correct = 0;')
sv.append('integer pred_class;')
sv.append('integer true_class;')
sv.append('integer j;')
sv.append('logic signed [15:0] max_val;')
sv.append('initial begin')
sv.append('$dumpfile("dump.vcd");')
sv.append('$dumpvars(0, tb_dnn_embedded);')
sv.append('rst_n = 0; start = 0;')
sv.append('@(posedge clk); #1;')
sv.append('rst_n = 1;')
sv.append('@(posedge clk); #1;')
sv.append('$display("=== DNN TESTBENCH ===");')

for i in range(3):
    sv.append('// Sample ' + str(i))
    for j in range(41):
        sv.append('x_in[' + str(j) + '] = 16\'sd' + str(inputs[i][j]) + ';')
    sv.append('start=1; @(posedge clk); #1; start=0;')
    sv.append('wait(done==1); @(posedge clk); #1;')
    sv.append('max_val=y_out[0]; pred_class=0;')
    sv.append('for(j=1;j<5;j++) if(y_out[j]>max_val) begin max_val=y_out[j]; pred_class=j; end')
    sv.append('true_class=' + str(labels[i]) + ';')
    sv.append('if(pred_class==true_class) begin correct++; $display("S' + str(i) + ' PASS pred=%0d true=%0d",pred_class,true_class); end')
    sv.append('else begin errors++; $display("S' + str(i) + ' FAIL pred=%0d true=%0d",pred_class,true_class); end')
    sv.append('@(posedge clk); #1;')

sv.append('$display("Results: %0d/3 correct", correct);')
sv.append('if(errors==0) $display("ALL PASSED");')
sv.append('else $display("%0d errors", errors);')
sv.append('$finish;')
sv.append('end')
sv.append('endmodule')

with open('tb/tb_dnn_embedded.sv', 'w') as f:
    f.write('\n'.join(sv))

print('Generated tb/tb_dnn_embedded.sv')
print('Lines: ' + str(len(sv)))
print('Done!')
