// Copyright Sungkyunkwan University
// Author: Jungrae Kim <dale40@gmail.com>
// Description:

// Follows AMBA2 AHB v1.0 specification, 1999
// (ARM IHI 0011A)

// For clocking block (verfication part)
// sample -0.1ns before a posedge
`define ISAMPLE_TIME            0.1
// drive 0.1ns after a posedge
`define OSAMPLE_TIME            0.1

parameter   logic   [1:0]           HTRANS_IDLE     = 2'b00;
parameter   logic   [1:0]           HTRANS_BUSY     = 2'b01;
parameter   logic   [1:0]           HTRANS_NONSEQ   = 2'b10;
parameter   logic   [1:0]           HTRANS_SEQ      = 2'b11;

parameter   logic   [1:0]           HRESP_OKAY      = 2'b00;
parameter   logic   [1:0]           HRESP_ERROR     = 2'b01;
parameter   logic   [1:0]           HRESP_RETRY     = 2'b10;
parameter   logic   [1:0]           HRESP_SPLIT     = 2'b11;

parameter   logic   [2:0]           HBURST_SINGLE   = 3'b000;
parameter   logic   [2:0]           HBURST_INCR     = 3'b001;
parameter   logic   [2:0]           HBURST_WRAP4    = 3'b010;
parameter   logic   [2:0]           HBURST_INCR4    = 3'b011;
parameter   logic   [2:0]           HBURST_WRAP8    = 3'b100;
parameter   logic   [2:0]           HBURST_INCR8    = 3'b101;
parameter   logic   [2:0]           HBURST_WRAP16   = 3'b110;
parameter   logic   [2:0]           HBURST_INCR16   = 3'b111;

parameter   logic   [2:0]           HSIZE_8BITS     = 3'b000;
parameter   logic   [2:0]           HSIZE_16BITS    = 3'b001;
parameter   logic   [2:0]           HSIZE_32BITS    = 3'b010;
parameter   logic   [2:0]           HSIZE_64BITS    = 3'b011;
parameter   logic   [2:0]           HSIZE_128BITS   = 3'b100;
parameter   logic   [2:0]           HSIZE_256BITS   = 3'b101;
parameter   logic   [2:0]           HSIZE_512BITS   = 3'b110;
parameter   logic   [2:0]           HSIZE_1024BITS  = 3'b111;

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

    // synopsys translate_off
    // - for verification only
    clocking master_cb @(posedge clk);
        default input #`ISAMPLE_TIME output #`OSAMPLE_TIME;

        output      hbusreq, haddr, htrans, hwrite, hsize, hburst, hprot, hwdata;
        input       hgrant, hrdata, hready, hresp; 
    endclocking
    
    clocking slave_cb @(posedge clk);
        default input #`ISAMPLE_TIME output #`OSAMPLE_TIME;

        input       hbusreq, haddr, htrans, hwrite, hsize, hburst, hprot, hwdata;
        output      hgrant, hrdata, hready, hresp; 
    endclocking
    
    clocking mon_cb @(posedge clk);
        default input #`ISAMPLE_TIME output #`OSAMPLE_TIME;

        input       hbusreq, haddr, htrans, hwrite, hsize, hburst, hprot, hwdata;
        input       hgrant, hrdata, hready, hresp; 
    endclocking

    modport master_tb   (clocking master_cb, input hclk, hreset_n);
    modport slave_tb    (clocking slave_cb, input hclk, hreset_n);
    // synopsys translate_on

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

    // synopsys translate_off
    // - for verification only
    clocking master_cb @(posedge clk);
        default input #`ISAMPLE_TIME output #`OSAMPLE_TIME;

        output      hsel, haddr, htrans, hwrite, hsize, hburst, hprot, hwdata, hreadyi,
        input       hrdata, hreadyo, hresp
    endclocking
    
    clocking slave_cb @(posedge clk);
        default input #`ISAMPLE_TIME output #`OSAMPLE_TIME;

        input       hsel, haddr, htrans, hwrite, hsize, hburst, hprot, hwdata, hreadyi,
        output      hrdata, hreadyo, hresp
    endclocking
    
    clocking mon_cb @(posedge clk);
        default input #`ISAMPLE_TIME output #`OSAMPLE_TIME;

        input       hsel, haddr, htrans, hwrite, hsize, hburst, hprot, hwdata, hreadyi,
        input       hrdata, hreadyo, hresp
    endclocking

    modport master_tb   (clocking master_cb, input hclk, hreset_n);
    modport slave_tb    (clocking slave_cb, input hclk, hreset_n);
    // synopsys translate_on

endinterface
