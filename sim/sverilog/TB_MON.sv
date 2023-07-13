`define MON_IF mst_ahb_if.mon_tb

class Monitorr; 
    virtual AHB2_MST_INTF   mst_ahb_if;
    
    mailbox mon_score;
    
    function new(virtual AHB2_MST_INTF mst_ahb_if, mailbox mon_score);
        this.mst_ahb_if         = mst_ahb_if;
        this.mon_score          = mon_score;
    endfunction

    task run;    
        transaction trans;
        forever begin
            trans = new();
            int cycle2cycle_delay = 0;
            int trans2trans_delay = 0;
            mon_score.get(trans);
            for (int i=0; i<16; i=i+1) begin
                // drive data. The data will not change until it is received by ready.
                trans.addr           <= `MON_IF.addr;
                trans.data[i]        <= `MON_IF.data;    
                repeat(cycle2cycle_delay) @(posedge mst_ahb_if.clk);
            end
            repeat(trans2trans_delay) @(posedge mst_ahb_if.clk);
            mon_score.put(trans);
        end
    endtask
endclass

