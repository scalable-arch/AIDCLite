import  AIDC_LITE_COMP_CFG_pkg::*;

`include "AIDC_LITE_VERSION.svh"

module AIDC_LITE_COMP_TOP
(
    input   wire                        clk,
    input   wire                        rst_n,

    AHB2_MST_INTF.master                ahb_if,

    APB_INTF.slave                      apb_if
);

    wire    AIDC_LITE_COMP_CFG__in_t    cfg_hwif_in;
    wire    AIDC_LITE_COMP_CFG__out_t   cfg_hwif_out;

    AIDC_LITE_COMP_CFG                  u_cfg
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

    wire                                comp_wren;
    wire                                comp_sop;
    wire                                comp_eop;
    wire    [63:0]                      comp_wdata;

    wire                                sr_buf_wren;
    wire    [2:0]                       sr_buf_waddr;
    wire    [63:0]                      sr_buf_wdata;
    wire                                sr_done;
    wire                                sr_fail;

    wire                                zrle_buf_wren;
    wire    [2:0]                       zrle_buf_waddr;
    wire    [63:0]                      zrle_buf_wdata;
    wire                                zrle_done;
    wire                                zrle_fail;

    wire    [2:0]                       buf_addr;
    wire    [63:0]                      sr_buf_rdata;
    wire    [63:0]                      zrle_buf_rdata;

    AIDC_LITE_COMP_ENGINE               u_engine
    (
        .clk                            (clk),
        .rst_n                          (rst_n),

        .src_addr_i                     (cfg_hwif_out.SRC_ADDR.START_ADDR.value),
        .dst_addr_i                     (cfg_hwif_out.DST_ADDR.START_ADDR.value),
        .len_i                          (cfg_hwif_out.LEN.BYTE_SIZE.value),
        .start_i                        (cfg_hwif_out.CMD.START.value),
        .done_o                         (cfg_hwif_in.STATUS.DONE.next),

        .ahb_if                         (ahb_if),

        .comp_wren_o                    (comp_wren),
        .comp_sop_o                     (comp_sop),
        .comp_eop_o                     (comp_eop),
        .comp_wdata_o                   (comp_wdata),

        .comp0_done_i                   (sr_done),
        .comp1_done_i                   (zrle_done),
        .comp2_done_i                   (1'b1),
        .comp0_fail_i                   (sr_fail),
        .comp1_fail_i                   (zrle_fail),
        .comp2_fail_i                   (1'b1),

        .buf_addr_o                     (buf_addr),
        .comp0_rdata_i                  (sr_buf_rdata),
        .comp1_rdata_i                  (zrle_buf_rdata),
        .comp2_rdata_i                  (64'd0)
    );

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

    AIDC_LITE_BUFFER #(.ADDR_WIDTH(3))  u_sr_buffer
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

    AIDC_LITE_BUFFER #(.ADDR_WIDTH(3))  u_zrle_buffer
    (
        .clk                            (clk),
        .rst_n                          (rst_n),

        .wren_i                         (zrle_buf_wren),
        .waddr_i                        (zrle_buf_waddr),
        .wdata_i                        (zrle_buf_wdata),

        .raddr_i                        (buf_addr),
        .rdata_o                        (zrle_buf_rdata)
    );

    /*
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
