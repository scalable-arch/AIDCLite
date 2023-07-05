// Copyright Sungkyunkwan University
// Author: Jungrae Kim <dale40@gmail.com>
// Description:

// Follows AMBA2 AHB v1.0 specification, 1999
// (ARM IHI 0011A)

interface AHB2_INTF
#(
    parameter   ADDR_WIDTH              = 32,
    parameter   DATA_WIDTH              = 32
)
(
    input   wire                        hclk,
    input   wire                        hreset_n
);

    logic                               hbusreq;
    logic                               hgrant;

    logic   [ADDR_WIDTH-1:0]            haddr;
    logic   [1:0]                       htrans;
    logic                               hwrite;
    logic   [2:0]                       hsize;
    logic   [2:0]                       hburst;
    logic   [3:0]                       hprot;
    logic   [DATA_WIDTH-1:0]            hwdata;

    logic                               hmasterlock;
    logic   [DATA_WIDTH-1:0]            hrdata;
    logic                               hready;
    logic   [1:0]                       hresp;

    modport master (
        output      hbusreq, haddr, hmasterlock, hprot, hsize, htrans, hwdata, hwrite,
        input       hgrant, hrdata, hreadyout, hresp
    );
    modport slave (
        input      hbusreq, haddr, hmasterlock, hprot, hsize, htrans, hwdata, hwrite,
        output     hgrant, hrdata, hreadyout, hresp
    );

    // synthesis translate_off
    // - for verification only
    // synthesis translate_on

endinterface
