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
    AHB2_SLV_INTF                       ahb_s1_if  (.hclk(clk), .hreset_n(rst_n));

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

    wire    [31:0]                      m_hrdata;
    wire    [1:0]                       m_hresp;
    wire                                m_hready;

    wire    [31:0]                      s_haddr;
    wire                                s_hwrite;
    wire    [1:0]                       s_htrans;
    wire    [2:0]                       s_hsize;
    wire    [2:0]                       s_hburst;
    wire    [31:0]                      s_hwdata;
    wire    [3:0]                       s_hprot;
    wire                                s_hready;

    amba_ahb_m2s2
    #(
        .P_HSEL0_START                  (32'h0000_0000),
        .P_HSEL0_SIZE                   (32'h0002_0000),
        .P_HSEL1_START                  (32'h0002_0000),
        .P_HSEL1_SIZE                   (32'h0002_0000)
    )
    u_bus
    (
        .HCLK                           (clk),
        .HRESETn                        (rst_n),

        .M0_HBUSREQ                     (ahb_m0_if.hbusreq),
        .M0_HGRANT                      (ahb_m0_if.hgrant),
        .M0_HADDR                       (ahb_m0_if.haddr),
        .M0_HTRANS                      (ahb_m0_if.htrans),
        .M0_HSIZE                       (ahb_m0_if.hsize),
        .M0_HBURST                      (ahb_m0_if.hburst),
        .M0_HPROT                       (ahb_m0_if.hprot),
        .M0_HLOCK                       (1'b0),
        .M0_HWRITE                      (ahb_m0_if.hwrite),
        .M0_HWDATA                      (ahb_m0_if.hwdata),

        .M1_HBUSREQ                     (ahb_m1_if.hbusreq),
        .M1_HGRANT                      (ahb_m1_if.hgrant),
        .M1_HADDR                       (ahb_m1_if.haddr),
        .M1_HTRANS                      (ahb_m1_if.htrans),
        .M1_HSIZE                       (ahb_m1_if.hsize),
        .M1_HBURST                      (ahb_m1_if.hburst),
        .M1_HPROT                       (ahb_m1_if.hprot),
        .M1_HLOCK                       (1'b0),
        .M1_HWRITE                      (ahb_m1_if.hwrite),
        .M1_HWDATA                      (ahb_m1_if.hwdata),

        .M_HRDATA                       (m_hrdata),
        .M_HRESP                        (m_hresp),
        .M_HREADY                       (m_hready),

        .S_HADDR                        (s_haddr),
        .S_HWRITE                       (s_hwrite),
        .S_HTRANS                       (s_htrans),
        .S_HSIZE                        (s_hsize),
        .S_HBURST                       (s_hburst),
        .S_HWDATA                       (s_hwdata),
        .S_HPROT                        (s_hprot),
        .S_HREADY                       (s_hready),
        .S_HMASTER                      (/* FLOATING */),
        .S_HMASTLOCK                    (/* FLOATING */),

        .S0_HSEL                        (ahb_s0_if.hsel),
        .S0_HREADY                      (ahb_s0_if.hreadyo),
        .S0_HRESP                       (ahb_s0_if.hresp),
        .S0_HRDATA                      (ahb_s0_if.hrdata),
        .S0_HSPLIT                      (16'd0),

        .S1_HSEL                        (ahb_s1_if.hsel),
        .S1_HREADY                      (ahb_s1_if.hreadyo),
        .S1_HRESP                       (ahb_s1_if.hresp),
        .S1_HRDATA                      (ahb_s1_if.hrdata),
        .S1_HSPLIT                      (16'd0),

        .REMAP                          (1'b0)
    );

    assign  ahb_m0_if.hrdata            = m_hrdata;
    assign  ahb_m0_if.hresp             = m_hresp;
    assign  ahb_m0_if.hready            = m_hready;

    assign  ahb_m1_if.hrdata            = m_hrdata;
    assign  ahb_m1_if.hresp             = m_hresp;
    assign  ahb_m1_if.hready            = m_hready;

    assign  ahb_s0_if.haddr             = s_haddr;
    assign  ahb_s0_if.hwrite            = s_hwrite;
    assign  ahb_s0_if.htrans            = s_htrans;
    assign  ahb_s0_if.hsize             = s_hsize;
    assign  ahb_s0_if.hburst            = s_hburst;
    assign  ahb_s0_if.hwdata            = s_hwdata;
    assign  ahb_s0_if.hprot             = s_hprot;
    assign  ahb_s0_if.hreadyi           = s_hready;

    assign  ahb_s1_if.haddr             = s_haddr;
    assign  ahb_s1_if.hwrite            = s_hwrite;
    assign  ahb_s1_if.htrans            = s_htrans;
    assign  ahb_s1_if.hsize             = s_hsize;
    assign  ahb_s1_if.hburst            = s_hburst;
    assign  ahb_s1_if.hwdata            = s_hwdata;
    assign  ahb_s1_if.hprot             = s_hprot;
    assign  ahb_s1_if.hreadyi           = s_hready;

    AHB2_MEM                            u_mem0
    (
        .clk                            (clk),
        .rst_n                          (rst_n),

        .ahb_if                         (ahb_s0_if)
    );

    AHB2_MEM                            u_mem1
    (
        .clk                            (clk),
        .rst_n                          (rst_n),

        .ahb_if                         (ahb_s1_if)
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
    task test_comp (
        input   [31:0]      src_addr,
        input   [31:0]      dst_addr,
        input   [31:0]      len
    );
    begin
        logic   [31:0]      rdata;

        $display("---------------------------------------------------");
        $display(" Compression test starts");
        $display("---------------------------------------------------");

        apb0_if.write(32'h0, src_addr);
        apb0_if.write(32'h4, dst_addr);
        apb0_if.write(32'h8, len);
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

        repeat (10) @(posedge clk);

        $display("---------------------------------------------------");
        $display(" Compression test completed");
        $display("---------------------------------------------------");
    end
    endtask;

    task test_decomp (
        input   [31:0]      src_addr,
        input   [31:0]      dst_addr,
        input   [31:0]      len
    );
    begin
        logic   [31:0]      rdata;

        $display("---------------------------------------------------");
        $display(" Decompression test starts");
        $display("---------------------------------------------------");

        apb1_if.write(32'h0, src_addr);
        apb1_if.write(32'h4, dst_addr);
        apb1_if.write(32'h8, len);
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

        repeat (10) @(posedge clk);

        $display("---------------------------------------------------");
        $display(" Decompression test completed");
        $display("---------------------------------------------------");
    end
    endtask;

    initial begin
        apb0_if.reset_master();
        apb1_if.reset_master();
        u_mem0.init_mem_with_addr();

        repeat (10) @(posedge clk);

        test_comp(32'h0000_0000,
                  32'h0002_0000,
                  32'h0000_0100);

        test_decomp(32'h0002_0000,
                    32'h0003_0000,
                    32'h0000_0100);

        repeat (100) @(posedge clk);

        test_comp(32'h0000_0100,
                  32'h0002_0000,
                  32'h0000_0100);

        test_decomp(32'h0002_0000,
                    32'h0003_0000,
                    32'h0000_0100);

        repeat (100) @(posedge clk);

        test_comp(32'h0001_0000,
                  32'h0002_0000,
                  32'h0000_0100);

        test_decomp(32'h0002_0000,
                    32'h0003_0000,
                    32'h0000_0100);

        $finish;
    end
endmodule
