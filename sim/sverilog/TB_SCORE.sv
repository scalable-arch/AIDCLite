class scoreboard;
    
    mailbox gen_score;
    mailbox mon_score;
    int i, j;
    bit [63:0] mem [16][492];

    function new(mailbox gen_score, mailbox mon_score);
        this.gen_score              = gen_score;
        this.mon_score              = mon_score;
        foreach(mem[i][j]) mem[i][j] = 64'h0;
    endfunction

    task run;
        transaction trans_gen;
        transaction trans_mon;
        # 20;
        for (j=1;j<493; j++) begin
            gen_score.get(trans_gen);
            for (i=0;i<16; i++) begin
                mem[i][j] = trans_gen.data[i];
                $display($time,"\tmem[%0d][%0d] = %h", i, j, trans_gen.data[i]);
            end
        end
        j=1;
        forever begin
            mon_score.get(trans_mon);
            for(i=0;i<16;i++) begin
                $display($time,"\ttrans_mon.data[%0d] = %h", i, trans_mon.data[i]);
                if((mem[i][j] == trans_mon.data[i])) $display("Okay, data[%0d][%0d] = %h", i, j, trans_mon.data[i]);
                else $display("Error, mem[%0d][%0d] = %h, trans_mon[%0d][%0d] = %h",i,j,mem[i][j], i,j, trans_mon[i]);
                #10;
            end
            j++;
        end
    endtask
endclass
