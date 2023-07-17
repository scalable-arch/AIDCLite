`include "AHB2_PKG.svh"

use AHB2_PKG::*;

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

    input   wire                        comp0_done_i,
    input   wire                        comp1_done_i,
    input   wire                        comp2_done_i,
    input   wire                        comp0_fail_i,
    input   wire                        comp1_fail_i,
    input   wire                        comp2_fail_i,

    output  logic   [2:0]               buf_addr_o,
    input   wire    [63:0]              comp0_rdata_i,
    input   wire    [63:0]              comp1_rdata_i,
    input   wire    [63:0]              comp2_rdata_i
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

    //----------------------------------------------------------
    // Each access has 4 states: BUSREQ, 1ST_ADDR, MIDDLE, and LAST_DATA
    // BUSREQ: asserting hbusreq, waiting for hgrant
    // AHB address phase: | 0 | 1 | 2 | ... |14 |15 |
    // AHB data phase   : |   | 0 | 1 | ... |13 |14 |15 |
    // internal state   :   | |       MIDDLE          |
    //                   1ST_ADDR                 LAST_DATA
    // 1ST_ADDR: the first address phase
    // MIDDLE: middle phases (both address and data phase arrive)
    // LAST_DATA: the last data phase
    //----------------------------------------------------------
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
    logic   [31:0]                      hwdata,     hwdata_n;

    logic   [1:0]                       owner,      owner_n;
    wire    [63:0]                      owner_data;

    assign  owner_data                  = (owner==2'd2) ? comp2_rdata_i :
                                          (owner==2'd1) ? comp1_rdata_i : comp0_rdata_i;

    //--------------------------------------------------------------------------------------
    // Timing diagram (part 1)
    //--------------------------------------------------------------------------------------
    // clk      : __--__--__--__--__--__--__-//-__--__--__--__--__--__--__-//_--__--__--____
    // start_i  : ___----____________________//____________________________//_______________

    // state    :  IDL  |  R1B  |1A |  MIDDLE//   |LAS|  R2B  |1A | MIDDLE //     |LAS|
    // beat_cnt :                   | 0 | 1 |//14 |15 |            16 |17 |// |30 |31 |

    // hbusreq_o: _______--------------------//________--------------------//______________
    // hgrant_i : ___________----------------//____________----------------//______________
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
        hwdata_n                        = hwdata;

        beat_en                         = 1'b0;

        owner_n                         = owner;

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

                    // data phase part
                    // during a RD, beat_cnt counts data phases
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

                    if (beat_cnt=='d13) begin
                        // deassert hbusreq
                        hbusreq_n                       = 1'b0;
                    end
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

                    if (beat_cnt=='d29) begin
                        // deassert hbusreq
                        hbusreq_n                       = 1'b0;
                    end

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
                if (comp0_done_i & comp1_done_i & comp2_done_i) begin
                    // compression finished
                    if (!comp0_fail_i) begin
                        owner_n                         = 2'd0;
                    end
                    else if (!comp1_fail_i) begin
                        owner_n                         = 2'd1;
                    end
                    else if (!comp2_fail_i) begin
                        owner_n                         = 2'd2;
                    end
                    else begin  // if everything fails, use 0
                        owner_n                         = 2'd0;
                    end

                    hbusreq_n                       = 1'b1;
                    state_n                         = S_WR_BUSREQ;
                end
            end
            S_WR_BUSREQ: begin
                if (ahb_if.hgrant) begin
                    // address phase part
                    // set the address and SRC_ADDR + BLK_CNT*64
                    haddr_n                         = dst_addr_i + {blk_cnt, 6'd0};
                    htrans_n                        = HTRANS_NONSEQ;
                    hwrite_n                        = 1'b1;
                    // during a WR, beat_cnt counts for address phases
                    beat_cnt_n                      = 'd0;

                    state_n                         = S_WR_1ST_ADDR;
                end
            end
            S_WR_1ST_ADDR: begin
                // address accepted
                if (ahb_if.hready) begin
                    // address phase part
                    haddr_n                         = haddr + 'd4;
                    htrans_n                        = HTRANS_SEQ;
                    beat_cnt_n                      = beat_cnt + 'd1;

                    // data phase part
                    if (beat_cnt[0]) begin
                        hwdata_n                        = owner_data[31:0];
                    end
                    else begin
                        hwdata_n                        = owner_data[63:32];
                    end

                    state_n                         = S_WR_MIDDLE;
                end
            end
            S_WR_MIDDLE: begin
                // receive data
                if (ahb_if.hready) begin
                    // address phase part
                    haddr_n                         = haddr + 'd4;
                    beat_cnt_n                      = beat_cnt + 'd1;

                    // data phase part
                    if (beat_cnt[0]) begin
                        hwdata_n                        = owner_data[31:0];
                    end
                    else begin
                        hwdata_n                        = owner_data[63:32];
                    end

                    if (beat_cnt=='d14) begin
                        // deassert hbusreq
                        hbusreq_n                       = 1'b0;
                    end

                    if (beat_cnt=='d15) begin
                        // last address (=last data - 1) of the access
                        htrans_n                        = HTRANS_IDLE;
                        state_n                         = S_WR_LAST_DATA;
                    end
                end
            end
            default: begin //S_WR_LAST_DATA: begin
                // receive data
                if (ahb_if.hready) begin
                    // data phase part
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
            haddr                           <= 32'd0;
            htrans                          <= HTRANS_IDLE;
            hwrite                          <= 1'b0;
            hwdata                          <= 32'd0;

            owner                           <= 2'd0;
        end
        else begin
            state                           <= state_n;

            blk_cnt                         <= blk_cnt_n;
            beat_cnt                        <= beat_cnt_n;

            hbusreq                         <= hbusreq_n;
            haddr                           <= haddr_n;
            htrans                          <= htrans_n;
            hwrite                          <= hwrite_n;
            hwdata                          <= hwdata_n;

            owner                           <= owner_n;
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
        comp_sop_n                      = 1'b0;
        comp_eop_n                      = 1'b0;
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
            comp_sop                        <= 1'b0;
            comp_eop                        <= 1'b0;
            comp_wdata                      <= 'h0;
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
    assign  ahb_if.hsize                    = HSIZE_32BITS;
    assign  ahb_if.hburst                   = HBURST_INCR16;
    assign  ahb_if.hprot                    = 4'b0001;  // data access
    assign  ahb_if.hwdata                   = hwdata;

    assign  comp_wren_o                     = comp_wren;
    assign  comp_sop_o                      = comp_sop;
    assign  comp_eop_o                      = comp_eop;
    assign  comp_wdata_o                    = comp_wdata;

    assign  buf_addr_o                      = beat_cnt[3:1];

endmodule
