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
    AHB2_MST_INTF                       ahb_m0_if (.hclk(clk), .hreset_n(rst_n));
    APB_INTF                            apb0_if     (.pclk(clk), .preset_n(rst_n));
    AHB2_MST_INTF                       ahb_m1_if (.hclk(clk), .hreset_n(rst_n));
    APB_INTF                            apb1_if     (.pclk(clk), .preset_n(rst_n));

    AHB2_SLV_INTF                       ahb_s0_if  (.hclk(clk), .hreset_n(rst_n));

    //----------------------------------------------------------
    // Design-Under-Test
    //----------------------------------------------------------
    AIDC_LITE_COMP_TOP                  u_comp
    (
        .clk                            (clk),
        .rst_n                          (rst_n),

        .ahb_if                         (ahb_m0_if),

        .apb_if                         (apb0_if)
    );

    AIDC_LITE_DECOMP_TOP                u_decomp
    (
        .clk                            (clk),
        .rst_n                          (rst_n),

        .ahb_if                         (ahb_m1_if),

        .apb_if                         (apb1_if)
    );

    AHB2_BUS                            u_bus
    (
        .clk                            (clk),
        .rst_n                          (rst_n),

        .m0_if                          (ahb_m0_if),
        .m1_if                          (ahb_m1_if),

        .s0_if                          (ahb_s0_if)
    );

    AHB2_MEM                            u_mem
    (
        .clk                            (clk),
        .rst_n                          (rst_n),

        .ahb_if                         (ahb_s0_if)
    );

    //initial begin
    //    $dumpvars(0, u_dut);
    //    $dumpfile("dump.vcd");
    //end
    initial begin
        $fsdbDumpfile("dump.fsdb");
        $fsdbDumpvars(0, TB_TOP);
    end

    //----------------------------------------------------------
    // Test sequence
    //----------------------------------------------------------
    initial begin
        logic   [31:0]      rdata;

        apb0_if.reset_master();
        apb1_if.reset_master();
        u_mem.init_mem_with_addr();

        repeat (10) @(posedge clk);

        apb0_if.write(32'h0, 32'h0001_0000);
        apb0_if.write(32'h4, 32'h0002_0000);
        apb0_if.write(32'h8, 32'h0000_1000);
        apb0_if.write(32'hC, 32'd1);

        for (int i=0; i<10000; i++) begin
            apb0_if.read(32'h10, rdata);
            if (rdata==32'h1) begin
                break;
            end
            $write(".");
            repeat (100) @(posedge clk);
        end
        $display("");   // new line
        repeat (50) @(posedge clk);

        $display("---------------------------------------------------");
        $display(" Compression completed");
        $display("---------------------------------------------------");

        apb1_if.write(32'h0, 32'h0002_0000);
        apb1_if.write(32'h4, 32'h0003_0000);
        apb1_if.write(32'h8, 32'h0000_0800);
        apb1_if.write(32'hC, 32'd1);

        for (int i=0; i<10000; i++) begin
            apb1_if.read(32'h10, rdata);
            if (rdata==32'h1) begin
                break;
            end
            $write(".");
            repeat (100) @(posedge clk);
        end
        $display("");   // new line
        repeat (50) @(posedge clk);

        $display("---------------------------------------------------");
        $display(" Decompression completed");
        $display("---------------------------------------------------");

        $finish;
    end
endmodule
