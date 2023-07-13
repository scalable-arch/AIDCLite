module AIDC_LITE_BUFFER
#(
    parameter   ADDR_WIDTH              = 3
)
(
    input   wire                        clk,
    input   wire                        rst_n,

    input   wire                        wren_i,
    input   wire    [ADDR_WIDTH-1:0]    waddr_i,
    input   wire    [63:0]              wdata_i,

    input   wire    [ADDR_WIDTH-1:0]    raddr_i,
    output  logic   [63:0]              rdata_o
);

    localparam  ADDR_CNT                = (1<<ADDR_WIDTH);

    logic   [63:0]                      mem[ADDR_CNT-1:0];

    always_ff @(posedge clk)
        if (wren_i) begin
            mem[waddr_i]                    <= wdata_i;
        end

    assign  rdata_o                     = mem[raddr_i];

endmodule
