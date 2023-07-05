`ifndef __AMBA4_PKG__
`define __AMBA4_PKG__

package AMBA4_PKG;
    // using SystemVerilog enum will raise warnings on assignments

    // AXLEN: 4-bit in AXI3 / 8-bit in AXI4
    //typedef         logic   [3:0]   LEN_T;
    typedef         logic   [7:0]   LEN_T;
    // AXSIZE: 3-bit in AXI3 and AXI4
    typedef         logic   [2:0]   SIZE_T;
    // cannot override
    localparam                      SIZE_1B     = 3'b000,
                                    SIZE_2B     = 3'b001,
                                    SIZE_4B     = 3'b010,
                                    SIZE_8B     = 3'b011,
                                    SIZE_16B    = 3'b100,
                                    SIZE_32B    = 3'b101,
                                    SIZE_64B    = 3'b110,
                                    SIZE_128B   = 3'b111;

    // AXBURST: 2-bit in AXI and AXI4
    typedef         logic   [1:0]   BURST_T;
    // cannot override
    localparam                      BURST_FIXED = 2'b00,
                                    BURST_INCR  = 2'b01,
                                    BURST_WRAP  = 2'b10,
                                    BURST_RSVD  = 2'b11;

    // AXLOCK: 2-bit in AXI3 / 1-bit in AXI4
    //typedef enum    logic   [1:0]  {LOCK_NORMAL     = 2'b00,
    //                                LOCK_EXCLUSIVE  = 2'b01,
    //                                LOCK_LOCKED     = 2'b10,
    //                                LOCK_RSVD       = 2'b11}
    //                                LOCK_T;
    typedef         logic           LOCK_T;
    localparam                      LOCK_NORMAL     = 1'b0,
                                    LOCK_RSVD       = 1'b1;

    typedef struct packed {
        logic                       BUFFERABLE;
        logic                       CACHEABLE;
        logic                       READ_ALLOCATE;
        logic                       WRITE_ALLOCATE;
    } CACHE_T;

    typedef struct packed {
        logic                       PRIV;
        logic                       NON_SECURE;
        logic                       INSTRUCTION;
    } PROT_T;

    // AXI4 only
    typedef         logic   [3:0]   QOS_T;
    typedef         logic   [3:0]   REGION_T;

    typedef         logic   [1:0]   RESP_T;
    localparam                      RESP_OKAY   = 2'b00,
                                    RESP_EXOKAY = 2'b01,
                                    RESP_SLVERR = 2'b10,
                                    RESP_DECERR = 2'b11;

endpackage

`endif /* __AMBA4_PKG__ */
