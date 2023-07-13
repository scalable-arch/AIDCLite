module AHB2_BUS
(
    input   wire                        clk,
    input   wire                        rst_n,

    AHB2_MST_INTF.slave                 m0_if,
    AHB2_MST_INTF.slave                 m1_if,

    AHB2_SLV_INTF.master                s0_if
);

    assign  m0_if.hgrant                = 1'b1;

    assign  s0_if.hsel                  = 1'b1;
    assign  s0_if.haddr                 = m0_if.haddr;
    assign  s0_if.htrans                = m0_if.htrans;
    assign  s0_if.hwrite                = m0_if.hwrite;
    assign  s0_if.hsize                 = m0_if.hsize;
    assign  s0_if.hburst                = m0_if.hburst;
    assign  s0_if.hprot                 = m0_if.hprot;
    assign  s0_if.hwdata                = m0_if.hwdata;

    assign  s0_if.hreadyi               = s0_if.hreadyo;

    assign  m0_if.hrdata                = s0_if.hrdata;
    assign  m0_if.hresp                 = s0_if.hresp;
    assign  m0_if.hready                = s0_if.hreadyo;

endmodule

/*
module AHB2_ARBITER
#(
    parameter   MASTER_CNT              = 2,
    parameter   MASTER_ID_WIDTH         = $clog2(MASTER_CNT)
)
(
    input   wire                        clk,
    input   wire                        rst_n,

    input   wire                        hready_i,

    input   wire    [MASTER_CNT-1:0]    hbusreq_vec_i,
    output  logic   [MASTER_CNT-1:0]    hgrant_vec_o,

    output  logic   [MASTER_ID_WIDTH-1:0] hmaster_o
);

    logic   [MASTER_ID_WIDTH-1:0]       hmaster,    hmaster_n;
    logic   [MASTER_CNT-1:0]            hgrant_vec, hgrant_vec_n;

    always_comb begin
        hgrant_vec_n                    = 'd0;
        hmaster_n                       = hmaster;
        if (hready_i) begin
            for (int i=0; i<MASTER_CNT; i=i+1) begin
                if (hbusreq_vec_i[i]) begin
                    hgrant_vec_n[i]                 = 1'b1;
                    hmaster_n                       = i;
                    break;
                end
            end
        end
    end

    always @(posedge clk)
        if (~rst_n) begin
            hmaster                         <= 'd0;
            hgrant_vec                      <= 'd0;
        end
        else begin
            hmaster                         <= hmaster_n;
            hgrant_vec                      <= hgrant_vec_n;
        end
endmodule

module AHB2_MUX
#(
    parameter   MASTER_CNT              = 2,
    parameter   MASTER_ID_WIDTH         = $clog2(MASTER_CNT)
)
(
    input   wire                        clk,
    input   wire                        rst_n,

    input   wire    [MASTER_ID_WIDTH-1:0] hmaster_i,
    input   wire                        hready_i,

    AHB2_MST_INTF.slave                 m0_if,
    AHB2_MST_INTF.slave                 m1_if,

    AHB2_MST_INTF.master                s_if
);
    logic                               hmaster_data;

    always @(posedge clk)
        if (!rst_n) begin
            hmaster_data                    <= 'd0;
        end
        else if (hready_i) begin
            hmaster_data                    <= hmaster_i;
        end

    always_comb begin
        if (hmaster_i==1'b0) begin
            s_if.haddr                      = m0_if.haddr;
            s_if.htrans                     = m0_if.htrans;
            s_if.hwrite                     = m0_if.hwrite;
            s_if.hsize                      = m0_if.hsize;
            s_if.hburst                     = m0_if.hburst;
            s_if.hprot                      = m0_if.hprot;
        end
        else begin
            s_if.haddr                      = m1_if.haddr;
            s_if.htrans                     = m1_if.htrans;
            s_if.hwrite                     = m1_if.hwrite;
            s_if.hsize                      = m1_if.hsize;
            s_if.hburst                     = m1_if.hburst;
            s_if.hprot                      = m1_if.hprot;
        end
    end
endmodule
*/
