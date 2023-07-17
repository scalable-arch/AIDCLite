// Copyright Sungkyunkwan University
// Author: Jungrae Kim <dale40@gmail.com>
// Description:

interface FIFO_PUSH_INTF
#(
    parameter   DATA_WIDTH              = 32
)
(
    input   wire                        clk,
    input   wire                        rst_n
);

    logic                               full;
    logic                               afull;
    logic                               wren;
    logic   [DATA_WIDTH-1:0]            wdata;

    modport src (
        input       full,   afull,
        output      wren,   wdata
    );

    modport fifo (
        output      full,   afull,
        input       wren,   wdata
    );

endinterface

interface FIFO_POP_INTF
#(
    parameter   DATA_WIDTH              = 32
)
(
    input   wire                        clk,
    input   wire                        rst_n
);

    logic                               empty;
    logic                               aempty;
    logic                               rden;
    logic   [DATA_WIDTH-1:0]            rdata;

    modport fifo (
        output      empty,  aempty, rdata,
        input       rden
    );
    modport dst (
        input       empty,  aempty, rdata,
        output      rden
    );

endinterface

