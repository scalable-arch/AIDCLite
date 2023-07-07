// Copyright Sungkyunkwan University
// Author: Jungrae Kim <dale40@gmail.com>
// Description:

// Follows AMBA2 AHB v1.0 specification, 1999
// (ARM IHI 0011A)

interface AHB2_MST_INTF
(
    input   wire                        hclk,
    input   wire                        hreset_n
);

    logic                               hbusreq;
    logic                               hgrant;

    logic   [31:0]                      haddr;
    logic   [1:0]                       htrans;
    logic                               hwrite;
    logic   [2:0]                       hsize;
    logic   [2:0]                       hburst;
    logic   [3:0]                       hprot;
    logic   [31:0]                      hwdata;

    logic   [31:0]                      hrdata;
    logic                               hready;
    logic   [1:0]                       hresp;

    modport master (
        output      hbusreq, haddr, htrans, hwrite, hsize, hburst, hprot, hwdata,
        input       hgrant, hrdata, hready, hresp
    );
    modport slave (
        input       hbusreq, haddr, htrans, hwrite, hsize, hburst, hprot, hwdata,
        output      hgrant, hrdata, hready, hresp
    );

    // synthesis translate_off
    // - for verification only
    // synthesis translate_on

endinterface

interface AHB2_SLV_INTF
(
    input   wire                        hclk,
    input   wire                        hreset_n
);

    logic                               hsel;
    logic   [31:0]                      haddr;
    logic   [1:0]                       htrans;
    logic                               hwrite;
    logic   [2:0]                       hsize;
    logic   [2:0]                       hburst;
    logic   [3:0]                       hprot;
    logic   [31:0]                      hwdata;

    logic   [31:0]                      hrdata;
    logic                               hready;
    logic   [1:0]                       hresp;

    modport master (
        output      hsel, haddr, htrans, hwrite, hsize, hburst, hprot, hwdata,
        input       hrdata, hready, hresp
    );
    modport slave (
        input       hsel, haddr, htrans, hwrite, hsize, hburst, hprot, hwdata,
        output      hrdata, hready, hresp
    );

    // synthesis translate_off
    // - for verification only
    // synthesis translate_on

endinterface
