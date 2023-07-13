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
    output  logic   [10:0]              blk_size_o
);

    logic   [2:0]                       cnt,        cnt_n;
    logic   [2:0]                       cnt_reg;

    logic                               valid,      valid_n;
    logic   [63:0]                      data,       data_n;
    logic                               done,       done_n;

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

    logic   [10:0]                      blk_size,   blk_size_n;
    logic   [CODE_BUF_SIZE-1:0]         code_buf,   code_buf_n;

    always_comb begin
        valid_n                         = 1'b0;
        data_n                          = data;
        done_n                          = done;

        cnt_n                           = cnt;
        blk_size_n                      = blk_size;
        code_buf_n                      = code_buf;

        if (valid_i) begin
            logic   [TMP_BUF_SIZE-1:0]      tmp_buf;

            // calculate new block size (in bits)
            blk_size_n                      = blk_size + size_i;
            // concate the old data and new data
            tmp_buf                         =  {code_buf, 64'd0}
                                             |({data_i, 62'd0}>>blk_size[5:0]);

            if (eop_i) begin
                // EOP -> flush the buffered data regardless of blk_size
                valid_n                         = 1'b1;
                data_n                          = tmp_buf[TMP_BUF_SIZE-1:TMP_BUF_SIZE-64];
                cnt_n                           = 'd0;

                // preload the 2-bit prefix for the next block
                blk_size_n                      = 'd2;
                code_buf_n[CODE_BUF_SIZE-1:CODE_BUF_SIZE-2] = PREFIX;
            end
            else if (blk_size_n[6]!=blk_size[6]) begin
                // if the new block size is different from the old size
                // in bit 6, it means a full 64-bit is ready
                valid_n                         = 1'b1;
                cnt_n                           = cnt + 'd1;
                data_n                          = tmp_buf[TMP_BUF_SIZE-1:TMP_BUF_SIZE-64];
                code_buf_n                      = tmp_buf[TMP_BUF_SIZE-65:0];
            end
            else begin
                // synopsys translate_off
                assert (blk_size_n[7]==blk_size[7]); // no +(128+) case
                // synopsys translate_on

                // partial data is ready
                valid_n                         = 1'b0;
                code_buf_n                      = tmp_buf[TMP_BUF_SIZE-1:TMP_BUF_SIZE-62];
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
        if  (~rst_n) begin
            valid                           <= 1'b0;
            cnt                             <= 'd0;
            cnt_reg                         <= 'd0;
            data                            <= 'd0;
            done                            <= 1'b1;

            // the default value is 2 to represent 2-bit prefix
            blk_size                        <= 'd2;
            code_buf                        <= 'd0;
        end
        else begin
            valid                           <= valid_n;
            cnt                             <= cnt_n;
            cnt_reg                         <= cnt;
            data                            <= data_n;
            done                            <= done_n;

            blk_size                        <= blk_size_n;
            code_buf                        <= code_buf_n;
        end

    //----------------------------------------------------------
    // Output assignments
    //----------------------------------------------------------
    assign  valid_o                         = valid;
    assign  addr_o                          = cnt_reg;
    assign  data_o                          = data;
    assign  done_o                          = done;
    assign  blk_size_o                      = blk_size;

endmodule
