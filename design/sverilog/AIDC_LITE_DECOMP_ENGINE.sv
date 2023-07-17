`include "AHB2_PKG.svh"

import AHB2_PKG::*;

module AIDC_LITE_DECOMP_ENGINE
(
    input   wire                        clk,
    input   wire                        rst_n,

    input   wire    [31:0]              src_addr_i,
    input   wire    [31:0]              dst_addr_i,
    input   wire    [31:6]              len_i,
    input   wire                        start_i,    // pulse
    output  logic                       done_o,     // level

    AHB2_MST_INTF.master                ahb_if,

    output  logic                       decomp0_wren_o,
    output  logic                       decomp1_wren_o,
    output  logic                       decomp2_wren_o,
    output  logic                       decomp_sop_o,
    output  logic                       decomp_eop_o,
    output  logic   [31:0]              decomp_wdata_o,

    input   wire                        decomp_done_i,

    output  logic   [3:0]               buf_addr_o,
    input   wire    [63:0]              decomp_rdata_i
);

    // A block: 64B data
    // - fetched from memory using one 4B x 16-beat access
    // - written to memory (in the uncompressed format)
    //   using two 4B x 16-beat accesses
    logic   [31:6]                      blk_cnt,    blk_cnt_n;
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
        S_RD_BUSREQ,                    // 1, bus request (1st RD)
        S_RD_1ST_ADDR,                  // 2, 1st addr phase (1st RD)
        S_RD_MIDDLE,                    // 3, middle (addr+data) phases
        S_RD_LAST_DATA,                 // 4, last data phase (1st RD)
        S_DECOMP,                       // 5, compression
        S_WR1_BUSREQ,                   // 6, bus request (2nd RD)
        S_WR1_1ST_ADDR,                 // 7, 1st addr phase (2nd RD)
        S_WR1_MIDDLE,                   // 8, middle (addr+data) phases
        S_WR1_LAST_DATA,                // 9, last data phases (2nd RD)
        S_WR2_BUSREQ,                   // 10, bus request (WR)
        S_WR2_1ST_ADDR,                 // 11, 1st addr phase (WR)
        S_WR2_MIDDLE,                   // 12, middle (addr+data) phases
        S_WR2_LAST_DATA                 // 13, last data phase (WR)
    }                                   state,      state_n;

    logic                               hbusreq,    hbusreq_n;
    logic   [31:0]                      haddr,      haddr_n;
    logic   [1:0]                       htrans,     htrans_n;
    logic                               hwrite,     hwrite_n;
    logic   [31:0]                      hwdata,     hwdata_n;

    logic   [1:0]                       owner,      owner_n;

    //--------------------------------------------------------------------------------------
    // Timing diagram (part 1)
    //--------------------------------------------------------------------------------------
    // clk      : __--__--__--__--__--__--__-//-__--__--__--__--__--__--__--__--__--__--____
    // start_i  : ___----____________________//_____________________________________________

    // state    :  IDL  |  BUS  |1A |  MIDDLE//   |LAS|  DECOMP  |  BUS   |
    // beat_cnt :                   | 0 | 1 |//14 |15 |

    // hbusreq_o: _______--------------------//___________________---------------------_____
    // hgrant_i : ___________----------------//_______________________-----------------_____
    // haddr_o  :               |+0 |+4 |+8 |//+60|                       |+0 |+4 |+8 |
    // hsize_o  :                         constant (4B)
    // hburst_o :                         constant (16-beat)
    // hready_i : _______________------------//-------____________________-------------------

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

        case (state)
            S_IDLE: begin
                if (start_i & (len_i!='d0)) begin
                    // reset block_cnt to zero
                    blk_cnt_n                       = 'd0;

                    // prepare asserting hbusreq on the next cycle (BUSREQ state)
                    hbusreq_n                       = 1'b1;

                    state_n                         = S_RD_BUSREQ;
                end
            end
            S_RD_BUSREQ: begin
                // request granted
                if (ahb_if.hgrant) begin
                    // address phase part (prepation)
                    // set the address and SRC_ADDR + BLK_CNT*128
                    haddr_n                         = src_addr_i + {blk_cnt, 6'd0};
                    htrans_n                        = HTRANS_NONSEQ;
                    hwrite_n                        = 1'b0;

                    state_n                         = S_RD_1ST_ADDR;
                end
            end
            S_RD_1ST_ADDR: begin
                // address accepted
                if (ahb_if.hready) begin
                    // address phase part
                    haddr_n                         = haddr + 'd4;
                    htrans_n                        = HTRANS_SEQ;

                    // data phase part
                    // during a RD, beat_cnt counts data phases
                    beat_cnt_n                      = 'd0;

                    state_n                         = S_RD_MIDDLE;
                end
            end
            S_RD_MIDDLE: begin
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
                        state_n                         = S_RD_LAST_DATA;
                    end
                end
            end
            S_RD_LAST_DATA: begin
                // receive data
                if (ahb_if.hready) begin
                    // data phase part
                    beat_en                         = 1'b1;
                    beat_cnt_n                      = beat_cnt + 'd1;

                    state_n                         = S_DECOMP;
                end
            end
            S_DECOMP: begin
                if (decomp_done_i) begin
                    hbusreq_n                       = 1'b1;
                    state_n                         = S_WR1_BUSREQ;
                end
            end
            S_WR1_BUSREQ: begin
                // request granted
                if (ahb_if.hgrant) begin
                    // address phase part (prepation)
                    // continue using haddr and hwrite from the 1st access
                    //  x2 for block_cnt than source as destination contains
                    // expanded data
                    haddr_n                         = dst_addr_i + {blk_cnt[30:6], 7'd0};
                    htrans_n                        = HTRANS_NONSEQ;
                    hwrite_n                        = 1'b1;
                    // during a WR, beat_cnt counts for address phases
                    beat_cnt_n                      = 'd0;

                    state_n                         = S_WR1_1ST_ADDR;
                end
            end
            S_WR1_1ST_ADDR: begin
                // address accepted
                if (ahb_if.hready) begin
                    // address phase part
                    haddr_n                         = haddr + 'd4;
                    htrans_n                        = HTRANS_SEQ;
                    beat_cnt_n                      = beat_cnt + 'd1;

                    // data phase part
                    if (beat_cnt[0]) begin
                        hwdata_n                        = decomp_rdata_i[31:0];
                    end
                    else begin
                        hwdata_n                        = decomp_rdata_i[63:32];
                    end
                    state_n                         = S_WR1_MIDDLE;
                end
            end
            S_WR1_MIDDLE: begin
                // receive data
                if (ahb_if.hready) begin
                    // address phase part
                    haddr_n                         = haddr + 'd4;
                    beat_cnt_n                      = beat_cnt + 'd1;

                    // data phase part
                    if (beat_cnt[0]) begin
                        hwdata_n                        = decomp_rdata_i[31:0];
                    end
                    else begin
                        hwdata_n                        = decomp_rdata_i[63:32];
                    end

                    if (beat_cnt=='d14) begin
                        // deassert hbusreq
                        hbusreq_n                       = 1'b0;
                    end

                    if (beat_cnt=='d15) begin
                        // last address (=last data - 1) of the access
                        htrans_n                        = HTRANS_IDLE;
                        state_n                         = S_WR1_LAST_DATA;
                    end
                end
            end
            S_WR1_LAST_DATA: begin
                // receive data
                if (ahb_if.hready) begin
                    hbusreq_n                       = 1'b1;
                    state_n                         = S_WR2_BUSREQ;
                end
            end
            S_WR2_BUSREQ: begin
                if (ahb_if.hgrant) begin
                    // address phase part
                    // set the address and SRC_ADDR + BLK_CNT*64
                    htrans_n                        = HTRANS_NONSEQ;

                    state_n                         = S_WR2_1ST_ADDR;
                end
            end
            S_WR2_1ST_ADDR: begin
                // address accepted
                if (ahb_if.hready) begin
                    // address phase part
                    haddr_n                         = haddr + 'd4;
                    htrans_n                        = HTRANS_SEQ;

                    beat_cnt_n                      = beat_cnt + 'd1;

                    // data phase part
                    if (beat_cnt[0]) begin
                        hwdata_n                        = decomp_rdata_i[31:0];
                    end
                    else begin
                        hwdata_n                        = decomp_rdata_i[63:32];
                    end

                    state_n                         = S_WR2_MIDDLE;
                end
            end
            S_WR2_MIDDLE: begin
                // receive data
                if (ahb_if.hready) begin
                    // address phase part
                    haddr_n                         = haddr + 'd4;
                    beat_cnt_n                      = beat_cnt + 'd1;

                    // data phase part
                    if (beat_cnt[0]) begin
                        hwdata_n                        = decomp_rdata_i[31:0];
                    end
                    else begin
                        hwdata_n                        = decomp_rdata_i[63:32];
                    end

                    if (beat_cnt=='d30) begin
                        // deassert hbusreq
                        hbusreq_n                       = 1'b0;
                    end

                    if (beat_cnt=='d31) begin
                        // last address (=last data - 1) of the access
                        htrans_n                        = HTRANS_IDLE;
                        state_n                         = S_WR2_LAST_DATA;
                    end
                end
            end
            default: begin //S_WR2_LAST_DATA: begin
                // receive data
                if (ahb_if.hready) begin
                    // data phase part
                    blk_cnt_n                       = blk_cnt + 'd1;
                    if (blk_cnt_n==len_i) begin
                        state_n                         = S_IDLE;
                    end
                    else begin
                        hbusreq_n                       = 1'b1;

                        state_n                         = S_RD_BUSREQ;
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
        end

    //----------------------------------------------------------
    // from 32-bit data to 64-bit data
    //----------------------------------------------------------
    logic                               decomp0_wren,   decomp0_wren_n;
    logic                               decomp1_wren,   decomp1_wren_n;
    logic                               decomp2_wren,   decomp2_wren_n;
    logic                               decomp_sop,     decomp_sop_n;
    logic                               decomp_eop,     decomp_eop_n;
    logic   [31:0]                      decomp_wdata,   decomp_wdata_n;

    always_comb begin
        decomp0_wren_n                  = 1'b0;
        decomp1_wren_n                  = 1'b0;
        decomp2_wren_n                  = 1'b0;
        decomp_sop_n                    = 1'b0;
        decomp_eop_n                    = 1'b0;
        decomp_wdata_n                  = decomp_wdata;
        owner_n                         = owner;

        if (beat_en) begin
            if (beat_cnt[4:0]=='d0) begin
                if (ahb_if.hrdata[31]==1'b1) begin
                    owner_n                         = 2'd0;
                end
                else if (ahb_if.hrdata[30]==1'b0) begin
                    owner_n                         = 2'd1;
                end
                else begin
                    owner_n                         = 2'd2;
                end
            end

            decomp0_wren_n                  = (owner_n==2'd0);
            decomp1_wren_n                  = (owner_n==2'd1);
            decomp2_wren_n                  = (owner_n==2'd2);
            decomp_sop_n                    = (beat_cnt[3:0]==4'h0);
            decomp_eop_n                    = (beat_cnt[3:0]==4'hF);
            decomp_wdata_n                  = ahb_if.hrdata;
        end
    end

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            decomp0_wren                    <= 1'b0;
            decomp1_wren                    <= 1'b0;
            decomp2_wren                    <= 1'b0;
            decomp_sop                      <= 1'b0;
            decomp_eop                      <= 1'b0;
            decomp_wdata                    <= 32'd0;
            owner                           <= 2'd0;
        end
        else begin
            decomp0_wren                    <= decomp0_wren_n;
            decomp1_wren                    <= decomp1_wren_n;
            decomp2_wren                    <= decomp2_wren_n;
            decomp_sop                      <= decomp_sop_n;
            decomp_eop                      <= decomp_eop_n;
            decomp_wdata                    <= decomp_wdata_n;
            owner                           <= owner_n;
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

    assign  decomp0_wren_o                  = decomp0_wren;
    assign  decomp1_wren_o                  = decomp1_wren;
    assign  decomp2_wren_o                  = decomp2_wren;
    assign  decomp_sop_o                    = decomp_sop;
    assign  decomp_eop_o                    = decomp_eop;
    assign  decomp_wdata_o                  = decomp_wdata;

    assign  buf_addr_o                      = beat_cnt[4:1];

endmodule
