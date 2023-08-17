// Copyright Sungkyunkwan University
// Author: Jungrae Kim <dale40@gmail.com>
// Description:

// Follows AMBA2 AHB v1.0 specification, 1999
// (ARM IHI 0011A)

package AHB2_PKG;
    localparam  logic   [1:0]           HTRANS_IDLE     = 2'b00;
    localparam  logic   [1:0]           HTRANS_BUSY     = 2'b01;
    localparam  logic   [1:0]           HTRANS_NONSEQ   = 2'b10;
    localparam  logic   [1:0]           HTRANS_SEQ      = 2'b11;
    
    localparam  logic   [1:0]           HRESP_OKAY      = 2'b00;
    localparam  logic   [1:0]           HRESP_ERROR     = 2'b01;
    localparam  logic   [1:0]           HRESP_RETRY     = 2'b10;
    localparam  logic   [1:0]           HRESP_SPLIT     = 2'b11;
    
    localparam  logic   [2:0]           HBURST_SINGLE   = 3'b000;
    localparam  logic   [2:0]           HBURST_INCR     = 3'b001;
    localparam  logic   [2:0]           HBURST_WRAP4    = 3'b010;
    localparam  logic   [2:0]           HBURST_INCR4    = 3'b011;
    localparam  logic   [2:0]           HBURST_WRAP8    = 3'b100;
    localparam  logic   [2:0]           HBURST_INCR8    = 3'b101;
    localparam  logic   [2:0]           HBURST_WRAP16   = 3'b110;
    localparam  logic   [2:0]           HBURST_INCR16   = 3'b111;
    
    localparam  logic   [2:0]           HSIZE_8BITS     = 3'b000;
    localparam  logic   [2:0]           HSIZE_16BITS    = 3'b001;
    localparam  logic   [2:0]           HSIZE_32BITS    = 3'b010;
    localparam  logic   [2:0]           HSIZE_64BITS    = 3'b011;
    localparam  logic   [2:0]           HSIZE_128BITS   = 3'b100;
    localparam  logic   [2:0]           HSIZE_256BITS   = 3'b101;
    localparam  logic   [2:0]           HSIZE_512BITS   = 3'b110;
    localparam  logic   [2:0]           HSIZE_1024BITS  = 3'b111;

endpackage
