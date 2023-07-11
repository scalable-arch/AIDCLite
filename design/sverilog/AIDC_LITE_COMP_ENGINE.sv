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
    output  logic   [31:0]              buf_wdata_o
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
        S_RD1_ADDR_PHASE,               // 2, addr phase (1st RD)
        S_RD1_DATA_PHASES,              // 3, data phases (1st RD), 16 beats
        S_RD2_BUSREQ,                   // 4, bus request (2nd RD)
        S_RD2_ADDR_PHASE,               // 5, addr phase (2nd RD)
        S_RD2_DATA_PHASES,              // 6, data phases (2nd RD), 16 beats
        S_COMP,                         // 7, compression
        S_WR_BUSREQ,                    // 8, bus request (WR)
        S_WR_ADDR_PHASE,                // 9, addr phase (WR)
        S_WR_DATA_PHASES                // 10, data phases (WR), 16 beats
    }                                   state,      state_n;

    logic                               hbusreq,    hbusreq_n;
    logic   [31:0]                      haddr,      haddr_n;

    logic                               buf_wren;
    logic                               blk_ready_pulse, blk_ready_pulse_n;

    //----------------------------------------------------------------------------------
    // Timing diagram (part 1)
    //----------------------------------------------------------------------------------
    // clk      : __--__--__--__--__--__--__--//__--__--__--__--__--__--__--//__--__--__
    // start_i  : ___----_____________________//____________________________//__________

    // state    :  IDL  |  R1B  |R1A|    R1D  //      |  R2B  |R2A|   R2D   // R2D  |
    // beat_cnt :               | 0 | 1 | 2 | //  |15 |       |16 |17 |18 | //  |31 |

    // hbusreq_o: _______--------_____________//_______--------_____________//__________
    // hgrant_i : ___________----_____________//___________----_____________//__________
    // haddr_o  :               |SA |+4 |+8 | //  |+60|       |+64|+68|+62| // |+124|
    // hsize_o  :                         constant (4B)
    // hburst_o :                         constant (16-beat)
    // hready_i : _______________-------------//-------________-------------//-------___

    always_comb begin
        state_n                         = state;

        blk_cnt_n                       = blk_cnt;
        beat_cnt_n                      = beat_cnt;
        blk_ready_pulse_n               = 1'b0;

        hbusreq_n                       = hbusreq;
        haddr_n                         = haddr;

        buf_wren                        = 1'b0;

        case (state)
            S_IDLE: begin
                if (start_i & (len_i!='d0)) begin
                    blk_cnt_n                       = 'd0;
                    beat_cnt_n                      = 'd0;

                    hbusreq_n                       = 1'b1;

                    state_n                         = S_RD1_BUSREQ;
                end
            end
            S_RD1_BUSREQ: begin
                // request granted
                if (ahb_if.hgrant) begin
                    hbusreq_n                       = 1'b0;
                    haddr_n                         = src_addr_i + {blk_cnt, 7'd0};

                    state_n                         = S_RD1_ADDR_PHASE;
                end
            end
            S_RD1_ADDR_PHASE: begin
                // address accepted
                if (ahb_if.hready) begin
                    haddr_n                         = haddr + 'd4;
                    state_n                         = S_RD1_DATA_PHASES;
                end
            end
            S_RD1_DATA_PHASES: begin
                // receive data
                if (ahb_if.hready) begin
                    haddr_n                         = haddr + 'd4;
                    buf_wren                        = 1'b1;
                    if (beat_cnt=='d15) begin
                        hbusreq_n                       = 1'b1;

                        state_n                         = S_RD2_BUSREQ;
                    end
                end
            end
            S_RD2_BUSREQ: begin
                // request granted
                if (ahb_if.hgrant) begin
                    hbusreq_n                       = 1'b0;

                    state_n                         = S_RD2_ADDR_PHASE;
                end
            end
            S_RD2_ADDR_PHASE: begin
                // address accepted
                if (ahb_if.hready) begin
                    haddr_n                         = haddr + 'd4;
                    state_n                         = S_RD2_DATA_PHASES;
                end
            end
            S_RD2_DATA_PHASES: begin
                // receive data
                if (ahb_if.hready) begin
                    haddr_n                         = haddr + 'd4;
                    buf_wren                        = 1'b1;
                    if (beat_cnt=='d31) begin
                        blk_ready_pulse_n               = 1'b1;
                        state_n                         = S_COMP;
                    end
                end
            end
            S_COMP: begin
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
        end
        else begin
            state                           <= state_n;

            blk_cnt                         <= blk_cnt_n;
            beat_cnt                        <= beat_cnt_n;
            blk_ready_pulse                 <= blk_ready_pulse;

            hbusreq                         <= hbusreq_n;
            haddr                           <= haddr_n;
        end

endmodule
