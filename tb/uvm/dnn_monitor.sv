class dnn_monitor extends uvm_monitor;
    `uvm_component_utils(dnn_monitor)

    virtual dnn_if vif;

    uvm_analysis_port #(dnn_seq_item) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
        if (!uvm_config_db #(virtual dnn_if)::get(
            this, "", "vif", vif))
            `uvm_fatal("NO_VIF", "Monitor virtual interface not found")
    endfunction

    task run_phase(uvm_phase phase);
        dnn_seq_item item;
        forever begin
            // Wait for done signal
            @(posedge vif.clk);
            if (vif.done === 1'b1) begin
                item = dnn_seq_item::type_id::create("item");

                // Capture outputs
                for (int i = 0; i <= 40; i++)
                    item.x_in[i] = vif.x_in[i];

                // Find predicted class (argmax)
                begin
                    logic signed [15:0] max_val;
                    int pred_class;
                    max_val   = vif.y_out[0];
                    pred_class = 0;
                    for (int j = 1; j < 5; j++) begin
                        if (vif.y_out[j] > max_val) begin
                            max_val    = vif.y_out[j];
                            pred_class = j;
                        end
                    end
                    item.expected_class = pred_class;
                end

                `uvm_info("MONITOR",
                    $sformatf("Captured output class=%0d",
                    item.expected_class), UVM_MEDIUM)

                ap.write(item);
            end
        end
    endtask

endclass
