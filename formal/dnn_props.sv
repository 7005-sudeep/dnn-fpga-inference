module dnn_props (
    input logic clk,
    input logic rst_n,
    input logic start,
    input logic done,
    input logic done1,
    input logic done2,
    input logic done3,
    input logic start2,
    input logic start3
);

    // Default clocking and reset
    default clocking cb @(posedge clk);
    endclocking
    default disable iff (!rst_n);

    // Property 1: done must never be high for more than 1 cycle
    property done_pulses_once;
        done |=> !done;
    endproperty
    assert_done_pulses: assert property(done_pulses_once)
        else $error("FAIL: done stayed high more than 1 cycle");

    // Property 2: after start, start2 must come after done1
    property layer_chain_order;
        done1 |=> start2;
    endproperty
    assert_chain_order: assert property(layer_chain_order)
        else $error("FAIL: layer chaining broken — start2 did not follow done1");

    // Property 3: after done1, start3 must follow done2
    property layer2_chain;
        done2 |=> start3;
    endproperty
    assert_layer2_chain: assert property(layer2_chain)
        else $error("FAIL: layer chaining broken — start3 did not follow done2");

    // Property 4: done3 must eventually lead to top done
    property done3_leads_to_done;
        done3 |=> done;
    endproperty
    assert_done3: assert property(done3_leads_to_done)
        else $error("FAIL: done3 did not propagate to top done");

    // Property 5: reset must clear done
    property reset_clears_done;
        !rst_n |-> !done;
    endproperty
    assert_reset: assert property(reset_clears_done)
        else $error("FAIL: done not cleared during reset");

    // Property 6: start and done never high at same time
    property no_start_done_overlap;
        start |-> !done;
    endproperty
    assert_no_overlap: assert property(no_start_done_overlap)
        else $error("FAIL: start and done overlap detected");

    // Cover properties — reachability checks
    cover_done:    cover property(done);
    cover_start:   cover property(start);
    cover_chain:   cover property(done1 ##1 start2);

endmodule
