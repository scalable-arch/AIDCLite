typedef enum {SR, ZRLE, BPC, NONE} CompType;

class CompData;
    rand    CompType        comp_type;
    rand    bit [31:0]      data[32];
    rand    bit [63:0]      zero_hword_vec;

    // constraint for sign-reduction data
    constraint  data_sr00_c { if (comp_type==SR) { data[00][31:23]=={9{data[00][22]}}; data[00][15:8]=={8{data[00][7]}}; } }
    constraint  data_sr01_c { if (comp_type==SR) { data[01][31:24]=={8{data[01][23]}}; data[01][15:8]=={8{data[01][7]}}; } }
    constraint  data_sr02_c { if (comp_type==SR) { data[02][31:24]=={8{data[02][23]}}; data[02][15:8]=={8{data[02][7]}}; } }
    constraint  data_sr03_c { if (comp_type==SR) { data[03][31:24]=={8{data[03][23]}}; data[03][15:8]=={8{data[03][7]}}; } }
    constraint  data_sr04_c { if (comp_type==SR) { data[04][31:24]=={8{data[04][23]}}; data[04][15:8]=={8{data[04][7]}}; } }
    constraint  data_sr05_c { if (comp_type==SR) { data[05][31:24]=={8{data[05][23]}}; data[05][15:8]=={8{data[05][7]}}; } }
    constraint  data_sr06_c { if (comp_type==SR) { data[06][31:24]=={8{data[06][23]}}; data[06][15:8]=={8{data[06][7]}}; } }
    constraint  data_sr07_c { if (comp_type==SR) { data[07][31:24]=={8{data[07][23]}}; data[07][15:8]=={8{data[07][7]}}; } }
    constraint  data_sr08_c { if (comp_type==SR) { data[08][31:24]=={8{data[08][23]}}; data[08][15:8]=={8{data[08][7]}}; } }
    constraint  data_sr09_c { if (comp_type==SR) { data[09][31:24]=={8{data[09][23]}}; data[09][15:8]=={8{data[09][7]}}; } }
    constraint  data_sr10_c { if (comp_type==SR) { data[10][31:24]=={8{data[10][23]}}; data[10][15:8]=={8{data[10][7]}}; } }
    constraint  data_sr11_c { if (comp_type==SR) { data[11][31:24]=={8{data[11][23]}}; data[11][15:8]=={8{data[11][7]}}; } }
    constraint  data_sr12_c { if (comp_type==SR) { data[12][31:24]=={8{data[12][23]}}; data[12][15:8]=={8{data[12][7]}}; } }
    constraint  data_sr13_c { if (comp_type==SR) { data[13][31:24]=={8{data[13][23]}}; data[13][15:8]=={8{data[13][7]}}; } }
    constraint  data_sr14_c { if (comp_type==SR) { data[14][31:24]=={8{data[14][23]}}; data[14][15:8]=={8{data[14][7]}}; } }
    constraint  data_sr15_c { if (comp_type==SR) { data[15][31:24]=={8{data[15][23]}}; data[15][15:8]=={8{data[15][7]}}; } }
    constraint  data_sr16_c { if (comp_type==SR) { data[16][31:24]=={8{data[16][23]}}; data[16][15:8]=={8{data[16][7]}}; } }
    constraint  data_sr17_c { if (comp_type==SR) { data[17][31:24]=={8{data[17][23]}}; data[17][15:8]=={8{data[17][7]}}; } }
    constraint  data_sr18_c { if (comp_type==SR) { data[18][31:24]=={8{data[18][23]}}; data[18][15:8]=={8{data[18][7]}}; } }
    constraint  data_sr19_c { if (comp_type==SR) { data[19][31:24]=={8{data[19][23]}}; data[19][15:8]=={8{data[19][7]}}; } }
    constraint  data_sr20_c { if (comp_type==SR) { data[20][31:24]=={8{data[20][23]}}; data[20][15:8]=={8{data[20][7]}}; } }
    constraint  data_sr21_c { if (comp_type==SR) { data[21][31:24]=={8{data[21][23]}}; data[21][15:8]=={8{data[21][7]}}; } }
    constraint  data_sr22_c { if (comp_type==SR) { data[22][31:24]=={8{data[22][23]}}; data[22][15:8]=={8{data[22][7]}}; } }
    constraint  data_sr23_c { if (comp_type==SR) { data[23][31:24]=={8{data[23][23]}}; data[23][15:8]=={8{data[23][7]}}; } }
    constraint  data_sr24_c { if (comp_type==SR) { data[24][31:24]=={8{data[24][23]}}; data[24][15:8]=={8{data[24][7]}}; } }
    constraint  data_sr25_c { if (comp_type==SR) { data[25][31:24]=={8{data[25][23]}}; data[25][15:8]=={8{data[25][7]}}; } }
    constraint  data_sr26_c { if (comp_type==SR) { data[26][31:24]=={8{data[26][23]}}; data[26][15:8]=={8{data[26][7]}}; } }
    constraint  data_sr27_c { if (comp_type==SR) { data[27][31:24]=={8{data[27][23]}}; data[27][15:8]=={8{data[27][7]}}; } }
    constraint  data_sr28_c { if (comp_type==SR) { data[28][31:24]=={8{data[28][23]}}; data[28][15:8]=={8{data[28][7]}}; } }
    constraint  data_sr29_c { if (comp_type==SR) { data[29][31:24]=={8{data[29][23]}}; data[29][15:8]=={8{data[29][7]}}; } }
    constraint  data_sr30_c { if (comp_type==SR) { data[30][31:24]=={8{data[30][23]}}; data[30][15:8]=={8{data[30][7]}}; } }
    constraint  data_sr31_c { if (comp_type==SR) { data[31][31:24]=={8{data[31][23]}}; data[31][15:8]=={8{data[31][7]}}; } }

    // constraint for zero-run-length-encoding data
    // one zero-half-word saves roughly 14 bits, so there should be at least 37 zero-half-words
    // to save 512 bits
    constraint  data_zrle_c { if (comp_type==ZRLE) { $countones(zero_hword_vec) > 37; } }


    function void post_randomize();
        for (int i=0; i<64; i=i+1) begin
            if (zero_hword_vec[i]) begin
                if (i%2==0) begin
                    data[i/2][31:16] = 0;
                end
                else begin
                    data[i/2][15:0] = 0;
                end
            end
        end
    endfunction

    function void display;
        for (int i=0; i<32; i=i+1) begin
            $display("%04x %04x", data[i][31:16], data[i][15:0]);
        end
    endfunction

endclass

class CompTransaction #(parameter int MAX=8);
    rand    CompType        comp_type;
    rand    int             blk_cnt;
    rand    CompData        blks[];

    constraint  comp_type_c     { comp_type inside {SR, ZRLE}; }
    //constraint  comp_type_c     { comp_type inside {ZRLE}; }
    constraint  blk_cnt_c       { blk_cnt > 0; blk_cnt < MAX; }
    constraint  blk_type_c      { foreach (blks[i]) blks[i].comp_type==comp_type; }

    function void pre_randomize();
        blks                 = new[MAX];
        foreach (blks[i])
            blks[i]              = new();
    endfunction

    function void display();
        $display("Comp Type   : ", comp_type);
        $display("Block Count : 0x%03x", blk_cnt);
        for (int i=0; i<blk_cnt; i=i+1) begin
            $display("Blk %d:", i);
            blks[i].display();
        end
    endfunction
endclass
