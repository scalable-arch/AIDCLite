module AHB2_BUS
(
    input   wire                        clk,
    input   wire                        rst_n,

    AHB2_MST_INTF.slave                 m0_if,

    AHB2_SLV_INTF.master                s0_if
);

    assign  m0_if.hgrant                = 1'b1;

    assign  s0_if.hsel                  = 1'b1;
    //assign  s0_if.hsel                  = 1'b1;

endmodule
