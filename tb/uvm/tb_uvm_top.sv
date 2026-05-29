`timescale 1ns/1ps
`include "uvm_macros.svh"
import uvm_pkg::*;

`include "dnn_if.sv"
`include "dnn_seq_item.sv"
`include "dnn_driver.sv"
`include "dnn_monitor.sv"
`include "dnn_scoreboard.sv"
`include "dnn_agent.sv"
`include "dnn_env.sv"
`include "dnn_sequence.sv"
`include "dnn_test.sv"

module tb_uvm_top;

    logic clk;

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    // Interface instantiation
    dnn_if dif(.clk(clk));

    // DUT instantiation
    dnn_top dut(
        .clk   (clk),
        .rst_n (dif.rst_n),
        .start (dif.start),
        .x_in  (dif.x_in),
        .y_out (dif.y_out),
        .done  (dif.done)
    );

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_uvm_top);

        // Set virtual interface in config db
        uvm_config_db #(virtual dnn_if)::set(
            null, "uvm_test_top.*", "vif", dif);

        // Reset sequence
        dif.rst_n = 0;
        dif.start = 0;
        repeat(5) @(posedge clk);
        dif.rst_n = 1;
        repeat(2) @(posedge clk);

        // Run UVM test
        run_test("dnn_test");
    end

endmodule
