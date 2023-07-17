typedef     logic   [31:0]          DW;
typedef     logic   [127:0]         TLP_HEADER;

typedef struct packed {
    logic   [2:0]                   fmt;
    logic   [4:0]                   type_;
    logic                           rsvd_t9;
    logic   [2:0]                   tc;
    logic                           rsvd_t8;
    logic                           attr2;
    logic                           ln; // Lightweigiht Notification
    logic                           th; // TLP Hints
    logic                           td; // TLP Digest
    logic                           ep; // Error Poisoned
    logic   [1:0]                   attr10;
    logic   [1:0]                   at;
    logic   [9:0]                   length;
} PCIE_TLP_HEADER_DW0;

typedef struct packed {
    logic   [15:0]                  requester_id;
    logic   [7:0]                   tag;
    logic   [3:0]                   last_be;
    logic   [3:0]                   first_be;
} PCIE_TLP_HEADER_REQ_DW1;

typedef struct packed {
    logic   [15:0]                  completer_id;
    logic   [2:0]                   status;
    logic                           b;
    logic   [11:0]                  byte_count;
} PCIE_TLP_HEADER_CPL_DW1;

typedef struct packed {
    logic   [15:0]                  requester_id;
    logic   [7:0]                   tag;
    logic                           rsvd;
    logic   [6:0]                   lower_address;
} PCIE_TLP_HEADER_CPL_DW2;

typedef struct packed {
    logic   [15:0]                  requester_id;
    logic   [7:0]                   tag;
    logic   [7:0]                   message_code;
} PCIE_TLP_HEADER_MSG_DW1;

parameter   PCIE_TLP_FMT_3DW_ND     3'b000
parameter   PCIE_TLP_FMT_4DW_ND     3'b001
parameter   PCIE_TLP_FMT_3DW_D      3'b010
parameter   PCIE_TLP_FMT_4DW_D      3'b011
parameter   PCIE_TLP_FMT_TLP_PREFIX 3'b100

parameter   PCIE_TLP_TYPE_MRD       5'b00000
parameter   PCIE_TLP_TYPE_MRDLK     5'b00001
parameter   PCIE_TLP_TYPE_MWR       5'b00000
parameter   PCIE_TLP_TYPE_IORD      5'b00010
parameter   PCIE_TLP_TYPE_IOWR      5'b00010
parameter   PCIE_TLP_TYPE_CFGRD0    5'b00100
parameter   PCIE_TLP_TYPE_CFGWR0    5'b00100
parameter   PCIE_TLP_TYPE_CFGRD1    5'b00101
parameter   PCIE_TLP_TYPE_CFGWR1    5'b00101
parameter   PCIE_TLP_TYPE_TCFGRD    5'b11011
parameter   PCIE_TLP_TYPE_TCFGWR    5'b11011
parameter   PCIE_TLP_TYPE_MSG       5'b10000
parameter   PCIE_TLP_TYPE_MSGD      5'b10000
parameter   PCIE_TLP_TYPE_CPL       5'b01010
parameter   PCIE_TLP_TYPE_CPLD      5'b01010
parameter   PCIE_TLP_TYPE_CPLLK     5'b01010
parameter   PCIE_TLP_TYPE_CPLDLK    5'b01010
parameter   PCIE_TLP_TYPE_FETCHADD  5'b01100
parameter   PCIE_TLP_TYPE_SWAP      5'b01101
parameter   PCIE_TLP_TYPE_CAS       5'b01110
parameter   PCIE_TLP_TYPE_LPRFX     5'b00000
parameter   PCIE_TLP_TYPE_EPRFX     5'b10000

function    TLP_HEADER  gen_tlp_header_mrd (
    input   wire    [63:0]          addr,
    //input   wire    [2:0]           tc,
    //input   wire                    td,
    //input   wire                    ep,
    //input   wire    [1:0]           attr10,
    input   wire    [9:0]           length,
    input   wire    [15:0]          requester_id,
    input   wire    [7:0]           tag
    //input   wire    [3:0]           last_be,
    //input   wire    [3:0]           first_be,
);
    PCIE_TLP_HEADER_DW0             dw0;
    PCIE_TLP_HEADER_REQ_DW1         dw1;

    // initialize all fields to 0s
    dw0                             = {$bits(DW){1'b0}};
    dw0.fmt                         = PCIE_TLP_FMT_4DW_ND;
    dw0.type_                       = PCIE_TLP_TYPE_MRD;
    //dw0.tc                          = tc;
    //dw0.td                          = td;
    //dw0.ep                          = ep;
    //dw0.attr10                      = attr10;
    dw0.length                      = length;

    // initialize all fields to 0s
    dw1                             = {$bits(DW){1'b0}};
    dw1.requester_id                = requester_id;
    dw1.tag                         = tag;
    dw1.last_be                     = last_be;
    dw1.first_be                    = first_be;

    gen_tlp_header_mrd              = {dw0, dw1, addr[63:2], 2'b00};
endfunction

function    TLP_HEADER  gen_tlp_header_mwr(
    input   wire    [63:0]          addr,
    //input   wire    [2:0]           tc,
    //input   wire                    ep,
    //input   wire    [1:0]           attr10,
    input   wire    [9:0]           length,
    input   wire    [15:0]          requester_id,
    input   wire    [7:0]           tag
    //input   wire    [3:0]           last_be,
    //input   wire    [3:0]           first_be,
);
    PCIE_TLP_HEADER_DW0             dw0;
    PCIE_TLP_HEADER_REQ_DW1         dw1;

    // initialize all fields to 0s
    dw0                             = {$bits(DW){1'b0}};
    dw0.fmt                         = PCIE_TLP_FMT_4DW_D;
    dw0.type_                       = PCIE_TLP_TYPE_MWR;
    //dw0.tc                          = tc;
    //dw0.ep                          = ep;
    //dw0.attr10                      = attr10;
    dw0.length                      = length;

    // initialize all fields to 0s
    dw1                             = {$bits(DW){1'b0}};
    dw1.requester_id                = requester_id;
    dw1.tag                         = tag;
    dw1.last_be                     = last_be;
    dw1.first_be                    = first_be;

    gen_tlp_header_mwr              = {dw0, dw1, addr[63:2], 2'b00};

endfunction

function    TLP_HEADER  gen_tlp_header_cpl (
    input   wire    [63:0]          addr,
    //input   wire    [2:0]           tc,
    //input   wire                    td,
    //input   wire                    ep,
    //input   wire    [1:0]           attr10,
    input   wire    [9:0]           length,
    input   wire    [15:0]          completer_id,
    input   wire    [2:0]           status,
    input   wire    [11:0]          byte_count,
    input   wire    [15:0]          requester_id,
    input   wire    [7:0]           tag,
    input   wire    [6:0]           lower_address
    //input   wire    [3:0]           last_be,
    //input   wire    [3:0]           first_be,
);
    PCIE_TLP_HEADER_DW0             dw0;
    PCIE_TLP_HEADER_CPL_DW1         dw1;
    PCIE_TLP_HEADER_CPL_DW2         dw2;

    // initialize all fields to 0s
    dw0                             = {$bits(DW){1'b0}};
    dw0.fmt                         = PCIE_TLP_FMT_3DW_ND;
    dw0.type_                       = PCIE_TLP_TYPE_CPL;
    //dw0.tc                          = tc;
    //dw0.td                          = td;
    //dw0.ep                          = ep;
    //dw0.attr10                      = attr10;
    dw0.length                      = length;

    // initialize all fields to 0s
    dw1                             = {$bits(DW){1'b0}};
    dw1.completer_id                = completer_id;
    dw1.status                      = status;
    dw1.byte_count                  = byte_count;

    // initialize all fields to 0s
    dw2                             = {$bits(DW){1'b0}};
    dw2.requester_id                = requester_id;
    dw2.tag                         = tag;
    dw2.lower_address               = lower_address;

    gen_tlp_header_cpl              = {dw0, dw1, dw2, 32'd0};
endfunction

function    TLP_HEADER  gen_tlp_header_cpld (
    input   wire    [63:0]          addr,
    //input   wire    [2:0]           tc,
    //input   wire                    td,
    //input   wire                    ep,
    //input   wire    [1:0]           attr10,
    input   wire    [9:0]           length,
    input   wire    [15:0]          completer_id,
    input   wire    [2:0]           status,
    input   wire    [11:0]          byte_count,
    input   wire    [15:0]          requester_id,
    input   wire    [7:0]           tag,
    input   wire    [6:0]           lower_address
    //input   wire    [3:0]           last_be,
    //input   wire    [3:0]           first_be,
);
    PCIE_TLP_HEADER_DW0             dw0;
    PCIE_TLP_HEADER_CPL_DW1         dw1;
    PCIE_TLP_HEADER_CPL_DW2         dw2;

    // initialize all fields to 0s
    dw0                             = {$bits(DW){1'b0}};
    dw0.fmt                         = PCIE_TLP_FMT_3DW_D;
    dw0.type_                       = PCIE_TLP_TYPE_CPL;
    //dw0.tc                          = tc;
    //dw0.td                          = td;
    //dw0.ep                          = ep;
    //dw0.attr10                      = attr10;
    dw0.length                      = length;

    // initialize all fields to 0s
    dw1                             = {$bits(DW){1'b0}};
    dw1.completer_id                = completer_id;
    dw1.status                      = status;
    dw1.byte_count                  = byte_count;

    // initialize all fields to 0s
    dw2                             = {$bits(DW){1'b0}};
    dw2.requester_id                = requester_id;
    dw2.tag                         = tag;
    dw2.lower_address               = lower_address;

    gen_tlp_header_cpld             = {dw0, dw1, dw2, 32'd0};
endfunction

