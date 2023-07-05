// Copyright Sungkyunkwan University
// Author: Jungrae Kim <dale40@gmail.com>
// Description:

// Follows AMBA AXI and ACE protocol specification, 2013
// (ARM IHI0022E)
// - Each channel in the AXI protocol has its own interface

// follows the names and conventions from AMBA 4 AXI standard

// can be used for AR and AW channels
interface AXI4_A_INTF
#(
    parameter   ID_WIDTH                = 4,
    parameter   ADDR_WIDTH              = 64,
    parameter   USER_WIDTH              = 1
)
(
    input   wire                        aclk,
    input   wire                        areset_n
);

    logic   [ID_WIDTH-1:0]              aid;
    logic   [ADDR_WIDTH-1:0]            aaddr;
    logic   [7:0]                       alen;
    logic   [2:0]                       asize;
    logic   [1:0]                       aburst;
    logic                               alock;
    logic   [3:0]                       acache;
    logic   [2:0]                       aprot;
    logic   [3:0]                       aqos;
    logic   [3:0]                       aregion;
    logic   [USER_WIDTH-1:0]            auser;
    logic                               avalid;
    logic                               aready;

    modport master (
        output      aid, aaddr, alen, asize, aburst, alock, acache, aprot, avalid,
        output      aqos, aregion, auser,        // AXI4 only
        input       aready
    );

    modport slave (
        input       aid, aaddr, alen, asize, aburst, alock, acache, aprot, avalid,
        input       aqos, aregion, auser,        // AXI4 only
        output      aready
    );

    function reset_master();
        avalid                          = 'd0;
        aid                             = 'dx;
        aaddr                           = 'dx;
        alen                            = 'dx;
        asize                           = 'dx;
        aburst                          = 'dx;
        alock                           = 'dx;
        acache                          = 'dx;
        aprot                           = 'dx;
        aqos                            = 'dx;
        aregion                         = 'dx;
        auser                           = 'dx;
    endfunction

    function reset_slave();
        aready                          = 'd0;
    endfunction

endinterface

`define AXI4_A_INTF_CONNECT(SRC, DST) \
    begin \
        DST.avalid                      = SRC.avalid; \
        DST.aid                         = SRC.aid; \
        DST.aaddr                       = SRC.aaddr; \
        DST.alen                        = SRC.alen; \
        DST.asize                       = SRC.asize; \
        DST.aburst                      = SRC.aburst; \
        DST.alock                       = SRC.alock; \
        DST.acache                      = SRC.acache; \
        DST.aprot                       = SRC.aprot; \
        DST.aqos                        = SRC.aqos; \
        DST.aregion                     = SRC.aregion; \
        DST.auser                       = SRC.aprot; \
        SRC.aready                      = DST.aready; \
    end

interface AXI4_W_INTF
#(
    parameter   ID_WIDTH                = 4,
    parameter   DATA_WIDTH              = 512,
    parameter   STRB_WIDTH              = (DATA_WIDTH/8),
    parameter   USER_WIDTH              = 1
)
(
    input   wire                        aclk,
    input   wire                        areset_n
);

    logic   [ID_WIDTH-1:0]              wid;
    logic   [DATA_WIDTH-1:0]            wdata;
    logic   [STRB_WIDTH-1:0]            wstrb;
    logic                               wlast;
    logic   [USER_WIDTH-1:0]            wuser;
    logic                               wvalid;
    logic                               wready;

    modport master (
        output      wid, wdata, wstrb, wlast, wvalid,
        output      wuser,              // AXI4 only
        input       wready
    );

    modport slave (
        input       wid, wdata, wstrb, wlast, wvalid,
        input       wuser,              // AXI4 only
        output      wready
    );

    function reset_master();
        wvalid                          = 'd0;
        wid                             = 'dx;
        wdata                           = 'dx;
        wstrb                           = 'dx;
        wlast                           = 'dx;
        wuser                           = 'dx;
    endfunction

    function reset_slave();
        wready                          = 'd0;
    endfunction

endinterface

`define AXI4_W_INTF_CONNECT(MASTER, SLAVE) \
    begin \
        SLAVE.wvalid                        = MASTER.wvalid; \
        SLAVE.wid                           = MASTER.wid; \
        SLAVE.wdata                         = MASTER.wdata; \
        SLAVE.wstrb                         = MASTER.wstrb; \
        SLAVE.wlast                         = MASTER.wlast; \
        SLAVE.wuser                         = MASTER.wuser; \
        MASTER.wready                       = SLAVE.wready; \
    end

interface AXI4_B_INTF
#(
    parameter   ID_WIDTH                = 4,
    parameter   USER_WIDTH              = 1
)
(
    input   wire                        aclk,
    input   wire                        areset_n
);

    logic   [ID_WIDTH-1:0]              bid;
    logic   [1:0]                       bresp;
    logic   [USER_WIDTH-1:0]            buser;
    logic                               bvalid;
    logic                               bready;

    modport master (
        input       bid, bresp, bvalid,
        input       buser,              // AXI4 only
        output      bready
    );

    modport slave (
        output      bid, bresp, bvalid,
        output      buser,              // AXI4 only
        input       bready
    );

    function reset_master();
        bready                          = 'd0;
    endfunction

    function reset_slave();
        bvalid                          = 'd0;
        bid                             = 'dx;
        bresp                           = 'dx;
        buser                           = 'dx;
    endfunction

endinterface

`define AXI4_B_INTF_CONNECT(MASTER, SLAVE) \
    begin \
        MASTER.bvalid                       = SLAVE.bvalid; \
        MASTER.bid                          = SLAVE.bid; \
        MASTER.bresp                        = SLAVE.bresp; \
        MASTER.buser                        = SLAVE.buser; \
        SLAVE.bready                        = MASTER.bready; \
    end

interface AXI4_R_INTF
#(
    parameter   ID_WIDTH                = 4,
    parameter   DATA_WIDTH              = 512,
    parameter   USER_WIDTH              = 1
)
(
    input   wire                        aclk,
    input   wire                        areset_n
);

    logic   [ID_WIDTH-1:0]              rid;
    logic   [DATA_WIDTH-1:0]            rdata;
    logic   [1:0]                       rresp;
    logic                               rlast;
    logic   [USER_WIDTH-1:0]            ruser;
    logic                               rvalid;
    logic                               rready;

    modport master (
        input       rid, rdata, rresp, rlast, rvalid,
        input       ruser,              // AXI4 only
        output      rready
    );

    modport slave (
        output      rid, rdata, rresp, rlast, rvalid,
        output      ruser,              // AXI4 only
        input       rready
    );

    function reset_master();
        rready                          = 'd0;
    endfunction

    function reset_slave();
        rvalid                          = 'd0;
        rid                             = 'dx;
        rdata                           = 'dx;
        rresp                           = 'dx;
        rlast                           = 'dx;
        ruser                           = 'dx;
    endfunction

endinterface

`define AXI4_R_INTF_CONNECT(MASTER, SLAVE) \
    begin \
        MASTER.rvalid                       = SLAVE.rvalid; \
        MASTER.rid                          = SLAVE.rid; \
        MASTER.rdata                        = SLAVE.rdata; \
        MASTER.rresp                        = SLAVE.rresp; \
        MASTER.rlast                        = SLAVE.rlast; \
        MASTER.ruser                        = SLAVE.ruser; \
        SLAVE.rready                        = MASTER.rready; \
    end
