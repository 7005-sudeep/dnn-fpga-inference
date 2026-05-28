class dnn_sequence extends uvm_sequence #(dnn_seq_item);
    `uvm_object_utils(dnn_sequence)

    // Test vectors loaded from Python
    logic signed [15:0] test_inputs  [0:2][0:40];
    int                 test_labels  [0:2];

    function new(string name = "dnn_sequence");
        super.new(name);
    endfunction

    task body();
        dnn_seq_item item;

        // Sample 0 — DoS attack
        test_labels[0] = 1;
        test_inputs[0] = '{
            -28,-32,278,-569,-2,-1,-4,-23,-2,-24,
            -7,-207,-3,-9,-6,-3,-7,-5,-11,0,
            -1,-25,324,-63,-163,-162,703,695,-362,-4,
            -96,188,-244,-274,-31,-123,-74,-164,-160,736,705
        };

        // Sample 1 — DoS attack
        test_labels[1] = 1;
        test_inputs[1] = '{
            -28,-32,278,-569,-2,-1,-4,-23,-2,-24,
            -7,-207,-3,-9,-6,-3,-7,-5,-11,0,
            -1,-25,116,-94,-163,-162,703,695,-379,-4,
            -96,188,-265,-297,-31,-123,-74,-164,-160,736,705
        };

        // Sample 2 — Normal traffic
        test_labels[2] = 0;
        test_inputs[2] = '{
            -28,-32,-176,192,-1,-1,-4,-23,-2,-24,
            -7,-207,-3,-9,-6,-3,-7,-5,-11,0,
            -1,-25,-186,-94,-163,-162,-96,-96,197,-90,
            -96,-124,-69,51,-58,382,-29,-164,-160,-99,-96
        };

        // Send all 3 items
        foreach (test_inputs[i]) begin
            item = dnn_seq_item::type_id::create("item");
            start_item(item);
            for (int j = 0; j <= 40; j++)
                item.x_in[j] = test_inputs[i][j];
            item.expected_class = test_labels[i];
            finish_item(item);
        end
    endtask

endclass
