class dnn_agent extends uvm_agent;
    `uvm_component_utils(dnn_agent)

    dnn_driver   driver;
    dnn_monitor  monitor;
    uvm_sequencer #(dnn_seq_item) sequencer;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        driver    = dnn_driver::type_id::create("driver", this);
        monitor   = dnn_monitor::type_id::create("monitor", this);
        sequencer = uvm_sequencer #(dnn_seq_item)::type_id::create("sequencer", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction

endclass
