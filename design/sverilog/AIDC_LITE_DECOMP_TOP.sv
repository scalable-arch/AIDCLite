import  AIDC_LITE_DECOMP_CFG_pkg::*;

`include "AIDC_LITE_VERSION.svh"

module AIDC_LITE_DECOMP_TOP
(
    input   wire                        clk,
    input   wire                        rst_n,

    AHB2_MST_INTF.master                ahb_if,

    APB_INTF.slave                      apb_if
);

    wire    AIDC_LITE_DECOMP_CFG__in_t  cfg_hwif_in;
    wire    AIDC_LITE_DECOMP_CFG__out_t cfg_hwif_out;

    AIDC_LITE_DECOMP_CFG                u_cfg
    (
        .clk                            (clk),
        .rst_n                          (rst_n),

        .s_apb_psel                     (apb_if.psel),
        .s_apb_penable                  (apb_if.penable),
        .s_apb_pwrite                   (apb_if.pwrite),
        .s_apb_paddr                    (apb_if.paddr[5:0]),
        .s_apb_pwdata                   (apb_if.pwdata),
        .s_apb_pready                   (apb_if.pready),
        .s_apb_prdata                   (apb_if.prdata),
        .s_apb_pslverr                  (apb_if.pslverr),

        .hwif_in                        (cfg_hwif_in),
        .hwif_out                       (cfg_hwif_out)
    );

    assign  cfg_hwif_in.VERSION.MAJOR.next  = `AIDC_LITE_VERSION_MAJOR;
    assign  cfg_hwif_in.VERSION.MINOR.next  = `AIDC_LITE_VERSION_MINOR;
    assign  cfg_hwif_in.VERSION.MICRO.next  = `AIDC_LITE_VERSION_MICRO;
    assign  cfg_hwif_in.GIT.HASH.next       = `AIDC_LITE_GIT_HASH;

    wire                                decomp0_wren,
                                        decomp1_wren;
    wire                                decomp_sop;
    wire                                decomp_eop;
    wire    [31:0]                      decomp_wdata;

    wire                                sr_buf_wren;
    wire    [3:0]                       sr_buf_waddr;
    wire    [63:0]                      sr_buf_wdata;
    wire                                sr_done;

    wire                                zrle_buf_wren;
    wire    [3:0]                       zrle_buf_waddr;
    wire    [63:0]                      zrle_buf_wdata;
    wire                                zrle_done;

    logic   [3:0]                       buf_addr;
    wire    [63:0]                      buf_rdata;

    AIDC_LITE_DECOMP_ENGINE             u_engine
    (
        .clk                            (clk),
        .rst_n                          (rst_n),

        .src_addr_i                     (cfg_hwif_out.SRC_ADDR.START_ADDR.value),
        .dst_addr_i                     (cfg_hwif_out.DST_ADDR.START_ADDR.value),
        .len_i                          (cfg_hwif_out.LEN.BYTE_SIZE.value),
        .start_i                        (cfg_hwif_out.CMD.START.value),
        .done_o                         (cfg_hwif_in.STATUS.DONE.next),

        .ahb_if                         (ahb_if),

        .decomp0_wren_o                 (decomp0_wren),
        .decomp1_wren_o                 (decomp1_wren),
        .decomp2_wren_o                 (/* FLOLATING */),
        .decomp_sop_o                   (decomp_sop),
        .decomp_eop_o                   (decomp_eop),
        .decomp_wdata_o                 (decomp_wdata),

        .decomp_done_i                  (sr_done & zrle_done),

        .buf_addr_o                     (buf_addr),
        .decomp_rdata_i                 (buf_rdata)
    );

    AIDC_LITE_DECOMP_SR                 u_sr
    (
        .clk                            (clk),
        .rst_n                          (rst_n),

        .valid_i                        (decomp0_wren),
        .sop_i                          (decomp_sop),
        .eop_i                          (decomp_eop),
        .data_i                         (decomp_wdata),

        .valid_o                        (sr_buf_wren),
        .addr_o                         (sr_buf_waddr),
        .data_o                         (sr_buf_wdata),
        .done_o                         (sr_done)
    );

    AIDC_LITE_DECOMP_ZRLE               u_zrle
    (
        .clk                            (clk),
        .rst_n                          (rst_n),

        .valid_i                        (decomp1_wren),
        .sop_i                          (decomp_sop),
        .eop_i                          (decomp_eop),
        .data_i                         (decomp_wdata),

        .valid_o                        (zrle_buf_wren),
        .addr_o                         (zrle_buf_waddr),
        .data_o                         (zrle_buf_wdata),
        .done_o                         (zrle_done)
    );

    AIDC_LITE_BUFFER #(.ADDR_WIDTH(4))  u_buffer
    (
        .clk                            (clk),
        .rst_n                          (rst_n),

        .wren_i                         (sr_buf_wren  | zrle_buf_wren),
        .waddr_i                        (sr_buf_waddr | zrle_buf_waddr),
        .wdata_i                        (sr_buf_wdata | zrle_buf_wdata),

        .raddr_i                        (buf_addr),
        .rdata_o                        (buf_rdata)
    );

endmodule
