module AIDC_LITE_DECOMP_TOP
(
    input   wire                        clk,
    input   wire                        rst_n,

    AHB2_MST_INTF.master                ahb_if,

    APB_INTF.slave                      apb_if
);

    wire    [31:0]                      cfg_src_addr;
    wire    [31:0]                      cfg_dst_addr;
    wire    [31:6]                      cfg_len;
    wire                                cfg_start;
    wire                                cfg_done;

    AIDC_LITE_DECOMP_CFG                u_cfg
    (
        .clk                            (clk),
        .rst_n                          (rst_n),

        .apb_if                         (apb_if),

        .src_addr_o                     (cfg_src_addr),
        .dst_addr_o                     (cfg_dst_addr),
        .len_o                          (cfg_len),
        .start_o                        (cfg_start),
        .done_i                         (cfg_done)
    );

    wire                                decomp0_wren,
                                        decomp1_wren,
                                        decomp2_wren;
    wire                                decomp_sop;
    wire                                decomp_eop;
    wire    [63:0]                      decomp_wdata;

    logic   [3:0]                       buf_addr;
    wire    [63:0]                      decomp_rdata;

    AIDC_LITE_DECOMP_ENGINE             u_engine
    (
        .clk                            (clk),
        .rst_n                          (rst_n),

        .src_addr_i                     (cfg_src_addr),
        .dst_addr_i                     (cfg_dst_addr),
        .len_i                          (cfg_len),
        .start_i                        (cfg_start),
        .done_o                         (cfg_done),

        .ahb_if                         (ahb_if),

        .decomp0_wren_o                 (decomp0_wren),
        .decomp1_wren_o                 (decomp1_wren),
        .decomp2_wren_o                 (decomp2_wren),
        .decomp_sop_o                   (decomp_sop),
        .decomp_eop_o                   (decomp_eop),
        .decomp_wdata_o                 (decomp_wdata),

        .decomp_done_i                  (1'b1),

        .buf_addr_o                     (buf_addr),
        .decomp_data_i                  (decomp_rdata)
    );

    /*
    AIDC_LITE_COMP_SR                   u_sr
    (
        .clk                            (clk),
        .rst_n                          (rst_n),

        .valid_i                        (comp_wren),
        .sop_i                          (comp_sop),
        .eop_i                          (comp_eop),
        .data_i                         (comp_wdata),

        .valid_o                        (sr_buf_wren),
        .addr_o                         (sr_buf_waddr),
        .data_o                         (sr_buf_wdata),
        .done_o                         (sr_done),
        .fail_o                         (sr_fail)
    );

    AIDC_LITE_COMP_BUFFER               u_sr_buffer
    (
        .clk                            (clk),
        .rst_n                          (rst_n),

        .wren_i                         (sr_buf_wren),
        .waddr_i                        (sr_buf_waddr),
        .wdata_i                        (sr_buf_wdata),

        .raddr_i                        (buf_addr),
        .rdata_o                        (sr_buf_rdata)
    );

    AIDC_LITE_COMP_ZRLE                 u_zrle
    (
        .clk                            (clk),
        .rst_n                          (rst_n),

        .valid_i                        (comp_wren),
        .sop_i                          (comp_sop),
        .eop_i                          (comp_eop),
        .data_i                         (comp_wdata),

        .valid_o                        (zrle_buf_wren),
        .addr_o                         (zrle_buf_waddr),
        .data_o                         (zrle_buf_wdata),
        .done_o                         (zrle_done),
        .fail_o                         (zrle_fail)
    );

    AIDC_LITE_COMP_BUFFER               u_zrle_buffer
    (
        .clk                            (clk),
        .rst_n                          (rst_n),

        .wren_i                         (zrle_buf_wren),
        .waddr_i                        (zrle_buf_waddr),
        .wdata_i                        (zrle_buf_wdata),

        .raddr_i                        (buf_addr),
        .rdata_o                        (zrle_buf_rdata)
    );

    wire                                bpc_buf_wren;
    wire    [2:0]                       bpc_buf_waddr;
    wire    [63:0]                      bpc_buf_wdata;
    wire                                bpc_done;
    wire                                bpc_fail;

    AIDC_LITE_COMP_BPC                  u_bpc
    (
        .clk                            (clk),
        .rst_n                          (rst_n),

        .valid_i                        (comp_wren),
        .sop_i                          (comp_sop),
        .eop_i                          (comp_eop),
        .data_i                         (comp_wdata),

        .valid_o                        (bpc_buf_wren),
        .addr_o                         (bpc_buf_waddr),
        .data_o                         (bpc_buf_wdata),
        .done_o                         (bpc_done),
        .fail_o                         (bpc_fail)
    );
    */

endmodule
