class dnn_driver extends uvm_driver #(dnn_seq_item);
    `uvm_component_utils(dnn_driver)

    virtual interface dnn_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(virtual dnn_if)::get(
            this, "", "vif", vif))
            `uvm_fatal("NO_VIF", "Virtual interface not found")
    endfunction

    task run_phase(uvm_phase phase);
        dnn_seq_item item;
        forever begin
            seq_item_port.get_next_item(item);
            drive_item(item);
            seq_item_port.item_done();
        end
    endtask

    task drive_item(dnn_seq_item item);
        // Wait for reset
        @(posedge vif.clk);
        wait(vif.rst_n === 1'b1);

        // Drive inputs
        for (int i = 0; i <= 40; i++)
            vif.x_in[i] <= item.x_in[i];

        // Pulse start
        vif.start <= 1;
        @(posedge vif.clk);
        vif.start <= 0;

        // Wait for done
        wait(vif.done === 1'b1);
        @(posedge vif.clk);

        `uvm_info("DRIVER",
            $sformatf("Drove packet, expected class=%0d",
            item.expected_class), UVM_MEDIUM)
    endtask

endclass
