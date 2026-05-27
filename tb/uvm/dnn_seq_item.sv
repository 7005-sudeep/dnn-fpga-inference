class dnn_seq_item extends uvm_sequence_item;
    `uvm_object_utils(dnn_seq_item)

    // Input features
    rand logic signed [15:0] x_in [0:40];

    // Expected output class
    logic [2:0] expected_class;

    // Constraints — keep values in Q8.8 range
    constraint valid_input {
        foreach (x_in[i])
            x_in[i] inside {[-32768:32767]};
    }

    function new(string name = "dnn_seq_item");
        super.new(name);
    endfunction

    function string convert2string();
        return $sformatf("expected_class=%0d x_in[0]=%0d",
                expected_class, x_in[0]);
    endfunction

endclass
