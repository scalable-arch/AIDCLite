module AIDC_LITE_DECOMP_ZRLE
#(
    parameter   CODE_BUF_SIZE           = (512-2)
)
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
    logic                               valid,      valid_n;
    // addr and data will be ORed to share a buffer among decompressors
    // Therefore, these signals must be 0 when the current decompressor
    // does not write (valid is deassert)
    logic   [3:0]                       addr,       addr_n;
    logic   [63:0]                      data,       data_n;
    logic                               done,       done_n;
    
    logic   [CODE_BUF_SIZE-1:0]         code_buf,   code_buf_n;
    logic   [8:0]                       buf_size,   buf_size_n;
    logic   [4:0]                       cnt,        cnt_n;

    always_comb begin
        valid_n                         = 1'b0;
        addr_n                          = 'hX;
        data_n                          = 'hX;
        done_n                          = done;
        
        code_buf_n                      = code_buf;
        buf_size_n                      = buf_size;
        cnt_n                           = cnt;

        // output generation
        if (cnt < 'd8) begin
            casez (code_buf[CODE_BUF_SIZE-1:CODE_BUF_SIZE-6])
                6'b00_0000: begin   // Z-Z-Z-Z
                    if (size >= 'd6) begin
                        valid_n                         = 1'b1;
                        data_n                          = {16'd0,
                                                           16'd0,
                                                           16'd0,
                                                           16'd0};
                        buf_size_n                      = buf_size - 'd6;
                        code_buf_n                      = code_buf << 6;
                    end
                end
                6'b00_0001: begin   // Z-Z-Z-N
                    if (size >= 'd22) begin
                        valid_n                         = 1'b1;
                        data_n                          = {16'd0,
                                                           16'd0,
                                                           16'd0,
                                                           code_buf[CODE_BUF_SIZE-7 -: 16]};
                        buf_size_n                      = buf_size - 'd22;
                        code_buf_n                      = code_buf << 22;
                    end
                end
                6'b00_001?: begin   // Z-Z-N-Z
                    if (size >= 'd21) begin
                        valid_n                         = 1'b1;
                        data_n                          = {16'd0,
                                                           16'd0,
                                                           code_buf[CODE_BUF_SIZE-6 -: 16],
                                                           16'd0};
                        buf_size_n                      = buf_size - 'd21;
                        code_buf_n                      = code_buf << 21;
                    end
                end
                6'b00_010?: begin   // Z-N-Z-Z
                    if (size >= 'd21) begin
                        valid_n                         = 1'b1;
                        data_n                          = {16'd0,
                                                           code_buf[CODE_BUF_SIZE-6 -: 16],
                                                           16'd0,
                                                           16'd0};
                        buf_size_n                      = buf_size - 'd21;
                        code_buf_n                      = code_buf << 21;
                    end
                end
                6'b00_011?: begin   // N-Z-Z-Z
                    if (size >= 'd21) begin
                        valid_n                         = 1'b1;
                        data_n                          = {code_buf[CODE_BUF_SIZE-6 -: 16],
                                                           16'd0,
                                                           16'd0,
                                                           16'd0};
                        buf_size_n                      = buf_size - 'd21;
                        code_buf_n                      = code_buf << 21;
                    end
                end
                6'b00_10??: begin   // Z-Z-N-N
                    if (size >= 'd36) begin
                        valid_n                         = 1'b1;
                        data_n                          = {16'd0,
                                                           16'd0,
                                                           code_buf[CODE_BUF_SIZE-5 -: 16],
                                                           code_buf[CODE_BUF_SIZE-21 -: 16]};
                        buf_size_n                      = buf_size - 'd36;
                        code_buf_n                      = code_buf << 36;
                    end
                end
                6'b00_11??: begin   // Z-N-Z-N
                    if (size >= 'd36) begin
                        valid_n                         = 1'b1;
                        data_n                          = {16'd0,
                                                           code_buf[CODE_BUF_SIZE-5 -: 16],
                                                           16'd0,
                                                           code_buf[CODE_BUF_SIZE-21 -: 16]};
                        buf_size_n                      = buf_size - 'd36;
                        code_buf_n                      = code_buf << 36;
                    end
                end
                6'b01_00??: begin   // N-Z-Z-N
                    if (size >= 'd36) begin
                        valid_n                         = 1'b1;
                        data_n                          = {code_buf[CODE_BUF_SIZE-5 -: 16],
                                                           16'd0,
                                                           16'd0,
                                                           code_buf[CODE_BUF_SIZE-21 -: 16]};
                        buf_size_n                      = buf_size - 'd36;
                        code_buf_n                      = code_buf << 36;
                    end
                end
                6'b01_01??: begin   // Z-N-N-Z
                    if (size >= 'd36) begin
                        valid_n                         = 1'b1;
                        data_n                          = {16'd0,
                                                           code_buf[CODE_BUF_SIZE-5 -: 16],
                                                           code_buf[CODE_BUF_SIZE-21 -: 16],
                                                           16'd0};
                        buf_size_n                      = buf_size - 'd36;
                        code_buf_n                      = code_buf << 36;
                    end
                end
                6'b01_10??: begin   // N-Z-N-Z
                    if (size >= 'd36) begin
                        valid_n                         = 1'b1;
                        data_n                          = {code_buf[CODE_BUF_SIZE-5 -: 16],
                                                           16'd0,
                                                           code_buf[CODE_BUF_SIZE-21 -: 16],
                                                           16'd0};
                        buf_size_n                      = buf_size - 'd36;
                        code_buf_n                      = code_buf << 36;
                    end
                end
                6'b01_11??: begin   // N-N-Z-Z
                    if (size >= 'd36) begin
                        valid_n                         = 1'b1;
                        data_n                          = {code_buf[CODE_BUF_SIZE-5 -: 16],
                                                           code_buf[CODE_BUF_SIZE-21 -: 16],
                                                           16'd0,
                                                           16'd0};
                        buf_size_n                      = buf_size - 'd36;
                        code_buf_n                      = code_buf << 36;
                    end
                end
                6'b10_00??: begin   // Z-N-N-N
                    if (size >= 'd52) begin
                        valid_n                         = 1'b1;
                        data_n                          = {16'd0,
                                                           code_buf[CODE_BUF_SIZE-5 -: 16],
                                                           code_buf[CODE_BUF_SIZE-21 -: 16],
                                                           code_buf[CODE_BUF_SIZE-37 -: 16]};
                        buf_size_n                      = buf_size - 'd52;
                        code_buf_n                      = code_buf << 52;
                    end
                end
                6'b10_01??: begin   // N-Z-N-N
                    if (size >= 'd52) begin
                        valid_n                         = 1'b1;
                        data_n                          = {code_buf[CODE_BUF_SIZE-5 -: 16],
                                                           16'd0,
                                                           code_buf[CODE_BUF_SIZE-21 -: 16],
                                                           code_buf[CODE_BUF_SIZE-37 -: 16]};
                        buf_size_n                      = buf_size - 'd52;
                        code_buf_n                      = code_buf << 52;
                    end
                end
                6'b10_10??: begin   // N-N-Z-N
                    if (size >= 'd52) begin
                        valid_n                         = 1'b1;
                        data_n                          = {code_buf[CODE_BUF_SIZE-5 -: 16],
                                                           code_buf[CODE_BUF_SIZE-21 -: 16],
                                                           16'd0,
                                                           code_buf[CODE_BUF_SIZE-37 -: 16]};
                        buf_size_n                      = buf_size - 'd52;
                        code_buf_n                      = code_buf << 52;
                    end
                end
                6'b10_11??: begin   // N-N-N-Z
                    if (size >= 'd52) begin
                        valid_n                         = 1'b1;
                        data_n                          = {code_buf[CODE_BUF_SIZE-5 -: 16],
                                                           code_buf[CODE_BUF_SIZE-21 -: 16],
                                                           code_buf[CODE_BUF_SIZE-37 -: 16],
                                                           16'd0};
                        buf_size_n                      = buf_size - 'd52;
                        code_buf_n                      = code_buf << 52;
                    end
                end
                default: begin  // 6'b11_????   // N-N-N-N
                    if (size >= 'd66) begin
                        valid_n                         = 1'b1;
                        data_n                          = code_buf[CODE_BUF_SIZE-3 -: 64];
                        buf_size_n                      = buf_size - 'd66;
                        code_buf_n                      = code_buf << 66;
                    end
                end
            endcase
        end

        if (valid_n) begin
            cnt_n                           = cnt + 'd1;
        end

        // input buffer
        if (valid_i) begin
            if (sop_i) begin
                // upper 2 bits, containing prefix, is discarded
                code_buf_n[CODE_BUF_SIZE-1 -: 30] = data_i[29:0];
                buf_size_n                      = 'd30;
                cnt_n                           = 'd0;
                done_n                          = 1'b0;
            end
            else begin
                code_buf_n                      = code_buf_n
                                                 |({data_i[31:0], {CODE_BUF_SIZE{1'b0}}} >> size_n);
                buf_size_n                      = buf_size_n + 'd32;
            end
        end
    end

    always_ff @(posedge clk)
        if (!rst_n) begin
            valid                           <= 1'b0;
            addr                            <= 'd0;
            data                            <= 'd0;
            done                            <= 1'b0;
            
            code_buf                        <= 'd0;
            buf_size                        <= 'd0;
            cnt                             <= 'd0;
        end
        else begin
            valid                           <= valid_n;
            addr                            <= addr_n;
            data                            <= data_n;
            done                            <= done_n;
            
            code_buf                        <= code_buf_n;
            buf_size                        <= buf_size_n;
            cnt                             <= cnt_n;
        end

    //----------------------------------------------------------
    // Output assignments
    //----------------------------------------------------------
    assign  valid_o                         = valid;
    assign  addr_o                          = addr;
    assign  data_o                          = data;
    assign  done_o                          = done;

endmodule


