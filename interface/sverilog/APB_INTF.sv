// Copyright Sungkyunkwan University
// Author: Jungrae Kim <dale40@gmail.com>
// Description:

// Follows AMBA 3 APB Protocol v1.0 specification, 2004
// (ARM IHI0024B)

interface APB_INTF
#(
    parameter   ADDR_WIDTH              = 32,
    parameter   DATA_WIDTH              = 32
)
(
    input   wire                        pclk,
    input   wire                        preset_n
);
    logic   [ADDR_WIDTH-1:0]            paddr;
    logic                               psel;
    logic                               penable;
    logic                               pwrite;
    logic   [DATA_WIDTH-1:0]            pwdata;
    logic                               pready;
    logic   [DATA_WIDTH-1:0]            prdata;
    logic                               pslverr;

    modport master (
        output      paddr, psel, penable, pwrite, pwdata,
        input       pready, prdata, pslverr
    );
    modport slave (
        input       paddr, psel, penable, pwrite, pwdata,
        output      pready, prdata, pslverr
    );

    // synthesis translate_off
    // - for verification only
    task reset_master();
        paddr                           = 'hx;
        psel                            = 1'b0;
        penable                         = 1'b0;
        pwrite                          = 'hx;
        pwdata                          = 'hx;
    endtask

    task write (input logic [31:0]      addr,
                input logic [31:0]      data);
        #1
        psel                            = 1'b1;
        penable                         = 1'b0;
        paddr                           = addr;
        pwrite                          = 1'b1;
        pwdata                          = data;
        @(posedge pclk)
        #1
        penable                         = 1'b1;
        @(posedge pclk)
        #1
        while (pready==1'b0) begin
            @(posedge pclk)
            #1 ;
        end
        reset_master();
    endtask;

    task read (input logic [31:0]       addr,
               input logic [31:0]       data);
        #1
        psel                            = 1'b1;
        penable                         = 1'b0;
        paddr                           = addr;
        pwrite                          = 1'b0;
        pwdata                          = 'hx;
        @(posedge pclk)
        #1
        penable                         = 1'b1;
        @(posedge pclk)
        #1
        while (pready==1'b0) begin
            @(posedge pclk)
            #1 ;
        end
        data                            = prdata;
        reset_master();
    endtask;
    // synthesis translate_on

endinterface
