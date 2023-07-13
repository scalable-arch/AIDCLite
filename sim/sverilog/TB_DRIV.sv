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

        `DRIV_IF.wlast         <= 0;    // wi
        `DRIV_IF.wvalid        <= 0;    
        `DRIV_IF.wdata         <= 0;    
        `DRIV_IF.wstrb         <= 0;    
        
        wait (mst_ahb_if.rst_n);    // #5;
        $display("[ DRIVER ] ----- Reset Ended -----");
    endtask

    task run;    
        transaction trans;
        forever begin
            int cycle2cycle_delay = 0;
            int trans2trans_delay = 0;
            gen2driv.get(trans);
            for (int i=0; i<16; i=i+1) begin
                // drive data. The data will not change until it is received by ready.
                `DRIV_IF.wvalid               <= trans.valid;
                `DRIV_IF.wid                  <= trans.id;
                `DRIV_IF.wlast                <= (i==15);
                `DRIV_IF.wdata                <= trans.data[i];
                `DRIV_IF.wstrb                <= trans.strb & 8'b11111111;         // 8'b00000 0001 (라인별 1씩 shift) 
                @(posedge vif_w.clk);
                while (!`DRIV_IF_ICNT_W.wready) begin
                    @(posedge vif_w.clk);
                end
                `DRIV_IF.wvalid               <= 1'b0;
                `DRIV_IF.wid                  <= 'bx;
                `DRIV_IF.wlast                <= 1'bx;
                `DRIV_IF.wdata                <= 'hx;
                `DRIV_IF.wstrb                <= 'bx;
                repeat(cycle2cycle_delay) @(posedge vif_w.clk);
            end
            `DRIV_IF.wvalid               <= 1'b0;
            `DRIV_IF.wid                  <= 'bx;
            `DRIV_IF.wlast                <= 1'bx;
            `DRIV_IF.wdata                <= 'hx;
            `DRIV_IF.wstrb                <= 'bx;
            repeat(trans2trans_delay) @(posedge vif_w.clk);
        end
    endtask
endclass

