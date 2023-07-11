module AHB2_BUS
(
    input   wire                        clk,
    input   wire                        rst_n,

    AHB2_MST_INTF.slave                 m0_if,

    AHB2_SLV_INTF.master                s0_if
);

    assign  m0_if.hgrant                = 1'b1;

    assign  s0_if.hsel                  = 1'b1;
    assign  s0_if.haddr                 = m0_if.haddr;
    assign  s0_if.htrans                = m0_if.htrans;
    assign  s0_if.hwrite                = m0_if.hwrite;
    assign  s0_if.hsize                 = m0_if.hsize;
    assign  s0_if.hburst                = m0_if.hburst;
    assign  s0_if.hprot                 = m0_if.hprot;
    assign  s0_if.hwdata                = m0_if.hwdata;

    assign  s0_if.hreadyi               = s0_if.hreadyo;

    assign  m0_if.hrdata                = s0_if.hrdata;
    assign  m0_if.hresp                 = s0_if.hresp;
    assign  m0_if.hready                = s0_if.hreadyo;

endmodule
