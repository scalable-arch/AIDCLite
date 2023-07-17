// Copyright Sungkyunkwan University
// Author: Jungrae Kim <dale40@gmail.com>
// Description:

// Follows AMBA AXI protocol v1.0 specification, 2003
// (ARM IHI0022B)
// - Each channel in the AXI protocol has its own interface

// follows the names and conventions from AMBA 3 AXI standard

// can be used for AR and AW channels
interface AXI3_A_INTF
#(
    parameter   ID_WIDTH                = 4,
    parameter   ADDR_WIDTH              = 64
)
(
    input   wire                        aclk,
    input   wire                        areset_n
);

    logic   [ID_WIDTH-1:0]              aid;
    logic   [ADDR_WIDTH-1:0]            aaddr;
    logic   [3:0]                       alen;
    logic   [2:0]                       asize;
    logic   [1:0]                       aburst;
    logic   [1:0]                       alock;
    logic   [3:0]                       acache;
    logic   [2:0]                       aprot;
    logic                               avalid;
    logic                               aready;

    modport master (
        output      aid, aaddr, alen, asize, aburst, alock, acache, aprot, avalid,
        input       aready
    );

    modport slave (
        input       aid, aaddr, alen, asize, aburst, alock, acache, aprot, avalid,
        output      aready
    );

    // synopsys translate_off
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
    endfunction

    function reset_slave();
        aready                          = 'd0;
    endfunction

    clocking driver_cb_icnt_aw @(posedge aclk);
	    //default input #1 output #1;

        // on chip - w
        output          aid;
        output          aaddr;
        output          avalid;
        output          alen;
        output          asize;
        output          aburst;
        // dram - w
        input           aready;

    endclocking

    clocking driver_cb_mc_aw @(posedge aclk);
	    //default input #1 output #1;

        // on chip - w
        input          aid;
        input          aaddr;
        input          avalid;
        input          alen;
        input          asize;
        input          aburst;
        // dram - w
        output           aready;

    endclocking


    clocking driver_cb_icnt_ar @(posedge aclk);
	    //default input #1 output #1;

        // on chip - w
        output          aid;
        output          aaddr;
        output          avalid;
        output          alen;
        output          asize;
        output          aburst;
        // dram - w
        input           aready;

    endclocking

    clocking driver_cb_mc_ar @(posedge aclk);
	    //default input #1 output #1;

        // on chip - w
        input          aid;
        input          aaddr;
        input          avalid;
        input          alen;
        input          asize;
        input          aburst;
        // dram - w
        output           aready;

    endclocking

/*  clocking monitor_cb_icnt_aw @(posedge aclk);
	//default input #1 output #1;

        input          aid;
        input          aaddr;
        input          avalid;
        input          alen;
        input          asize;
        input          aburst;

        input          aready;

endclocking
*/
    clocking monitor_cb_mc_aw @(posedge aclk);
	    //default input #1 output #1;

        input          aid;
        input          aaddr;
        input          avalid;
        input          alen;
        input          asize;
        input          aburst;
        input          aready;

    endclocking

    clocking monitor_cb_mc_ar @(posedge aclk);
	    //default input #1 output #1;

        input          aid;
        input          aaddr;
        input          avalid;
        input          alen;
        input          asize;
        input          aburst;
        input          aready;

    endclocking

    modport DRIVER_ICNT_AW (clocking driver_cb_icnt_aw, input aclk, areset_n);
    modport DRIVER_MC_AW (clocking driver_cb_mc_aw, input aclk, areset_n);

    modport DRIVER_ICNT_AR (clocking driver_cb_icnt_ar, input aclk, areset_n);
    modport DRIVER_MC_AR (clocking driver_cb_mc_ar, input aclk, areset_n);

    // modport MONITOR_ICNT_AW (clocking monitor_cb_icnt_aw, input aclk, areset_n);
    modport MONITOR_MC_AW (clocking monitor_cb_mc_aw, input aclk, areset_n);
    modport MONITOR_MC_AR (clocking monitor_cb_mc_ar, input aclk, areset_n);
    // synopsys translate_on

endinterface

`define AXI3_A_INTF_CONNECT(SRC, DST) \
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
        SRC.aready                      = DST.aready; \
    end

interface AXI3_W_INTF
#(
    parameter   ID_WIDTH                = 4,
    parameter   DATA_WIDTH              = 32,
    parameter   STRB_WIDTH              = (DATA_WIDTH/8)
)
(
    input   wire                        aclk,
    input   wire                        areset_n
);

    logic   [ID_WIDTH-1:0]              wid;
    logic   [DATA_WIDTH-1:0]            wdata;
    logic   [STRB_WIDTH-1:0]            wstrb;
    logic                               wlast;
    logic                               wvalid;
    logic                               wready;

    modport master (
        output      wid, wdata, wstrb, wlast, wvalid,
        input       wready
    );

    modport slave (
        input       wid, wdata, wstrb, wlast, wvalid,
        output      wready
    );

    // synopsys translate_off
    function reset_master();
        wvalid                          = 'd0;
        wid                             = 'dx;
        wdata                           = 'dx;
        wstrb                           = 'dx;
        wlast                           = 'dx;
    endfunction

    function reset_slave();
        wready                          = 'd0;
    endfunction

    clocking driver_cb_icnt_w @(posedge aclk);
	    //default input #1 output #1;

        // on chip - w
        output          wid;
        output          wdata;
        output          wstrb;
        output          wlast;
        output          wvalid;
        // dram - w
        input           wready;
    endclocking

    clocking driver_cb_mc_w @(posedge aclk);
	    //default input #1 output #1;

	    // on chip - w
	    input           wid;
	    input           wdata;
	    input           wstrb;
	    input           wlast;
	    input           wvalid;
	    // dram - w
	    output          wready;
    endclocking

/*  clocking monitor_cb_icnt_w @(posedge aclk);
	//default input #1 output #1;

	// on chip - w
	input wready;
	// dram - w
	input wid;
	input wdata;
	input wstrb;
	input wlast;
	input wvalid;

endclocking
*/
    clocking monitor_cb_mc_w @(posedge aclk);
	    //default input #1 output #1;

	    // on chip - w
	    input           wready;
        // dram - w
        input           wid;
        input           wdata;
        input           wstrb;
        input           wlast;
        input           wvalid;
    endclocking

    modport DRIVER_ICNT_W (clocking driver_cb_icnt_w, input aclk, areset_n);
    modport DRIVER_MC_W (clocking driver_cb_mc_w, input aclk, areset_n);

    // modport MONITOR_ICNT_W (clocking monitor_cb_icnt_w, input aclk, areset_n);
    modport MONITOR_MC_W (clocking monitor_cb_mc_w, input aclk, areset_n);

    // synopsys translate_on

endinterface

`define AXI3_W_INTF_CONNECT(MASTER, SLAVE) \
    begin \
        SLAVE.wvalid                        = MASTER.wvalid; \
        SLAVE.wid                           = MASTER.wid; \
        SLAVE.wdata                         = MASTER.wdata; \
        SLAVE.wstrb                         = MASTER.wstrb; \
        SLAVE.wlast                         = MASTER.wlast; \
        MASTER.wready                       = SLAVE.wready; \
    end

interface AXI3_B_INTF
#(
    parameter   ID_WIDTH                = 4
)
(
    input   wire                        aclk,
    input   wire                        areset_n
);

    logic   [ID_WIDTH-1:0]              bid;
    logic   [1:0]                       bresp;
    logic                               bvalid;
    logic                               bready;

    modport master (
        input       bid, bresp, bvalid,
        output      bready
    );

    modport slave (
        output      bid, bresp, bvalid,
        input       bready
    );

    // synopsys translate_off
    function reset_master();
        bready                          = 'd0;
    endfunction

    function reset_slave();
        bvalid                          = 'd0;
        bid                             = 'dx;
        bresp                           = 'dx;
    endfunction
    // synopsys translate_on

endinterface

`define AXI3_B_INTF_CONNECT(MASTER, SLAVE) \
    begin \
        MASTER.bvalid                       = SLAVE.bvalid; \
        MASTER.bid                          = SLAVE.bid; \
        MASTER.bresp                        = SLAVE.bresp; \
        SLAVE.bready                        = MASTER.bready; \
    end

interface AXI3_R_INTF
#(
    parameter   ID_WIDTH                = 4,
    parameter   DATA_WIDTH              = 32
)
(
    input   wire                        aclk,
    input   wire                        areset_n
);

    logic   [ID_WIDTH-1:0]              rid;
    logic   [DATA_WIDTH-1:0]            rdata;
    logic   [1:0]                       rresp;
    logic                               rlast;
    logic                               rvalid;
    logic                               rready;

    modport master (
        input       rid, rdata, rresp, rlast, rvalid,
        output      rready
    );

    modport slave (
        output      rid, rdata, rresp, rlast, rvalid,
        input       rready
    );

    // synopsys translate_off
    function reset_master();
        rready                          = 'd0;
    endfunction

    function reset_slave();
        rvalid                          = 'd0;
        rid                             = 'dx;
        rdata                           = 'dx;
        rresp                           = 'dx;
        rlast                           = 'dx;
    endfunction

    clocking driver_cb_mc_r @(posedge aclk);
        // default input #1 output #1;

	    input               rready;
	    output              rid;
	    output              rdata;
	    output              rresp;
	    output              rlast;
	    output              rvalid;
    endclocking

    clocking driver_cb_icnt_r @(posedge aclk);
        // default input #1 output #1;

        output          rready;
        input           rid;
        input           rdata;
        input           rresp;
        input           rlast;
        input           rvalid;
    endclocking

    clocking monitor_cb_icnt_r @(posedge aclk);
        // default input #1 output #1;

	    input           rid;
        input           rresp;
        input           rdata;
        input           rlast;
        input           rvalid;
        input           rready;
    endclocking

    modport DRIVER_MC_R (clocking driver_cb_mc_r, input aclk, areset_n);
    modport DRIVER_ICNT_R (clocking driver_cb_icnt_r, input aclk, areset_n);

    //  modport MONITOR_MC_R (clocking monitor_cb_mc_r, input aclk, areset_n);
    modport MONITOR_ICNT_R (clocking monitor_cb_icnt_r, input aclk, areset_n);
    // synopsys translate_on

endinterface

`define AXI3_R_INTF_CONNECT(MASTER, SLAVE) \
    begin \
        MASTER.rvalid                       = SLAVE.rvalid; \
        MASTER.rid                          = SLAVE.rid; \
        MASTER.rdata                        = SLAVE.rdata; \
        MASTER.rresp                        = SLAVE.rresp; \
        MASTER.rlast                        = SLAVE.rlast; \
        SLAVE.rready                        = MASTER.rready; \
    end

/*
interface AXI_LP_INTF
(
    input   wire                        aclk,
    input   wire                        areset_n
);

    logic                               csysreq;
    logic                               csysack;
    logic                               cactive;

    modport clk_ctrl (
        output      csysreq,
        input       csysack, cactive
    );

    modport peri (
        input       csysreq,
        output      csysack, cactive
    );

endinterface
*/
