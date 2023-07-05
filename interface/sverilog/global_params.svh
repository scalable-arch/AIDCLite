// the macros are to be updated per system
// the parameters are derived from the macros and supported
// to be don't changed

// Based on AMBA AXI4 specification
`define PCIE_FLITS_PER_CYCLE 8

struct {
    logic   [9:0]               length;
    logic   [1:0]               at;
    logic   [1:0]               attr;
    logic                       ep;
    logic                       td;
    logic                       th;
    logic                       rsvd;
    logic                       attr2;
    logic                       t8;
    logic   [2:0]               tc;
    logic                       t9;
    logic   [4:0]               type_;
    logic   [2:0]               fmt;
} PCIE_REQ_FLIT0

`define CPI_EPOCH_ID_WIDTH	4


struct {
    logic   [24:0]              rsvd;
    logic   [1:0]               port_id;
    logic                       epoch_id
    logic                       epoch_valid;
    logic   [1:0]               flit_mode;
    logic   [3:0]               cacheID;    
    logic   [51:6]              address;
    logic                       address_parity;
    logic   [11:0]              uqid;
    logic   [2:0]               opcode;
} CPI_REQ_HEADER_UP_A2F;

struct {
    logic   [24:0]              rsvd2;
    logic   [1:0]               flit_mode;
    logic   [3:0]               cacheID;    
    logic   [51:6]              address;
    logic                       address_parity;
    logic   [1:0]               rsvd1;
    logic                       nt;
    logic   [11:0]              uqid;
    logic   [4:0]               opcode;
} CPI_REQ_HEADER_UP_F2A;

union {
  CPI_REQ_HEADER_UP_A2F up_a2f;
  CPI_REQ_HEADER_UP_F2A up_f2a;
} CPI_REQ_HEADER;
