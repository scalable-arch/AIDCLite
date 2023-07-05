module AIDC_LITE_COMP_ENGINE
(
    input   wire                        clk,
    input   wire                        rst_n,

    AHB_INTF.master                     ahb_if,

    input   wire    [31:0]              src_addr_i,
    input   wire    [31:0]              dst_addr_i,
    input   wire    [31:7]              len_i
    input   wire                        start_i,    // pulse
    output  logic                       done_o      // level
);

endmodule
