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

    output  logic                       buf_wren_o,
    output  logic   [3:0]               buf_waddr_o,
    output  logic   [7:0]               buf_wbe_o,  // byte_enable
    output  logic   [63:0]              buf_wdata_o,

    output  logic                       comp_start_o,
    input   wire                        comp_ready_i,
    output  logic                       comp_rden_o,
    input   wire    [31:0]              comp_rdata_i
);

    // A block: 128B data
    // - fetched from memory using two 4B x 16-beat accesses
    // - written to memory (in a compressed format) using one 4B x 16-beat access
    logic   [24:7]                      blk_cnt,    blk_cnt_n;
    // A beat: a single-cycle transfer (4B)
    // - beat_cnt increases from 0 to 31.
    //   - 0~15 belong to the first 16-beat acess
    //   - 16~31 belong to the second 16-beat access
    logic   [4:0]                       beat_cnt,   beat_cnt_n;

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

    logic                               buf_wren;
    logic   [3:0]                       buf_waddr;
    logic   [7:0]                       buf_wbe;
    logic   [63:0]                      buf_wdata;

    logic                               blk_ready_pulse, blk_ready_pulse_n;
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
        blk_ready_pulse_n               = 1'b0;

        hbusreq_n                       = hbusreq;
        haddr_n                         = haddr;
        htrans_n                        = htrans;
        hwrite_n                        = hwrite;

        // to write 32-bit data to 64b-wide buffer
        buf_wren                        = 1'b0;
        buf_waddr                       = beat_cnt[3:0];
        buf_wbe                         = { {4{!beat_cnt[0]}}, {4{beat_cnt[0]}} };
        buf_wdata                       = {ahb_if.hrdata, ahb_if.hrdata};

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
                    haddr_n                         = haddr + 'd4;
                    htrans_n                        = HTRANS_SEQ;
                    // reset the beat_cnt for the 1st data phase
                    beat_cnt_n                      = 'd0;

                    state_n                         = S_RD1_MIDDLE;
                end
            end
            S_RD1_MIDDLE: begin
                // receive data
                if (ahb_if.hready) begin
                    haddr_n                         = haddr + 'd4;
                    buf_wren                        = 1'b1;
                    beat_cnt_n                      = beat_cnt + 'd1;

                    if (beat_cnt=='d14) begin
                        // last address (=last data - 1) of the 1st access
                        htrans_n                        = HTRANS_IDLE;
                        state_n                         = S_RD1_LAST_DATA;
                    end
                end
            end
            S_RD1_LAST_DATA: begin
                // receive data
                if (ahb_if.hready) begin
                    buf_wren                        = 1'b1;
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

                    htrans_n                        = HTRANS_NONSEQ;

                    state_n                         = S_RD2_1ST_ADDR;
                end
            end
            S_RD2_1ST_ADDR: begin
                // address accepted
                if (ahb_if.hready) begin
                    haddr_n                         = haddr + 'd4;
                    htrans_n                        = HTRANS_SEQ;

                    state_n                         = S_RD2_MIDDLE;
                end
            end
            S_RD2_MIDDLE: begin
                // receive data
                if (ahb_if.hready) begin
                    haddr_n                         = haddr + 'd4;
                    buf_wren                        = 1'b1;
                    beat_cnt_n                      = beat_cnt + 'd1;

                    if (beat_cnt=='d30) begin
                        // last address (=last data - 1) of the 2nd access
                        htrans_n                        = HTRANS_IDLE;
                        state_n                         = S_RD2_LAST_DATA;
                    end
                end
            end
            S_RD2_LAST_DATA: begin
                // receive data
                if (ahb_if.hready) begin
                    buf_wren                        = 1'b1;
                    beat_cnt_n                      = beat_cnt + 'd1;

                    blk_ready_pulse_n               = 1'b1;

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
                    haddr_n                         = haddr + 'd4;
                    htrans_n                        = HTRANS_SEQ;
                    // reset the beat_cnt for the 1st data phase
                    beat_cnt_n                      = 'd0;

                    state_n                         = S_WR_MIDDLE;
                end
            end
            S_WR_MIDDLE: begin
                // receive data
                if (ahb_if.hready) begin
                    haddr_n                         = haddr + 'd4;
                    comp_rden                       = 1'b1;
                    beat_cnt_n                      = beat_cnt + 'd1;

                    if (beat_cnt=='d14) begin
                        // last address beat of the 1st access
                        htrans_n                        = HTRANS_IDLE;
                        state_n                         = S_WR_LAST_DATA;
                    end
                end
            end
            S_WR_LAST_DATA: begin
                // receive data
                if (ahb_if.hready) begin
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
            blk_ready_pulse                 <= 'd0;

            hbusreq                         <= 1'b0;
            haddr                           <= 'd0;
            htrans                          <= HTRANS_IDLE;
            hwrite                          <= 1'b0;
        end
        else begin
            state                           <= state_n;

            blk_cnt                         <= blk_cnt_n;
            beat_cnt                        <= beat_cnt_n;
            blk_ready_pulse                 <= blk_ready_pulse;

            hbusreq                         <= hbusreq_n;
            haddr                           <= haddr_n;
            htrans                          <= htrans_n;
            hwrite                          <= hwrite_n;
        end

    assign  done_o                          = (state==S_IDLE);

    assign  buf_wren_o                      = buf_wren;
    assign  buf_waddr_o                     = buf_waddr;
    assign  buf_wbe_o                       = buf_wbe;
    assign  buf_wdata_o                     = ahb_if.hrdata;

    assign  comp_start_o                    = blk_ready_pulse;

    assign  ahb_if.hbusreq                  = hbusreq;
    assign  ahb_if.haddr                    = haddr;
    assign  ahb_if.htrans                   = htrans;
    assign  ahb_if.hwrite                   = hwrite;
    assign  ahb_if.hsize                    = 3'b010;   // 4 byte;
    assign  ahb_if.hburst                   = 3'b111;   // 16-beat incrementing
    assign  ahb_if.hprot                    = 4'b0001;  // data access

endmodule
