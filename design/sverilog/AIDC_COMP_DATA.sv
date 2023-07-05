module AIDC_COMP_DATA
(
    input   wire                        clk,
    input   wire                        rst_n,

    AXI4_W_INTF.slave                   core_w_if,

    AXI4_W_INTF.master                  mem_w_if
);

    // SOP (start-of-packet) and EOP (end-of-packet)
    // are useful in processing data
    // EOP is the same as LAST in AXI, yet SOP requires
    // generation
    wire                                core_w_sop;

    AIDC_SOP_GEN                        u_sop_gen
    (
        .clk                            (clk),
        .rst_n                          (rst_n),

        .valid_i                        (core_w_if.wvalid),
        .ready_i                        (core_w_if.wready),
        .last_i                         (core_w_if.wlast),

        .sop_o                          (core_w_sop)
    );

    //                          core's W           AW's compFlag
    //  +--------------------------||-------------------|----+
    //  |                          ||  +-----+          |    |
    //  |                          ||==| SOP |          |    |
    //  |                          ||  +-----+          |    |
    //  |          ==================================   |    |
    //  |          ||          ||          ||       |   |    |
    //  |      +-------+   +-------+   +-------+    |   |    |
    //  |      | CMP0  |   |  CMP1 |   | CMP2  |    |   |    |
    //  |      | (ZRL) |   |  (SR) |   | (BPC) |    |   |    |
    //  |      +-------+   +-------+   +-------+    |   |    |
    //  |        |   |       |   |       |   |      |   |    |
    //  |(FIFOs)| | | |     | | | |     | | | |    | | | |
    //  |       +-+ +-+     +-+ +-+     +-+ +-+    +-+ +-+
    //  |       +-+ +-+     +-+ +-+     +-+ +-+    +-+ +-+
    //  |            |           |           |          |    |
    //  |           +-------------------------+         |    |
    //  |           |   comp selector         |         |    |
    //  |           +-------------------------+         |    |
    //  |                        |                      |    |
    //  |                       +------------------------+
    //  |                       |     data selector      |
    //  |                       +------------------------+

endmodule
