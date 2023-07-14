module AIDC_LITE_TOP_WRAPPER
(
    input   wire                        clk,
    input   wire                        rst_n,

    // compressor
    // AMBA2 AHB
    output  logic                       comp_hbusreq_o,
    input   wire                        comp_hgrant_i,

    output  logic   [31:0]              comp_haddr_o,
    output  logic   [1:0]               comp_htrans_o,
    output  logic                       comp_hwrite_o,
    output  logic   [2:0]               comp_hsize_o,
    output  logic   [2:0]               comp_hburst_o,
    output  logic   [3:0]               comp_hprot_o,
    output  logic   [31:0]              comp_hwdata_o,

    input   wire    [31:0]              comp_hrdata_i,
    input   wire                        comp_hready_i,
    input   wire    [1:0]               comp_hresp_i,

    // AMBA APB
    input   wire    [31:0]              comp_paddr_i,
    input   wire                        comp_psel_i,
    input   wire                        comp_penable_i,
    input   wire                        comp_pwrite_i,
    input   wire    [31:0]              comp_pwdata_i,
    output  logic                       comp_pready_o,
    output  logic   [31:0]              comp_prdata_o,
    output  logic                       comp_pslverr_o,

    // decompressor
    // AMBA2 AHB
    output  logic                       decomp_hbusreq_o,
    input   wire                        decomp_hgrant_i,

    output  logic   [31:0]              decomp_haddr_o,
    output  logic   [1:0]               decomp_htrans_o,
    output  logic                       decomp_hwrite_o,
    output  logic   [2:0]               decomp_hsize_o,
    output  logic   [2:0]               decomp_hburst_o,
    output  logic   [3:0]               decomp_hprot_o,
    output  logic   [31:0]              decomp_hwdata_o,

    input   wire    [31:0]              decomp_hrdata_i,
    input   wire                        decomp_hready_i,
    input   wire    [1:0]               decomp_hresp_i,

    // AMBA APB
    input   wire    [31:0]              decomp_paddr_i,
    input   wire                        decomp_psel_i,
    input   wire                        decomp_penable_i,
    input   wire                        decomp_pwrite_i,
    input   wire    [31:0]              decomp_pwdata_i,
    output  logic                       decomp_pready_o,
    output  logic   [31:0]              decomp_prdata_o,
    output  logic                       decomp_pslverr_o
);

    // indivdual signals to SystemVerilog interface conversion
    AHB2_MST_INTF                       comp_ahb_if (.hclk(clk), .hreset_n(rst_n));
    assign  comp_hbusreq_o              = comp_ahb_if.hbusreq;
    assign  comp_haddr_o                = comp_ahb_if.haddr;
    assign  comp_htrans_o               = comp_ahb_if.htrans;
    assign  comp_hwrite_o               = comp_ahb_if.hwrite;
    assign  comp_hsize_o                = comp_ahb_if.hsize;
    assign  comp_hburst_o               = comp_ahb_if.hburst;
    assign  comp_hprot_o                = comp_ahb_if.hprot;
    assign  comp_hwdata_o               = comp_ahb_if.hwdata;

    assign  comp_ahb_if.hgrant          = comp_hgrant_i;
    assign  comp_ahb_if.hrdata          = comp_hrdata_i;
    assign  comp_ahb_if.hready          = comp_hready_i;
    assign  comp_ahb_if.hresp           = comp_hresp_i;

    APB_INTF                            comp_apb_if  (.pclk(clk), .preset_n(rst_n));
    assign  comp_pready_o               = comp_apb_if.pready;
    assign  comp_prdata_o               = comp_apb_if.prdata;
    assign  comp_pslverr_o              = comp_apb_if.pslverr;
    assign  comp_apb_if.paddr           = comp_paddr_i;
    assign  comp_apb_if.psel            = comp_psel_i;
    assign  comp_apb_if.penable         = comp_penable_i;
    assign  comp_apb_if.pwrite          = comp_pwrite_i;
    assign  comp_apb_if.pwdata          = comp_pwdata_i;

    AHB2_MST_INTF                       decomp_ahb_if (.hclk(clk), .hreset_n(rst_n));
    assign  decomp_hbusreq_o            = decomp_ahb_if.hbusreq;
    assign  decomp_haddr_o              = decomp_ahb_if.haddr;
    assign  decomp_htrans_o             = decomp_ahb_if.htrans;
    assign  decomp_hwrite_o             = decomp_ahb_if.hwrite;
    assign  decomp_hsize_o              = decomp_ahb_if.hsize;
    assign  decomp_hburst_o             = decomp_ahb_if.hburst;
    assign  decomp_hprot_o              = decomp_ahb_if.hprot;
    assign  decomp_hwdata_o             = decomp_ahb_if.hwdata;

    assign  decomp_ahb_if.hgrant        = decomp_hgrant_i;
    assign  decomp_ahb_if.hrdata        = decomp_hrdata_i;
    assign  decomp_ahb_if.hready        = decomp_hready_i;
    assign  decomp_ahb_if.hresp         = decomp_hresp_i;

    APB_INTF                            decomp_apb_if  (.pclk(clk), .preset_n(rst_n));
    assign  decomp_pready_o             = decomp_apb_if.pready;
    assign  decomp_prdata_o             = decomp_apb_if.prdata;
    assign  decomp_pslverr_o            = decomp_apb_if.pslverr;
    assign  decomp_apb_if.paddr         = decomp_paddr_i;
    assign  decomp_apb_if.psel          = decomp_psel_i;
    assign  decomp_apb_if.penable       = decomp_penable_i;
    assign  decomp_apb_if.pwrite        = decomp_pwrite_i;
    assign  decomp_apb_if.pwdata        = decomp_pwdata_i;

    AIDC_LITE_COMP_TOP                  u_comp
    (
        .clk                            (clk),
        .rst_n                          (rst_n),

        .ahb_if                         (comp_ahb_if),
        .apb_if                         (comp_apb_if)
    );

    AIDC_LITE_DECOMP_TOP                u_decomp
    (
        .clk                            (clk),
        .rst_n                          (rst_n),

        .ahb_if                         (decomp_ahb_if),
        .apb_if                         (decomp_apb_if)
    );

endmodule
