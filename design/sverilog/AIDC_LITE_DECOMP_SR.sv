module AIDC_LITE_DECOMP_SR
(
    input   wire                        clk,
    input   wire                        rst_n,

    // no backpressure
    input   wire                        valid_i,
    input   wire                        sop_i,
    input   wire                        eop_i,
    input   wire    [31:0]              data_i,

    output  logic                       valid_o,
    output  logic   [3:0]               addr_o,
    output  logic   [63:0]              data_o,
    output  logic                       done_o
);

    logic   [3:0]                       beat_cnt,   beat_cnt_n;
    logic                               done,       done_n;

    logic                               valid,      valid_n;
    // addr and data will be ORed to share a buffer among decompressors
    // Therefore, these signals must be 0 when the current decompressor
    // does not write (valid is deassert)
    logic   [3:0]                       addr,       addr_n;
    logic   [63:0]                      data,       data_n;

    always_comb begin
        beat_cnt_n                      = beat_cnt;
        done_n                          = done;
        valid_n                         = 1'b0;
        addr_n                          = 'd0;  // must be 0
        data_n                          = 'd0;  // must be 0

        if (valid_i) begin
            valid_n                         = 1'b1;
            addr_n                          = beat_cnt;
            if (sop_i) begin
                data_n[63:55]                   = data_i[30] ? 9'b111111111 : 9'b000000000;
                data_n[54:48]                   = data_i[30:24];
            end
            else begin
                data_n[63:56]                   = data_i[31] ? 8'b11111111 : 8'b00000000;
                data_n[55:48]                   = data_i[31:24];
            end
            data_n[47:40]                   = data_i[23] ? 8'b11111111 : 8'b00000000;
            data_n[39:32]                   = data_i[23:16];
            data_n[31:24]                   = data_i[15] ? 8'b11111111 : 8'b00000000;
            data_n[23:16]                   = data_i[15: 8];
            data_n[15: 8]                   = data_i[ 7] ? 8'b11111111 : 8'b00000000;
            data_n[ 7: 0]                   = data_i[ 7: 0];

            if (eop_i) begin
                beat_cnt_n                      = 'd0;
            end
            else begin
                beat_cnt_n                      = beat_cnt + 'd1;
            end

            if (sop_i) begin
                done_n                          = 1'b0;
            end
            else if (eop_i) begin
                done_n                          = 1'b1;
            end
        end
    end

    always_ff @(posedge clk)
        if (!rst_n) begin
            valid                           <= 1'b0;
            addr                            <= 'd0;
            data                            <= 'd0;

            beat_cnt                        <= 'd0;
            done                            <= 1'b0;
        end
        else begin
            valid                           <= valid_n;
            addr                            <= addr_n;
            data                            <= data_n;

            beat_cnt                        <= beat_cnt_n;
            done                            <= done_n;
        end

    //----------------------------------------------------------
    // Output assignments
    //----------------------------------------------------------
    assign  valid_o                         = valid;
    assign  addr_o                          = addr;
    assign  data_o                          = data;
    assign  done_o                          = done;

endmodule



