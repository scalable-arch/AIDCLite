module AIDC_LITE_COMP_TOP
(
    input   wire                        clk,
    input   wire                        rst_n,

    AHB2_MST_INTF.master                ahb_if,

    APB_INTF.slave                      apb_if
);

    wire    [31:0]                      src_addr;
    wire    [31:0]                      dst_addr;
    wire    [31:7]                      len;
    wire                                start;
    wire                                done;

    AIDC_LITE_COMP_CFG                  u_cfg
    (
        .clk                            (clk),
        .rst_n                          (rst_n),

        .apb_if                         (apb_if),

        .src_addr_o                     (src_addr),
        .dst_addr_o                     (dst_addr),
        .len_o                          (len),
        .start_o                        (start),
        .done_i                         (done)
    );

    AIDC_LITE_COMP_ENGINE               u_engine
    (
        .clk                            (clk),
        .rst_n                          (rst_n),

        .ahb_if                         (ahb_if),

        .src_addr_i                     (src_addr),
        .dst_addr_i                     (dst_addr),
        .len_i                          (len),
        .start_i                        (start),
        .done_o                         (done)
    );

endmodule
