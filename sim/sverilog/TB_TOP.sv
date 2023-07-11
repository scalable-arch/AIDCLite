module TB_TOP;

    //----------------------------------------------------------
    // clock and reset generation
    //----------------------------------------------------------
    parameter                           CLK_PERIOD      = 10;

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
    // interface declaration
    //----------------------------------------------------------
    AHB2_MST_INTF                       mst_ahb_if  (.hclk(clk), .hreset_n(rst_n));
    AHB2_SLV_INTF                       slv_ahb_if  (.hclk(clk), .hreset_n(rst_n));
    APB_INTF                            apb_if      (.pclk(clk), .preset_n(rst_n));

    //----------------------------------------------------------
    // Design-Under-Test
    //----------------------------------------------------------
    AIDC_LITE_COMP_TOP                  dut
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
    //    $dumpvars(0, dut);
    //    $dumpfile("dump.vcd");
    //end
    initial begin
        $fsdbDumpfile("dump.fsdb");
        $fsdbDumpvars(0, dut);
    end

    //----------------------------------------------------------
    // Test sequence
    //----------------------------------------------------------
    initial begin
        logic   [31:0]      rdata;

        apb_if.reset_master();
        u_mem.init_mem_with_addr();

        repeat (10) @(posedge clk);

        apb_if.write(32'h0, 32'h0001_0000);
        apb_if.write(32'h4, 32'h0002_0000);
        apb_if.write(32'h8, 32'h0000_1000);
        apb_if.write(32'hC, 32'd1);

        for (int i=0; i<10000; i++) begin
            apb_if.read(32'h10, rdata);
            if (rdata==32'h1) begin
                break;
            end
            $write(".");
            repeat (100) @(posedge clk);
        end
        $display("");   // new line
        repeat (50) @(posedge clk);

        $display("---------------------------------------------------");
        $display("Command completed");
        $display("---------------------------------------------------");

        $finish;
    end
endmodule
