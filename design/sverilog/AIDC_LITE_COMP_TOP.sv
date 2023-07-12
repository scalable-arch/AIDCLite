module AIDC_LITE_COMP_TOP
(
    input   wire                        clk,
    input   wire                        rst_n,

    AHB2_MST_INTF.master                ahb_if,

    APB_INTF.slave                      apb_if
);

    wire    [31:0]                      cfg_src_addr;
    wire    [31:0]                      cfg_dst_addr;
    wire    [31:7]                      cfg_len;
    wire                                cfg_start;
    wire                                cfg_done;

    AIDC_LITE_COMP_CFG                  u_cfg
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

    wire                                comp_wren;
    wire                                comp_sop;
    wire                                comp_eop;
    wire    [63:0]                      comp_wdata;

    wire                                zrle_buf_wren;
    wire    [3:0]                       zrle_buf_waddr;
    wire    [63:0]                      zrle_buf_wdata;
    wire    [10:0]                      zrle_blk_size;

    AIDC_LITE_COMP_ENGINE               u_engine
    (
        .clk                            (clk),
        .rst_n                          (rst_n),

        .src_addr_i                     (cfg_src_addr),
        .dst_addr_i                     (cfg_dst_addr),
        .len_i                          (cfg_len),
        .start_i                        (cfg_start),
        .done_o                         (cfg_done),

        .ahb_if                         (ahb_if),

        .comp_wren_o                    (comp_wren),
        .comp_sop_o                     (comp_sop),
        .comp_eop_o                     (comp_eop),
        .comp_wdata_o                   (comp_wdata),

        .zrle_blk_size_i                (zrle_blk_size),
        .comp_ready_i                   (1'b1),
        .comp_rden_o                    (/* floating */),
        .comp_rdata_i                   (32'd0)
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
        .blk_size_o                     (zrle_blk_size)
    );

    AIDC_LITE_COMP_BUFFER               u_buffer
    (
        .clk                            (clk),
        .rst_n                          (rst_n),

        .wren_i                         (zrle_buf_wren),
        .waddr_i                        (zrle_buf_waddr),
        .wdata_i                        (zrle_buf_wdata),

        .rden_i                         (1'b0),
        .raddr_i                        (4'd0),
        .rdata_o                        (/* */)
    );

endmodule
