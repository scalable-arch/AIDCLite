module AIDC_LITE_COMP_ENGINE
(
    input   wire                        clk,
    input   wire                        rst_n,

    input   wire    [31:0]              src_addr_i,
    input   wire    [31:0]              dst_addr_i,
    input   wire    [31:7]              len_i,
    input   wire                        start_i,    // pulse
    output  logic                       done_o,     // level

    AHB2_MST_INTF.master                ahb_if,

    output  logic                       comp_wren_o,
    output  logic                       comp_sop_o,
    output  logic                       comp_eop_o,
    output  logic   [63:0]              comp_wdata_o,

    input   wire                        comp0_fail,
    input   wire                        comp1_fail,
    input   wire                        comp2_fail,
    input   wire                        comp_ready_i,
    output  logic                       comp_rden_o,
    input   wire    [31:0]              comp_rdata_i
);

    // A block: 128B data
    // - fetched from memory using two 4B x 16-beat accesses
    // - written to memory (in a compressed format) using one 4B x 16-beat access
    logic   [31:7]                      blk_cnt,    blk_cnt_n;
    // A beat: a single-cycle transfer (4B)
    // - beat_cnt increases from 0 to 31.
    //   - 0~15 belong to the first 16-beat acess
    //   - 16~31 belong to the second 16-beat access
    logic   [4:0]                       beat_cnt,   beat_cnt_n;
    logic                               beat_en;

    enum    logic   [3:0]   {
        S_IDLE,                         // 0
        S_RD1_BUSREQ,                   // 1, bus request (1st RD)
        S_RD1_1ST_ADDR,                 // 2, 1st addr phase (1st RD)
        S_RD1_MIDDLE,                   // 3, middle (addr+data) phases
        S_RD1_LAST_DATA,                // 4, last data phase (1st RD)
        S_RD2_BUSREQ,                   // 5, bus request (2nd RD)
        S_RD2_1ST_ADDR,                 // 6, 1st addr phase (2nd RD)
        S_RD2_MIDDLE,                   // 7, middle (addr+data) phases
        S_RD2_LAST_DATA,                // 8, last data phases (2nd RD)
        S_COMP,                         // 9, compression
        S_WR_BUSREQ,                    // 10, bus request (WR)
        S_WR_1ST_ADDR,                  // 11, 1st addr phase (WR)
        S_WR_MIDDLE,                    // 12, middle (addr+data) phases
        S_WR_LAST_DATA                  // 13, last data phase (WR)
    }                                   state,      state_n;

    logic                               hbusreq,    hbusreq_n;
    logic   [31:0]                      haddr,      haddr_n;
    logic   [1:0]                       htrans,     htrans_n;
    logic                               hwrite,     hwrite_n;

    logic                               comp_rden;

    //--------------------------------------------------------------------------------------
    // Timing diagram (part 1)
    //--------------------------------------------------------------------------------------
    // clk      : __--__--__--__--__--__--__-//-__--__--__--__--__--__--__-//_--__--__--____
    // start_i  : ___----____________________//____________________________//_______________

    // state    :  IDL  |  R1B  |1A |  MIDDLE//   |LAS|  R2B  |1A | MIDDLE //     |LAS|
    // beat_cnt :                   | 0 | 1 |//14 |15 |            16 |17 |// |30 |31 |
    // blk_ready: _____________________________________________________________________----_

    // hbusreq_o: _______--------____________//________--------_____________//______________
    // hgrant_i : ___________----____________//____________----_____________//______________
    // haddr_o  :               |+0 |+4 |+8 |//+60|           |+64|+68|+72| //+124|
    // hsize_o  :                         constant (4B)
    // hburst_o :                         constant (16-beat)
    // hready_i : _______________------------//-------________-------------//----------____

    always_comb begin
        state_n                         = state;

        blk_cnt_n                       = blk_cnt;
        beat_cnt_n                      = beat_cnt;

        hbusreq_n                       = hbusreq;
        haddr_n                         = haddr;
        htrans_n                        = htrans;
        hwrite_n                        = hwrite;

        beat_en                         = 1'b0;
        comp_rden                       = 1'b0;

        case (state)
            S_IDLE: begin
                if (start_i & (len_i!='d0)) begin
                    // reset block_cnt to zero
                    blk_cnt_n                       = 'd0;

                    // prepare asserting hbusreq on the next cycle (BUSREQ state)
                    hbusreq_n                       = 1'b1;

                    state_n                         = S_RD1_BUSREQ;
                end
            end
            S_RD1_BUSREQ: begin
                // request granted
                if (ahb_if.hgrant) begin
                    // deassert hbusreq
                    hbusreq_n                       = 1'b0;

                    // address phase part (prepation)
                    // set the address and SRC_ADDR + BLK_CNT*128
                    haddr_n                         = src_addr_i + {blk_cnt, 7'd0};
                    htrans_n                        = HTRANS_NONSEQ;
                    hwrite_n                        = 1'b0;

                    state_n                         = S_RD1_1ST_ADDR;
                end
            end
            S_RD1_1ST_ADDR: begin
                // address accepted
                if (ahb_if.hready) begin
                    // address phase part
                    haddr_n                         = haddr + 'd4;
                    htrans_n                        = HTRANS_SEQ;

                    // data phase part (preparation)
                    // reset the beat_cnt for the 1st data phase
                    beat_cnt_n                      = 'd0;

                    state_n                         = S_RD1_MIDDLE;
                end
            end
            S_RD1_MIDDLE: begin
                // receive data
                if (ahb_if.hready) begin
                    // address phase part
                    haddr_n                         = haddr + 'd4;

                    // data phase part
                    beat_en                         = 1'b1;
                    beat_cnt_n                      = beat_cnt + 'd1;

                    if (beat_cnt=='d14) begin
                        // last address (=last data - 1) of the access
                        htrans_n                        = HTRANS_IDLE;
                        state_n                         = S_RD1_LAST_DATA;
                    end
                end
            end
            S_RD1_LAST_DATA: begin
                // receive data
                if (ahb_if.hready) begin
                    // data phase part
                    beat_en                         = 1'b1;
                    beat_cnt_n                      = beat_cnt + 'd1;

                    hbusreq_n                       = 1'b1;

                    state_n                         = S_RD2_BUSREQ;
                end
            end
            S_RD2_BUSREQ: begin
                // request granted
                if (ahb_if.hgrant) begin
                    // deassert hbusreq
                    hbusreq_n                       = 1'b0;

                    // address phase part (prepation)
                    // continue using haddr and hwrite from the 1st access
                    htrans_n                        = HTRANS_NONSEQ;

                    state_n                         = S_RD2_1ST_ADDR;
                end
            end
            S_RD2_1ST_ADDR: begin
                // address accepted
                if (ahb_if.hready) begin
                    // address phase part
                    haddr_n                         = haddr + 'd4;
                    htrans_n                        = HTRANS_SEQ;

                    // data phase part (preparation)
                    // continue using beat_cnt from the 1st access

                    state_n                         = S_RD2_MIDDLE;
                end
            end
            S_RD2_MIDDLE: begin
                // receive data
                if (ahb_if.hready) begin
                    // address phase part
                    haddr_n                         = haddr + 'd4;

                    // data phase part
                    beat_en                         = 1'b1;
                    beat_cnt_n                      = beat_cnt + 'd1;

                    if (beat_cnt=='d30) begin
                        // last address (=last data - 1) of the access
                        htrans_n                        = HTRANS_IDLE;
                        state_n                         = S_RD2_LAST_DATA;
                    end
                end
            end
            S_RD2_LAST_DATA: begin
                // receive data
                if (ahb_if.hready) begin
                    // data phase part
                    beat_en                         = 1'b1;
                    beat_cnt_n                      = beat_cnt + 'd1;

                    state_n                         = S_COMP;
                end
            end
            S_COMP: begin
                // compression finished
                if (comp_ready_i) begin
                    hbusreq_n                       = 1'b1;
                    state_n                         = S_WR_BUSREQ;
                end
            end
            S_WR_BUSREQ: begin
                if (ahb_if.hgrant) begin
                    // deassert hbusreq
                    hbusreq_n                       = 1'b0;

                    // data phase part (preparation)
                    // set the address and SRC_ADDR + BLK_CNT*64
                    haddr_n                         = dst_addr_i + {blk_cnt, 6'd0};
                    htrans_n                        = HTRANS_NONSEQ;
                    hwrite_n                        = 1'b1;

                    state_n                         = S_WR_1ST_ADDR;
                end
            end
            S_WR_1ST_ADDR: begin
                // address accepted
                if (ahb_if.hready) begin
                    // address phase part
                    haddr_n                         = haddr + 'd4;
                    htrans_n                        = HTRANS_SEQ;

                    // data phase part (preparation)
                    // reset the beat_cnt for the 1st data phase
                    beat_cnt_n                      = 'd0;

                    state_n                         = S_WR_MIDDLE;
                end
            end
            S_WR_MIDDLE: begin
                // receive data
                if (ahb_if.hready) begin
                    // address phase part
                    haddr_n                         = haddr + 'd4;

                    // data phase part
                    comp_rden                       = 1'b1;
                    beat_cnt_n                      = beat_cnt + 'd1;

                    if (beat_cnt=='d14) begin
                        // last address (=last data - 1) of the access
                        htrans_n                        = HTRANS_IDLE;
                        state_n                         = S_WR_LAST_DATA;
                    end
                end
            end
            S_WR_LAST_DATA: begin
                // receive data
                if (ahb_if.hready) begin
                    // data phase part
                    comp_rden                       = 1'b1;
                    beat_cnt_n                      = beat_cnt + 'd1;

                    blk_cnt_n                       = blk_cnt + 'd1;
                    if (blk_cnt_n==len_i) begin
                        state_n                         = S_IDLE;
                    end
                    else begin
                        hbusreq_n                       = 1'b1;

                        state_n                         = S_RD1_BUSREQ;
                    end
                end
            end
        endcase
    end

    always_ff @(posedge clk)
        if (~rst_n) begin
            state                           <= S_IDLE;

            blk_cnt                         <= 'd0;
            beat_cnt                        <= 'd0;

            hbusreq                         <= 1'b0;
            haddr                           <= 'd0;
            htrans                          <= HTRANS_IDLE;
            hwrite                          <= 1'b0;
        end
        else begin
            state                           <= state_n;

            blk_cnt                         <= blk_cnt_n;
            beat_cnt                        <= beat_cnt_n;

            hbusreq                         <= hbusreq_n;
            haddr                           <= haddr_n;
            htrans                          <= htrans_n;
            hwrite                          <= hwrite_n;
        end

    //----------------------------------------------------------
    // from 32-bit data to 64-bit data
    //----------------------------------------------------------
    logic                               comp_wren,      comp_wren_n;
    logic                               comp_sop,       comp_sop_n;
    logic                               comp_eop,       comp_eop_n;
    logic   [63:0]                      comp_wdata,     comp_wdata_n;

    always_comb begin
        comp_wren_n                     = 1'b0;
        comp_sop_n                      = 1'bx;
        comp_eop_n                      = 1'bx;
        comp_wdata_n                    = comp_wdata;

        if (beat_en) begin
            if (beat_cnt[0]==1'b0) begin        // odd cycles
                comp_wdata_n[63:32]             = ahb_if.hrdata;
            end
            else begin
                comp_wren_n                     = 1'b1;
                comp_sop_n                      = (beat_cnt[4:1]=='d0);
                comp_eop_n                      = (beat_cnt[4:1]==4'hF);
                comp_wdata_n[31:0]              = ahb_if.hrdata;
            end
        end
    end

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            comp_wren                       <= 1'b0;
            comp_sop                        <= 'hx;
            comp_eop                        <= 'hx;
            comp_wdata                      <= 'hx;
        end
        else begin
            comp_wren                       <= comp_wren_n;
            comp_sop                        <= comp_sop_n;
            comp_eop                        <= comp_eop_n;
            comp_wdata                      <= comp_wdata_n;
        end
    end

    //----------------------------------------------------------
    // Output assignments
    //----------------------------------------------------------

    // !start_i condition is to prevent back-to-back CMD write
    // and STATUS read from mal-functioning.
    assign  done_o                          = (state==S_IDLE) & !start_i;

    assign  ahb_if.hbusreq                  = hbusreq;
    assign  ahb_if.haddr                    = haddr;
    assign  ahb_if.htrans                   = htrans;
    assign  ahb_if.hwrite                   = hwrite;
    assign  ahb_if.hsize                    = 3'b010;   // 4 byte;
    assign  ahb_if.hburst                   = 3'b111;   // 16-beat incrementing
    assign  ahb_if.hprot                    = 4'b0001;  // data access

    assign  comp_wren_o                     = comp_wren;
    assign  comp_sop_o                      = comp_sop;
    assign  comp_eop_o                      = comp_eop;
    assign  comp_wdata_o                    = comp_wdata;

endmodule
