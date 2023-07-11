module AIDC_LITE_COMP_BUFFER
(
    input   wire                        clk,
    input   wire                        rst_n,

    input   wire                        wren_i,
    input   wire    [3:0]               waddr_i,
    input   wire    [7:0]               wbe_i,
    input   wire    [63:0]              wdata_i,

    input   wire                        rden_i,
    input   wire    [3:0]               raddr_i,
    output  logic   [63:0]              rdata_o
);

endmodule
