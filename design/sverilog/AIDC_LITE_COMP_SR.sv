module AIDC_LITE_COMP_SR
(
    input   wire                        clk,
    input   wire                        rst_n,

    // no backpressure
    input   wire                        valid_i,
    input   wire                        sop_i,
    input   wire                        eop_i,
    input   wire    [63:0]              data_i,

    output  logic                       valid_o,
    output  logic   [3:0]               addr_o,
    output  logic   [63:0]              data_o,
    output  logic                       fail_o  // valid on eop
);

    // clk      : __--__--__--__--__--__--__ ... --__--__--__--__--__
    // valid_i  : ______-------------------- ... --------____________
    // sop_i    : ______----________________ ... ____________________
    // eop_i    : __________________________ ... ____----____________
    // data_i   :       |D0 |D1 |D2 |D3 |D4  ... |D15|D16|

    // state    :     SOP   |EVE|ODD|EVE|ODD ... ODD|EVE|SOP
    // valid_o  : ______________----____---- ... ----____----________
    // data_o   :               |D12|   |D34     |D34|   |D56|

    enum    logic   [1:0]   {
        S_FIRST                         = 2'b00,    // first cycle
        S_SECOND                        = 2'b01,    // 2nd cycle
        S_ODD                           = 2'b10,    // odd cycle (except FIRST)
        S_EVEN                          = 2'b11     // even cycle (except 2nd)
    }                                   state,      state_n;

    logic                               valid,      valid_n;
    logic   [3:0]                       addr,       addr_n;
    logic   [63:0]                      data,       data_n;
    logic                               fail,       fail_n;

    always_comb begin
        state_n                         = state;

        valid_n                         = 1'b0;
        addr_n                          = addr;
        data_n                          = data;
        fail_n                          = fail;

        if (valid_i) begin
            case (state)
                S_FIRST: begin
                    // the first cycle
                    assert(sop_i);

                    valid_n                         = 1'b0;
                    addr_n                          = 'd0;
                    state_n                         = S_SECOND;
                    data_n[63:32]                   = {1'b1,
                                                       data_i[54:48],
                                                       data_i[39:32],
                                                       data_i[23:16],
                                                       data_i[7:0]};
                    fail_n                          = ((data_i[63:54]!=10'd0)&(data_i[63:54]!=10'h3FF))
                                                     |((data_i[47:39]!= 9'd0)&(data_i[47:39]!= 9'h1FF))
                                                     |((data_i[31:23]!= 9'd0)&(data_i[31:23]!= 9'h1FF))
                                                     |((data_i[15: 7]!= 9'd0)&(data_i[15: 7]!= 9'h1FF));
                end
                S_SECOND: begin
                    valid_n                         = 1'b1;
                    state_n                         = S_ODD;
                    data_n[31:0]                    = {data_i[55:48],
                                                       data_i[39:32],
                                                       data_i[23:16],
                                                       data_i[7:0]};
                    fail_n                          = fail
                                                     |((data_i[63:55]!= 9'd0)&(data_i[63:55]!= 9'h1FF))
                                                     |((data_i[47:39]!= 9'd0)&(data_i[47:39]!= 9'h1FF))
                                                     |((data_i[31:23]!= 9'd0)&(data_i[31:23]!= 9'h1FF))
                                                     |((data_i[15: 7]!= 9'd0)&(data_i[15: 7]!= 9'h1FF));
                end
                S_ODD: begin
                    valid_n                         = 1'b0;
                    addr_n                          = addr + 'd1;
                    state_n                         = S_EVEN;
                    data_n[63:32]                   = {data_i[55:48],
                                                       data_i[39:32],
                                                       data_i[23:16],
                                                       data_i[7:0]};
                    fail_n                          = fail
                                                     |((data_i[63:55]!= 9'd0)&(data_i[63:55]!= 9'h1FF))
                                                     |((data_i[47:39]!= 9'd0)&(data_i[47:39]!= 9'h1FF))
                                                     |((data_i[31:23]!= 9'd0)&(data_i[31:23]!= 9'h1FF))
                                                     |((data_i[15: 7]!= 9'd0)&(data_i[15: 7]!= 9'h1FF));
                end
                default: begin  // S_EVEN
                    valid_n                         = 1'b1;
                    state_n                         = (eop_i) ? S_FIRST : S_ODD;
                    data_n[31:0]                    = {data_i[55:48],
                                                       data_i[39:32],
                                                       data_i[23:16],
                                                       data_i[7:0]};
                    fail_n                          = fail
                                                     |((data_i[63:55]!= 9'd0)&(data_i[63:55]!= 9'h1FF))
                                                     |((data_i[47:39]!= 9'd0)&(data_i[47:39]!= 9'h1FF))
                                                     |((data_i[31:23]!= 9'd0)&(data_i[31:23]!= 9'h1FF))
                                                     |((data_i[15: 7]!= 9'd0)&(data_i[15: 7]!= 9'h1FF));
                end
            endcase
        end
    end

    always_ff @(posedge clk)
        if (!rst_n) begin
            state                           <= S_FIRST;

            valid                           <= 1'b0;
            // data doesn't require reset
            //addr                            <= 'd0;
            //data                            <= 'd0;
            fail                            <= 1'b0;
        end
        else begin
            state                           <= state_n;

            valid                           <= valid_n;
            addr                            <= addr_n;
            data                            <= data_n;
            fail                            <= fail_n;
        end


    assign  valid_o                         = valid;
    assign  addr_o                          = addr;
    assign  data_o                          = data;
    assign  fail_o                          = fail;

endmodule
