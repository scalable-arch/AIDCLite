module AIDC_DECOMP_DATA
(
    input   wire                        clk,
    input   wire                        rst_n,

    AXI4_R_INTF.slave                   core_r_if,

    AXI4_R_INTF.master                  mem_r_if
);

    // SOP (start-of-packet) and EOP (end-of-packet)
    // are useful in processing data
    // EOP is the same as LAST in AXI, yet SOP requires
    // generation
    wire                                mem_r_sop;

    AIDC_SOP_GEN                        u_sop_gen
    (
        .clk                            (clk),
        .rst_n                          (rst_n),

        .valid_i                        (mem_r_if.rvalid),
        .ready_i                        (mem_r_if.rready),
        .last_i                         (mem_r_if.rlast),

        .sop_o                          (mem_r_sop)
    );

    //                          mem's R
    //  +--------------------------||-----------------------------+
    //  |     =================================================   |
    //  |     ||                ||                ||         ||   |
    //  | +---------+       +---------+       +---------+    ||   |
    //  | | DECMP0  |       | DECMP1  |       | DECMP2  |    ||   |
    //  | | (ZRL)   |       |  (SR)   |       | (BPC)   |    ||   |
    //  | +---------+       +---------+       +---------+    ||   |

endmodule
