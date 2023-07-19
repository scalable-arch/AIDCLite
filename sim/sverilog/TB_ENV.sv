class ahb_env;
    
    // TB Subclass
    Generator           gen;
    Driver              driv;
    Monitor             mon;
    Scoreboard          score;

    // TB Communication mechanism for exchanging messages
    mailbox             gen_driv;
    mailbox             gen_score;
    mailbox             mon_score;

    // Virtual interface
    virtual AHB2_MST_INTF               mst_ahb_if;
    virtual AHB2_SLV_INTF               slv_ahb_if;

    function new(
        virtual AHB_MST_INTF            mst_ahb_if,
        virtual AHB_SLV_INTF            slv_ahb_if,
        );
        this.mst_ahb_if     = mst_ahb_if;
        this.slv_ahb_if     = slv_ahb_if;
    endfunction

    task init();
        gen_driv        = new();
        gen_score       = new();
        mon_score       = new();
        

        gen             = new(gen_driv, gen_score);
        driv            = new(mst_ahb_if, gen_driv);
        mon             = new(slv_ahb_if, mon_score);
        score           = new(gen_score, mon_score);
    endtask

    task reset();
        driv.reset();
    endtask

    task run();
        transaction trans;
        init();
        reset();
        
        fork
            driv.run();
            mon.run();
            score.run();
        join_any
        #100000;
    endtask
endclass

class apb_env; 

    // Virtual interface
    virtual APB_INTF                    apb_if;
    
    function new(
        virtual APB_INTF                apb_if
        );
        this.apb_if         = apb_if;
    endfunction
    
    task apb_reset();
        apb_if.reset_master();
    endtask

    task apb_write(
            input [31:0]  src_addr,
            input [31:0]  dst_addr,
            input [31:0]  len
        );
        repeat (10) @(posedge clk);
        apb_if.write(32'h0, src_addr); 
        apb_if.write(32'h4, dst_addr);  
        apb_if.write(32'h8, len); 
        apb_if.write(32'hC, 32'd1);
    endtask

    task apb_read(logic [31:0] rdata);
        for (int i=0; i<10000; i++) begin
            apb_if.read(32'h10, rdata);
            if(rdata=32'h1)begin
                break;
            end
            $write(".");
            repeat (100) @(posedge clk);
        end
        $display(""); // new line
        repeat (50) @(posedge clk);

        $display("--------------------------------------------------");
        $display("APB_command completed");
        $display("--------------------------------------------------");
    endtask

    task run(
        input [31:0]  src_addr,
        input [31:0]  dst_addr,
        input [31:0]  len
        );
        logic [31:0] rdata;
        apb_reset();
        
        apb_write(src_addr, dst_addr, len);
        apb_read(rdata);
    endtask
endclass

