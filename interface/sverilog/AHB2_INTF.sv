// Copyright Sungkyunkwan University
// Author: Jungrae Kim <dale40@gmail.com>
// Description:

// Follows AMBA2 AHB v1.0 specification, 1999
// (ARM IHI 0011A)

parameter   logic   [1:0]           HTRANS_IDLE     = 2'b00;
parameter   logic   [1:0]           HTRANS_BUSY     = 2'b01;
parameter   logic   [1:0]           HTRANS_NONSEQ   = 2'b10;
parameter   logic   [1:0]           HTRANS_SEQ      = 2'b11;

parameter   logic   [1:0]           HRESP_OKAY      = 2'b00;
parameter   logic   [1:0]           HRESP_ERROR     = 2'b01;
parameter   logic   [1:0]           HRESP_RETRY     = 2'b10;
parameter   logic   [1:0]           HRESP_SPLIT     = 2'b11;

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
    logic                               hreadyi;
    logic                               hreadyo;
    logic   [1:0]                       hresp;

    modport master (
        output      hsel, haddr, htrans, hwrite, hsize, hburst, hprot, hwdata, hreadyi,
        input       hrdata, hreadyo, hresp
    );
    modport slave (
        input       hsel, haddr, htrans, hwrite, hsize, hburst, hprot, hwdata, hreadyi,
        output      hrdata, hreadyo, hresp
    );

    // synthesis translate_off
    // - for verification only
    // synthesis translate_on

endinterface
