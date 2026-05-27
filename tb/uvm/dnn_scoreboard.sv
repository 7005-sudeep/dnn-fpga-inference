class dnn_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(dnn_scoreboard)

    uvm_analysis_imp #(dnn_seq_item, dnn_scoreboard) analysis_export;

    // Statistics
    int pass_count = 0;
    int fail_count = 0;
    int total      = 0;

    // Expected results queue
    int expected_q [$];

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        analysis_export = new("analysis_export", this);
    endfunction

    // Called by monitor via analysis port
    function void write(dnn_seq_item item);
        int expected;
        total++;

        if (expected_q.size() > 0) begin
            expected = expected_q.pop_front();

            if (item.expected_class == expected) begin
                pass_count++;
                `uvm_info("SCOREBOARD",
                    $sformatf("PASS %0d/%0d pred=%0d exp=%0d",
                    pass_count, total,
                    item.expected_class, expected), UVM_MEDIUM)
            end
            else begin
                fail_count++;
                `uvm_error("SCOREBOARD",
                    $sformatf("FAIL %0d/%0d pred=%0d exp=%0d",
                    fail_count, total,
                    item.expected_class, expected))
            end
        end
    endfunction

    function void report_phase(uvm_phase phase);
        `uvm_info("SCOREBOARD",
            $sformatf("\n=== FINAL RESULTS ===\nPASS: %0d\nFAIL: %0d\nTOTAL: %0d\nAccuracy: %0d%%",
            pass_count, fail_count, total,
            (pass_count*100)/total), UVM_NONE)
    endfunction

endclass
