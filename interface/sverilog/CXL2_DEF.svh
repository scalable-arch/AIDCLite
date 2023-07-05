typedef struct packed {
    // upper bits        
    logic                               valid;
    logic   [4:0]                       opcode;
    logic   [51:6]                      address;
    logic   [11:0]                      cqid;
    logic                               nt;
    logic   [13:0]                      rsvd;
} CXL_CACHE_D2H_REQ;
