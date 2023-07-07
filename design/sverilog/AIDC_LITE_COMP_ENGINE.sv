module AIDC_LITE_COMP_ENGINE
(
    input   wire                        clk,
    input   wire                        rst_n,

    AHB2_MST_INTF.master                ahb_if,

    input   wire    [31:0]              src_addr_i,
    input   wire    [31:0]              dst_addr_i,
    input   wire    [31:7]              len_i,
    input   wire                        start_i,    // pulse
    output  logic                       done_o      // level
);

    enum    logic   [2:0]   {
        S_IDLE,
        S_BUSREQ,
        S_BUSY
    }                                   state,      state_n;

    logic                               hbusreq,    hbusreq_n;

    always_comb begin
        state_n                         = state;

        hbusreq_n                       = hbusreq;
        case (state)
            S_IDLE: begin
                if (start_i & (len_i!='d0)) begin
                    state_n                     = S_BUSREQ;

                    hbusreq_n                   = 1'b1;
                end
            end
            S_BUSREQ: begin
                if (ahb_if.hgrant) begin
                end
            end
        endcase
    end

    always_ff @(posedge clk)
        if (~rst_n) begin
            state                           <= S_IDLE;

            hbusreq                         <= 1'b0;
        end
        else begin
            state                           <= state_n;

            hbusreq                         <= hbusreq_n;
        end

endmodule
