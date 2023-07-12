module AIDC_LITE_COMP_BUFFER
(
    input   wire                        clk,
    input   wire                        rst_n,

    input   wire                        wren_i,
    input   wire    [3:0]               waddr_i,
    input   wire    [63:0]              wdata_i,

    input   wire    [3:0]               raddr_i,
    output  logic   [63:0]              rdata_o
);

    logic   [63:0]                      mem[15:0];

    always_ff @(posedge clk)
        if (wren_i) begin
            mem[waddr_i]                    <= wdata_i;
        end

    assign  rdata_o                     = mem[raddr_i];

endmodule
