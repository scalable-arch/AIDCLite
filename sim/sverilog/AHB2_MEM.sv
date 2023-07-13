module AHB2_MEM
#(
    parameter   ADDR_WIDTH              = 18
 )
(
    input   wire                        clk,
    input   wire                        rst_n,

    AHB2_SLV_INTF.slave                 ahb_if
);

    localparam  WORD_ADDR_WIDTH         = ADDR_WIDTH-2;
    localparam  WORD_CNT                = 1<<(WORD_ADDR_WIDTH);

    // memory
    logic   [31:0]                      mem[WORD_CNT-1:0];

    logic   [31:0]                      hrdata;
    logic                               wren_reg;
    logic   [ADDR_WIDTH+1:2]            addr_reg;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            hrdata                          <= 'hx;
            wren_reg                        <= 1'b0;
            addr_reg                        <= 'hx;
        end
        else begin
            // read
            if (ahb_if.hsel & ahb_if.htrans[1] & ahb_if.hreadyi & !ahb_if.hwrite) begin
                hrdata                              <= mem[ahb_if.haddr[ADDR_WIDTH+1:2]];
            end
            else begin
                hrdata                              <= 'hX;
            end

            // pre-write
            if (ahb_if.hsel & ahb_if.htrans[1] & ahb_if.hreadyi & ahb_if.hwrite) begin
                wren_reg                            <= 1'b1;
                addr_reg                            <= ahb_if.haddr[ADDR_WIDTH+1:2];
            end
            else begin
                wren_reg                            <= 1'b0;
                addr_reg                            <= 'hX;
            end
        end
    end

    // write
    always @(posedge clk) begin
        if (wren_reg) begin
            mem[addr_reg[ADDR_WIDTH+1:2]]       <= ahb_if.hwdata;
        end
    end

    //----------------------------------------------------------
    // Output assignments
    //----------------------------------------------------------
    assign  ahb_if.hrdata               = hrdata;
    assign  ahb_if.hresp                = HRESP_OKAY;
    assign  ahb_if.hreadyo              = 1'b1;

    // synopsys translate_off
    task init_mem();
        for (int i=0; i<WORD_CNT; i++) begin
            mem[i]                      = 'd0;
        end
    endtask

    task init_mem_with_addr();
        for (int i=0; i<WORD_CNT; i++) begin
            mem[i]                      = i;
        end
    endtask

    task read_word (
        input   wire    [31:0]          addr,
        output  logic   [31:0]          rdata
    );
        rdata                       = mem[addr[ADDR_WIDTH-1:2]];
    endtask

    
    task read_word (
        input   wire    [31:0]          addr,
        input   wire    [31:0]          wdata
    );
        mem[addr[ADDR_WIDTH-1:2]]   = wdata;
    endtask
    // synopsys translate_on

endmodule
