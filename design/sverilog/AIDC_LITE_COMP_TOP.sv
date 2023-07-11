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

    wire                                buf_wren;
    wire    [3:0]                       buf_waddr;
    wire    [7:0]                       buf_wbe;
    wire    [63:0]                      buf_wdata;

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

        .buf_wren_o                     (buf_wren),
        .buf_waddr_o                    (buf_addr),
        .buf_wbe_o                      (buf_wbe),
        .buf_wdata_o                    (buf_wdata),

        .comp_start_o                   (/* floating */),
        .comp_ready_i                   (1'b1),
        .comp_rden_o                    (/* floating */),
        .comp_rdata_i                   (32'd0)
    );

    AIDC_LITE_COMP_BUFFER               u_buffer
    (
        .clk                            (clk),
        .rst_n                          (rst_n),

        .wren_i                         (buf_wren),
        .waddr_i                        (buf_waddr),
        .wbe_i                          (buf_wbe),
        .wdata_i                        (buf_wdata),

        .rden_i                         (1'b0),
        .raddr_i                        (4'd0),
        .rdata_o                        (/* */)
    );

endmodule
