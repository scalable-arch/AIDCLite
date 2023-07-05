module AIDC_CFG
(
    input   wire                        clk,
    input   wire                        rst_n,

    APB_INTF.slave                      apb_if,

    output  logic                       cfg_aidc_on_o
);

    assign  cfg_aidc_on_o               = 1'b0;

endmodule
