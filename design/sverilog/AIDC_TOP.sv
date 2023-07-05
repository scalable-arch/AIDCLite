module AIDC_TOP
#(
    parameter   ID_WIDTH                = 4,
    parameter   ADDR_WIDTH              = 32
)
(
    input   wire                        clk,
    input   wire                        rst_n,

    AXI4_A_INTF.slave                   core_aw_if,
    AXI4_W_INTF.slave                   core_w_if,
    AXI4_B_INTF.slave                   core_b_if,
    AXI4_A_INTF.slave                   core_ar_if,
    AXI4_R_INTF.slave                   core_r_if,

    AXI4_A_INTF.master                  mem_aw_if,
    AXI4_W_INTF.master                  mem_w_if,
    AXI4_B_INTF.master                  mem_b_if,
    AXI4_A_INTF.master                  mem_ar_if,
    AXI4_R_INTF.master                  mem_r_if,

    APB_INTF.slave                      apb_if,

    output  logic                       cfg_aidc_on_o
);

    //----------------------------------------------------------
    // block diagram
    //----------------------------------------------------------
    //                  core interfaces
    //      AW      W       B       AR      R        APB
    //  +---||-------||------||------||-------||-------||----+
    //  | +-----+  +-----+   ||    +-----+  +-----+  +-----+ |
    //  | |addr_|->|data_|   ||    |addr_|->|data_|  | CFG | |
    //  | |conv |  |comp |   ||    |conv |  |decmp|  +-----+ |
    //  | +-----+  +-----+   ||    +-----+  +-----+          |
    //  +---||-------||------||------||-------||-------------+
    //      AW      W       B       AR      R
    //                  mem interfaces
    //----------------------------------------------------------
    AIDC_ADDR_CONVERTER                 u_addr_comp
    (
        .clk                            (clk),
        .rst_n                          (rst_n),

        .core_a_if                      (core_aw_if),
        .mem_a_if                       (mem_aw_if)
    );

    AIDC_COMP_DATA                      u_data_comp
    (
        .clk                            (clk),
        .rst_n                          (rst_n),

        .core_w_if                      (core_w_if),
        .mem_w_if                       (mem_w_if)
    );

    always_comb begin
        `AXI4_B_INTF_CONNECT(core_b_if, mem_b_if);
    end

    AIDC_ADDR_CONVERTER                 u_addr_decomp
    (
        .clk                            (clk),
        .rst_n                          (rst_n),

        .core_a_if                      (core_ar_if),
        .mem_a_if                       (mem_ar_if)
    );

    AIDC_DECOMP_DATA                    u_data_decomp
    (
        .clk                            (clk),
        .rst_n                          (rst_n),

        .core_r_if                      (core_r_if),
        .mem_r_if                       (mem_r_if)
    );

    AIDC_CFG                            u_cfg
    (
        .clk                            (clk),
        .rst_n                          (rst_n),

        .apb_if                         (apb_if),

        // use explicit port connection to reduce Lint warnings
        .cfg_aidc_on_o                  (cfg_aidc_on_o)
    );
endmodule
