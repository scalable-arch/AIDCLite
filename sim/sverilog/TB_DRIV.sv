`define DRIV_IF mst_ahb_if.master_tb.master_cb

class Driver; 
    virtual AHB2_MST_INTF   mst_ahb_if;
    
    mailbox gen_driv;
    mailbox gen_score;
    
    function new(virtual AHB2_MST_INTF mst_ahb_if, mailbox gen_driv, mailbox gen_score);
        this.mst_ahb_if         = mst_ahb_if;
        this.gen_driv           = gen_driv;
        this.gen_score          = gen_score;
    endfunction

    task reset;
        wait (!mst_ahb_if.rst_n);    // #5;
        $display("[ DRIVER ] ----- Reset Started ----- ");

        `DRIV_IF.hbusreq       <= 0;    
        `DRIV_IF.haddr         <= 0;    
        `DRIV_IF.htrans        <= 0;    
        `DRIV_IF.hwrite        <= 0;    
        `DRIV_IF.hsize         <= 0;    
        `DRIV_IF.hburst        <= 0;    
        `DRIV_IF.hprot         <= 0;    
        `DRIV_IF.hwdata        <= 0;    
        
        wait (mst_ahb_if.rst_n);    // #5;
        $display("[ DRIVER ] ----- Reset Ended -----");
    endtask

    task run;    
        transaction trans;
        forever begin
            int cycle2cycle_delay = 0;
            int trans2trans_delay = 0;
            gen_driv.get(trans);
            for (int i=0; i<16; i=i+1) begin
                // drive data. The data will not change until it is received by ready.
                //ahb_if.write(,);    
                @(posedge mst_ahb_if.clk);
                while (!`DRIV_IF.hgrant) begin
                    @(posedge mst_ahb_if.clk);
                end
                `DRIV_IF.hwdata        <= 0;    
                repeat(cycle2cycle_delay) @(posedge vif_w.clk);
            end
            `DRIV_IF.hbusreq       <= 0;    
            `DRIV_IF.haddr         <= 0;    
            `DRIV_IF.htrans        <= 0;    
            `DRIV_IF.hwrite        <= 0;    
            `DRIV_IF.hsize         <= 0;    
            `DRIV_IF.hburst        <= 0;    
            `DRIV_IF.hprot         <= 0;    
            `DRIV_IF.hwdata        <= 0;    
            repeat(trans2trans_delay) @(posedge vif_w.clk);
        end
    endtask
endclass

