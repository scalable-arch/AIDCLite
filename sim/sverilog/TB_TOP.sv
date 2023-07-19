module TB_TOP;

    //----------------------------------------------------------
    // clock and reset generation
    //----------------------------------------------------------
    parameter                           CLK_PERIOD      = 10;
    parameter                           TIMEOUT         = (CLK_PERIOD * 100000);

    logic                               clk;
    logic                               rst_n;

    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk     = ~clk;
    end

    initial begin
        rst_n                           = 1'b0;

        repeat (3) @(posedge clk)
        rst_n                           = 1'b1;
    end

    //----------------------------------------------------------
    // Simulation timeout
    //----------------------------------------------------------
    initial begin
        #TIMEOUT
        $fatal("Simulation timed out");
    end

    //----------------------------------------------------------
    // interface declaration
    //----------------------------------------------------------
    AHB2_MST_INTF                       mst_ahb_if  (.hclk(clk), .hreset_n(rst_n));
    AHB2_SLV_INTF                       slv_ahb_if  (.hclk(clk), .hreset_n(rst_n));
    APB_INTF                            apb_if      (.pclk(clk), .preset_n(rst_n));

    //----------------------------------------------------------
    // Design-Under-Test
    //----------------------------------------------------------
    AIDC_LITE_COMP_TOP                  u_dut
    (
        .clk                            (clk),
        .rst_n                          (rst_n),

        .ahb_if                         (mst_ahb_if),

        .apb_if                         (apb_if)
    );

    AHB2_BUS                            u_bus
    (
        .clk                            (clk),
        .rst_n                          (rst_n),

        .m0_if                          (mst_ahb_if),

        .s0_if                          (slv_ahb_if)
    );

    AHB2_MEM                            u_mem
    (
        .clk                            (clk),
        .rst_n                          (rst_n),

        .ahb_if                         (slv_ahb_if)
    );

    //initial begin
    //    $dumpvars(0, u_dut);
    //    $dumpfile("dump.vcd");
    //end
    initial begin
        $fsdbDumpfile("dump.fsdb");
        $fsdbDumpvars(0, u_dut);
    end

    //----------------------------------------------------------
    // Test sequence
    //----------------------------------------------------------
    initial begin
        u_mem.init_mem_with_addr();
    end
    
    APB_TEST (
            .apb_if                 (apb_if),
            .src_addr               (src_addr),
            .dst_addr               (dst_addr),
            .len                    (len)
        );

    AHB_TEST (
            mst_ahb_if,
            slv_ahb_if
        );

endmodule
