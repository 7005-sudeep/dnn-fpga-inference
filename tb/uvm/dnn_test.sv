class dnn_test extends uvm_test;
    `uvm_component_utils(dnn_test)

    dnn_env env;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = dnn_env::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);
        dnn_sequence seq;
        phase.raise_objection(this);

        seq = dnn_sequence::type_id::create("seq");
        seq.start(env.agent.sequencer);

        phase.drop_objection(this);
    endtask

endclass
