module AHB2_SLAVE
(
    input   wire                        clk,
    input   wire                        rst_n,

    AHB2_SLV_INTF.slave                 ahb_if
);

    assign  ahb_if.hreadyo              = 1'b1;
    assign  ahb_if.hresp                = HRESP_OKAY;

endmodule
