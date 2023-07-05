// Copyright Sungkyunkwan University
// Author: Jungrae Kim <dale40@gmail.com>
// Description:

// Follows AMBA 3 AHB-Lite v1.0 specification, 2006
// (ARM IHI0033A)

interface AHB_LITE_INTF
#(
    parameter   ADDR_WIDTH              = 32,
    parameter   DATA_WIDTH              = 32
)
(
    input   wire                        hclk,
    input   wire                        hreset_n
);

    logic   [ADDR_WIDTH-1:0]            haddr;
    logic                               hmasterlock;
    logic   [3:0]                       hprot;
    logic   [2:0]                       hsize;
    logic   [1:0]                       htrans;
    logic   [DATA_WIDTH-1:0]            hwdata;
    logic                               hwrite;
    logic   [DATA_WIDTH-1:0]            hrdata;
    logic                               hreadyout;
    logic                               hresp;

    modport master (
        output      haddr, hmasterlock, hprot, hsize, htrans, hwdata, hwrite,
        input       hrdata, hreadyout, hresp
    );
    modport slave (
        input      haddr, hmasterlock, hprot, hsize, htrans, hwdata, hwrite,
        output     hrdata, hreadyout, hresp
    );

    // synthesis translate_off
    // - for verification only
    // synthesis translate_on

endinterface
