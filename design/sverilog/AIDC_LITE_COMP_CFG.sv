module AIDC_LITE_COMP_CFG
(
    input   wire                        clk,
    input   wire                        rst_n,

    APB_INTF.slave                      apb_if,

    output  logic   [31:0]              src_addr_o,
    output  logic   [31:0]              dst_addr_o,
    output  logic   [31:7]              len_o,
    output  logic                       start_o,    // pulse
    input   wire                        done_i      // level
);

    logic   [31:0]                      src_addr;
    logic   [31:0]                      dst_addr;
    logic   [31:7]                      len;
    logic                               start;
    logic                               done;

    always_ff @(posedge clk)
        if (~rst_n) begin
            src_addr                        <= 'd0;
            dst_addr                        <= 'd0;
            len                             <= 'd0;
            start                           <= 1'b0;
        end
        else begin
            if (apb_if.psel & apb_if.penable & apb_if.pwrite) begin
                case (apb_if.paddr[9:2])
                    8'd0:
                        src_addr                        <= apb_if.pwdata;
                    8'd1:
                        dst_addr                        <= apb_if.pwdata;
                    8'd2:
                        len                             <= apb_if.pwdata[31:7];
                endcase
            end
            start                           <= apb_if.psel & apb_if.penable
                                              &apb_if.pwrite
                                              &(apb_if.paddr[9:2]==8'd3)
                                              &apb_if.pwdata[0];
        end

    logic   [31:0]                      prdata;

    always_ff @(posedge clk)
        if (~rst_n) begin
            prdata                          <= 'd0;
        end
        else if (apb_if.psel & ~apb_if.penable & ~apb_if.pwrite) begin
            case (apb_if.paddr[9:2])
                8'd0:
                    prdata                          <= src_addr;
                8'd1:
                    prdata                          <= dst_addr;
                8'd2:
                    prdata                          <= {len, 7'd0};
                8'd4:
                    prdata                          <= {31'd0, done_i};
            endcase
        end

    // output assignment
    assign  apb_if.prdata               = prdata;
    assign  apb_if.pready               = 1'b1;
    assign  apb_if.pslverr              = 1'b0;

    assign  src_addr_o                  = src_addr;
    assign  dst_addr_o                  = dst_addr;
    assign  len_o                       = len;
    assign  start_o                     = start;

endmodule
