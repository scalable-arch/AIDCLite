module AIDC_LITE_CODE_CONCATENATE
#(
    parameter   PREFIX                  = 2'b00,
    parameter   DATA_SIZE               = 66,
    parameter   CODE_BUF_SIZE           = 62
)
(
    input   wire                        clk,
    input   wire                        rst_n,

    // no backpressure
    input   wire                        valid_i,
    input   wire                        sop_i,
    input   wire                        eop_i,
    input   wire    [DATA_SIZE-1:0]     data_i,
    input   wire    [6:0]               size_i,

    output  logic                       valid_o,
    output  logic   [2:0]               addr_o,
    output  logic   [63:0]              data_o,
    output  logic                       done_o,
    output  logic                       fail_o
);

    logic                               valid,      valid_n;
    logic   [4:0]                       addr,       addr_n;  // +2 bits
    logic   [63:0]                      data,       data_n;
    logic                               done,       done_n;
    logic                               fail,       fail_n;

    // clk      : __--__--__--__--__--__--__--__--__--__--__--__--__--__--__--
    // valid_i  : ______------------------------
    // eop_i    : ______________________________
    // data_i   :       |D0 |D1 |D2 |D3 |D4 |D5 |
    // size_i   :       | 6 |34 |34 |34 |34 |34 |

    // blk_size :     2     | 8 |42 |76 |120|156|
    ///////////////////////////////////////////////
    // code_buf :        PREFIX     |   D2' |D4'|
    // (upper)              |   D0  |   |D3 |
    //    |                     |D1 |
    // code_buf                     |
    // (lower)
    //////////////////////////////////////////////////////
    // valid_o  : __________________----____----____
    // data_o   :                   |PRE|   |D2'|
    //                              |D0 |   |D3 |
    //                              |D1 |   |D4 |
    //                              |D2 |

    localparam  TMP_BUF_SIZE            = 64 + CODE_BUF_SIZE;
    logic   [TMP_BUF_SIZE-1:0]          tmp_buf;

    logic   [CODE_BUF_SIZE-1:0]         code_buf,   code_buf_n;
    logic   [10:0]                      blk_size,   blk_size_n;
    logic   [10:0]                      buf_size,   buf_size_n;
    logic                               flush,      flush_n;

    always_comb begin
        valid_n                         = 1'b0;
        addr_n                          = addr;
        data_n                          = data;
        done_n                          = done;
        fail_n                          = fail;

        code_buf_n                      = code_buf;
        blk_size_n                      = blk_size;
        buf_size_n                      = buf_size;
        flush_n                         = flush;

        if (valid_i) begin
            // new data arrived
            if (sop_i) begin
                done_n                          = 1'b0;
                fail_n                          = 1'b0;
                flush_n                         = 1'b0;
                addr_n                          = 'd0;
            end
            if (eop_i) begin
                flush_n                         = 1'b1;
            end

            // calculate new block size (in bits)
            blk_size_n                      = blk_size + size_i;
            buf_size_n                      = buf_size + size_i;
            // concate the old data and new data
            tmp_buf                         =  {code_buf, 64'd0}        // 62 + 64
                                             |({data_i, 60'd0}>>blk_size[5:0]);
        end

        if (buf_size_n >= 'd64) begin
            // enough data has accumulated   -> forward
            valid_n                         = (addr < 'd8);   // write up to 8 words
            addr_n                          = addr_n + 'd1;
            data_n                          = tmp_buf[TMP_BUF_SIZE-1:TMP_BUF_SIZE-64];

            if ((buf_size_n == 'd64) & flush_n) begin
                done_n                          = 1'b1;
                fail_n                          = (blk_size > 'd512);
                flush_n                         = 1'b0;

                code_buf_n[CODE_BUF_SIZE-1:CODE_BUF_SIZE-2] = PREFIX;
                code_buf_n[CODE_BUF_SIZE-3:0]   = 'd0;
                blk_size_n                      = 'd2;
                buf_size_n                      = 'd2;
            end
            else begin                
                // shift 64 bits
                code_buf_n                      = tmp_buf[TMP_BUF_SIZE-65:0];
                buf_size_n                      = buf_size_n - 'd64;
            end
        end
        else begin 
            if (flush_n) begin
                valid_n                         = 1'b1;
                data_n                          = tmp_buf[TMP_BUF_SIZE-1:TMP_BUF_SIZE-64];

                done_n                          = 1'b1;
                fail_n                          = (blk_size > 'd512);
                flush_n                         = 1'b0;

                code_buf_n[CODE_BUF_SIZE-1:CODE_BUF_SIZE-2] = PREFIX;
                code_buf_n[CODE_BUF_SIZE-3:0]   = 'd0;
                blk_size_n                      = 'd2;
                buf_size_n                      = 'd2;
            end
        end
    end

    always_ff @(posedge clk)
        if  (~rst_n) begin
            valid                           <= 1'b0;
            addr                            <= 'd0;
            data                            <= 'd0;
            done                            <= 1'b1;
            fail                            <= 1'b0;

            // preload the 2-bit prefix for the next block
            code_buf[CODE_BUF_SIZE-1:CODE_BUF_SIZE-2] <= PREFIX;
            code_buf[CODE_BUF_SIZE-3:0]     <= 'd0;
            blk_size                        <= 'd2;
            buf_size                        <= 'd2;
        end
        else begin
            valid                           <= valid_n;
            addr                            <= addr_n;
            data                            <= data_n;
            done                            <= done_n;
            fail                            <= fail_n;

            code_buf                        <= code_buf_n;
            blk_size                        <= blk_size_n;
            buf_size                        <= buf_size_n;
        end

    //----------------------------------------------------------
    // Output assignments
    //----------------------------------------------------------
    assign  valid_o                         = valid;
    assign  addr_o                          = addr[2:0];
    assign  data_o                          = data;
    assign  done_o                          = done;
    assign  fail_o                          = fail;

endmodule
