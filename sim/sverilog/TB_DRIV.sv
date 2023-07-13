`define DRIV_IF mst_ahb_if.master_tb.master_cb

class Driver; 
    virtual AHB2_MST_INTF   mst_ahb_if;
    
    mailbox gen_driv;
    
    function new(virtual AHB2_MST_INTF mst_ahb_if, mailbox gen_driv);
        this.mst_ahb_if         = mst_ahb_if;
        this.gen_driv           = gen_driv;
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
                ahb_if.m_read(i,trans.addr, trans.data);    
                repeat(cycle2cycle_delay) @(posedge mst_ahb_if.clk);
            end
            repeat(trans2trans_delay) @(posedge mst_ahb_if.clk);
        end
    endtask
endclass

