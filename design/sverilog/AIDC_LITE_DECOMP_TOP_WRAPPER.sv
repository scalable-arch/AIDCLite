module AIDC_LITE_DECOMP_TOP_WRAPPER
(
    input   wire                        clk,
    input   wire                        rst_n,

    // AMBA2 AHB
    output  logic                       hbusreq_o,
    input   wire                        hgrant_i,

    output  logic   [31:0]              haddr_o,
    output  logic   [1:0]               htrans_o,
    output  logic                       hwrite_o,
    output  logic   [2:0]               hsize_o,
    output  logic   [2:0]               hburst_o,
    output  logic   [3:0]               hprot_o,
    output  logic   [31:0]              hwdata_o,

    input   wire    [31:0]              hrdata_i,
    input   wire                        hready_i,
    input   wire    [1:0]               hresp_i,

    // AMBA APB
    input   wire    [31:0]              paddr_i,
    input   wire                        psel_i,
    input   wire                        penable_i,
    input   wire                        pwrite_i,
    input   wire    [31:0]              pwdata_i,
    output  logic                       pready_o,
    output  logic   [31:0]              prdata_o,
    output  logic                       pslverr_o
);

    // indivdual signals to SystemVerilog interface conversion
    AHB2_MST_INTF                       ahb_if  (.hclk(clk), .hreset_n(rst_n));
    assign  hbusreq_o                   = ahb_if.hbusreq;
    assign  haddr_o                     = ahb_if.haddr;
    assign  htrans_o                    = ahb_if.htrans;
    assign  hwrite_o                    = ahb_if.hwrite;
    assign  hsize_o                     = ahb_if.hsize;
    assign  hburst_o                    = ahb_if.hburst;
    assign  hprot_o                     = ahb_if.hprot;
    assign  hwdata_o                    = ahb_if.hwdata;

    assign  ahb_if.hgrant               = hgrant_i;
    assign  ahb_if.hrdata               = hrdata_i;
    assign  ahb_if.hready               = hready_i;
    assign  ahb_if.hresp                = hresp_i;

    APB_INTF                            apb_if  (.pclk(clk), .preset_n(rst_n));
    assign  pready_o                    = apb_if.pready;
    assign  prdata_o                    = apb_if.prdata;
    assign  pslverr_o                   = apb_if.pslverr;
    assign  apb_if.paddr                = paddr_i;
    assign  apb_if.psel                 = psel_i;
    assign  apb_if.penable              = penable_i;
    assign  apb_if.pwrite               = pwrite_i;
    assign  apb_if.pwdata               = pwdata_i;

    AIDC_LITE_DECOMP_TOP                u_comp
    (
        .clk                            (clk),
        .rst_n                          (rst_n),

        .ahb_if                         (ahb_if),
        .apb_if                         (apb_if)
    );

endmodule
