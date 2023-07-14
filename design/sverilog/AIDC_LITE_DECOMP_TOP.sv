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

        .src_addr_i                     (cfg_src_addr),
        .dst_addr_i                     (cfg_dst_addr),
        .len_i                          (cfg_len),
        .start_i                        (cfg_start),
        .done_o                         (cfg_done),

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
