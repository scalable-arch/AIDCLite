interface AXI3_A_INTF
#(
    parameter   ADDR_WIDTH      = `AXI_ADDR_WIDTH,      // 32
    parameter   ID_WIDTH        = `AXI_ID_WIDTH,        // 4
    parameter   ADDR_LEN        = 4                               // question 04.07
 )
(
    input                       clk,
    input                       rst_n
);
    logic                       avalid;
    logic                       aready;
    logic   [ID_WIDTH-1:0]      aid;
    logic   [ADDR_WIDTH-1:0]    aaddr;
    logic   [ADDR_LEN-1:0]      alen;                   
    logic   [2:0]               asize;
    logic   [1:0]               aburst;

    clocking driver_cb_icnt_aw @(posedge clk);
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
	
    clocking driver_cb_mc_aw @(posedge clk);
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


    clocking driver_cb_icnt_ar @(posedge clk);
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
	
    clocking driver_cb_mc_ar @(posedge clk);
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

/*  clocking monitor_cb_icnt_aw @(posedge clk);
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
    clocking monitor_cb_mc_aw @(posedge clk);
	    //default input #1 output #1;

        input          aid;	
        input          aaddr;       
        input          avalid;
        input          alen;
        input          asize;
        input          aburst;
        input          aready;

    endclocking

    clocking monitor_cb_mc_ar @(posedge clk);
	    //default input #1 output #1;

        input          aid;	
        input          aaddr;       
        input          avalid;
        input          alen;
        input          asize;
        input          aburst;
        input          aready;

    endclocking

    modport DRIVER_ICNT_AW (clocking driver_cb_icnt_aw, input clk, rst_n);
    modport DRIVER_MC_AW (clocking driver_cb_mc_aw, input clk, rst_n);

    modport DRIVER_ICNT_AR (clocking driver_cb_icnt_ar, input clk, rst_n);
    modport DRIVER_MC_AR (clocking driver_cb_mc_ar, input clk, rst_n);

    // modport MONITOR_ICNT_AW (clocking monitor_cb_icnt_aw, input clk, rst_n);
    modport MONITOR_MC_AW (clocking monitor_cb_mc_aw, input clk, rst_n);
    modport MONITOR_MC_AR (clocking monitor_cb_mc_ar, input clk, rst_n);

endinterface

interface AXI3_W_INTF
#(
    parameter   DATA_WIDTH      = `AXI_DATA_WIDTH,
    parameter   ID_WIDTH        = `AXI_ID_WIDTH
 )
(
    input                       clk,
    input                       rst_n
);
    logic                       wvalid;
    logic                       wready;
    logic   [ID_WIDTH-1:0]      wid;
    logic   [DATA_WIDTH-1:0]    wdata;
    logic   [DATA_WIDTH/8-1:0]  wstrb;
    logic                       wlast;

    clocking driver_cb_icnt_w @(posedge clk);
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
	
    clocking driver_cb_mc_w @(posedge clk);
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

/*  clocking monitor_cb_icnt_w @(posedge clk);
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
    clocking monitor_cb_mc_w @(posedge clk);
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

    modport DRIVER_ICNT_W (clocking driver_cb_icnt_w, input clk, rst_n);
    modport DRIVER_MC_W (clocking driver_cb_mc_w, input clk, rst_n);

    // modport MONITOR_ICNT_W (clocking monitor_cb_icnt_w, input clk, rst_n);
    modport MONITOR_MC_W (clocking monitor_cb_mc_w, input clk, rst_n);

endinterface

interface AXI3_B_INTF
#(
    parameter   ID_WIDTH        = `AXI_ID_WIDTH
 )
(
    input                       clk,
    input                       rst_n
);
    logic                       bvalid;
    logic                       bready;
    logic   [ID_WIDTH-1:0]      bid;
    logic   [1:0]               bresp;

endinterface



interface AXI3_R_INTF
#(
    parameter   DATA_WIDTH      = `AXI_DATA_WIDTH,
    parameter   ID_WIDTH        = `AXI_ID_WIDTH
 )
(
    input                       clk,
    input                       rst_n
);
    logic                       rvalid;
    logic                       rready;
    logic   [ID_WIDTH-1:0]      rid;
    logic   [DATA_WIDTH-1:0]    rdata;
    logic   [1:0]               rresp;
    logic                       rlast;

    // For verification
    // synthesis translate_off
    clocking driver_cb_mc_r @(posedge clk);
    //default input #1 output #1;

	    // on chip - r
	    input               rready;
	    // dram - r
	    output              rid;
	    output              rdata;
	    output              rresp;
	    output              rlast;
	    output              rvalid;
    endclocking

    clocking driver_cb_icnt_r @(posedge clk);
	//    default input #1 output #1;

        // on chip - r
        output          rready;
        // dram - r
        input           rid;
        input           rdata;
        input           rresp;
        input           rlast;
        input           rvalid;
    endclocking

    clocking monitor_cb_icnt_r @(posedge clk);
	    //default input #1 output #1;

	    // on chip - r
	    input           rid;
        input           rresp;
        input           rdata;
        input           rlast;
        input           rvalid;
        // dram - r
        input           rready;
    endclocking

    modport DRIVER_MC_R (clocking driver_cb_mc_r, input clk, rst_n);
    modport DRIVER_ICNT_R (clocking driver_cb_icnt_r, input clk, rst_n);

    //  modport MONITOR_MC_R (clocking monitor_cb_mc_r, input clk, rst_n);
    modport MONITOR_ICNT_R (clocking monitor_cb_icnt_r, input clk, rst_n);
    // synthesis translate_on
endinterface
