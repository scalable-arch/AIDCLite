// Generated by PeakRDL-regblock - A free and open-source SystemVerilog generator
//  https://github.com/SystemRDL/PeakRDL-regblock

module AIDC_LITE_COMP_CFG (
        input wire clk,
        input wire rst_n,

        input wire s_apb_psel,
        input wire s_apb_penable,
        input wire s_apb_pwrite,
        input wire [5:0] s_apb_paddr,
        input wire [31:0] s_apb_pwdata,
        output logic s_apb_pready,
        output logic [31:0] s_apb_prdata,
        output logic s_apb_pslverr,

        input AIDC_LITE_COMP_CFG_pkg::AIDC_LITE_COMP_CFG__in_t hwif_in,
        output AIDC_LITE_COMP_CFG_pkg::AIDC_LITE_COMP_CFG__out_t hwif_out
    );

    //--------------------------------------------------------------------------
    // CPU Bus interface logic
    //--------------------------------------------------------------------------
    logic cpuif_req;
    logic cpuif_req_is_wr;
    logic [5:0] cpuif_addr;
    logic [31:0] cpuif_wr_data;
    logic [31:0] cpuif_wr_biten;
    logic cpuif_req_stall_wr;
    logic cpuif_req_stall_rd;

    logic cpuif_rd_ack;
    logic cpuif_rd_err;
    logic [31:0] cpuif_rd_data;

    logic cpuif_wr_ack;
    logic cpuif_wr_err;

    // Request
    logic is_active;
    always_ff @(posedge clk) begin
        if(~rst_n) begin
            is_active <= '0;
            cpuif_req <= '0;
            cpuif_req_is_wr <= '0;
            cpuif_addr <= '0;
            cpuif_wr_data <= '0;
        end else begin
            if(~is_active) begin
                if(s_apb_psel) begin
                    is_active <= '1;
                    cpuif_req <= '1;
                    cpuif_req_is_wr <= s_apb_pwrite;
                    cpuif_addr <= {s_apb_paddr[5:2], 2'b0};
                    cpuif_wr_data <= s_apb_pwdata;
                end
            end else begin
                cpuif_req <= '0;
                if(cpuif_rd_ack || cpuif_wr_ack) begin
                    is_active <= '0;
                end
            end
        end
    end
    assign cpuif_wr_biten = '1;

    // Response
    assign s_apb_pready = cpuif_rd_ack | cpuif_wr_ack;
    assign s_apb_prdata = cpuif_rd_data;
    assign s_apb_pslverr = cpuif_rd_err | cpuif_wr_err;

    logic cpuif_req_masked;

    // Read & write latencies are balanced. Stalls not required
    assign cpuif_req_stall_rd = '0;
    assign cpuif_req_stall_wr = '0;
    assign cpuif_req_masked = cpuif_req
                            & !(!cpuif_req_is_wr & cpuif_req_stall_rd)
                            & !(cpuif_req_is_wr & cpuif_req_stall_wr);

    //--------------------------------------------------------------------------
    // Address Decode
    //--------------------------------------------------------------------------
    typedef struct {
        logic VERSION;
        logic GIT;
        logic SRC_ADDR;
        logic DST_ADDR;
        logic LEN;
        logic CMD;
        logic STATUS;
    } decoded_reg_strb_t;
    decoded_reg_strb_t decoded_reg_strb;
    logic decoded_req;
    logic decoded_req_is_wr;
    logic [31:0] decoded_wr_data;
    logic [31:0] decoded_wr_biten;

    always_comb begin
        decoded_reg_strb.VERSION = cpuif_req_masked & (cpuif_addr == 6'h0);
        decoded_reg_strb.GIT = cpuif_req_masked & (cpuif_addr == 6'h4);
        decoded_reg_strb.SRC_ADDR = cpuif_req_masked & (cpuif_addr == 6'h10);
        decoded_reg_strb.DST_ADDR = cpuif_req_masked & (cpuif_addr == 6'h14);
        decoded_reg_strb.LEN = cpuif_req_masked & (cpuif_addr == 6'h18);
        decoded_reg_strb.CMD = cpuif_req_masked & (cpuif_addr == 6'h1c);
        decoded_reg_strb.STATUS = cpuif_req_masked & (cpuif_addr == 6'h20);
    end

    // Pass down signals to next stage
    assign decoded_req = cpuif_req_masked;
    assign decoded_req_is_wr = cpuif_req_is_wr;
    assign decoded_wr_data = cpuif_wr_data;
    assign decoded_wr_biten = cpuif_wr_biten;

    //--------------------------------------------------------------------------
    // Field logic
    //--------------------------------------------------------------------------
    typedef struct {
        struct {
            struct {
                logic [31:0] next;
                logic load_next;
            } START_ADDR;
        } SRC_ADDR;
        struct {
            struct {
                logic [31:0] next;
                logic load_next;
            } START_ADDR;
        } DST_ADDR;
        struct {
            struct {
                logic [24:0] next;
                logic load_next;
            } BYTE_SIZE;
        } LEN;
        struct {
            struct {
                logic next;
                logic load_next;
            } START;
        } CMD;
    } field_combo_t;
    field_combo_t field_combo;

    typedef struct {
        struct {
            struct {
                logic [31:0] value;
            } START_ADDR;
        } SRC_ADDR;
        struct {
            struct {
                logic [31:0] value;
            } START_ADDR;
        } DST_ADDR;
        struct {
            struct {
                logic [24:0] value;
            } BYTE_SIZE;
        } LEN;
        struct {
            struct {
                logic value;
            } START;
        } CMD;
    } field_storage_t;
    field_storage_t field_storage;

    // Field: AIDC_LITE_COMP_CFG.SRC_ADDR.START_ADDR
    always_comb begin
        automatic logic [31:0] next_c = field_storage.SRC_ADDR.START_ADDR.value;
        automatic logic load_next_c = '0;
        if(decoded_reg_strb.SRC_ADDR && decoded_req_is_wr) begin // SW write
            next_c = (field_storage.SRC_ADDR.START_ADDR.value & ~decoded_wr_biten[31:0]) | (decoded_wr_data[31:0] & decoded_wr_biten[31:0]);
            load_next_c = '1;
        end
        field_combo.SRC_ADDR.START_ADDR.next = next_c;
        field_combo.SRC_ADDR.START_ADDR.load_next = load_next_c;
    end
    always_ff @(posedge clk) begin
        if(~rst_n) begin
            field_storage.SRC_ADDR.START_ADDR.value <= 32'h0;
        end else if(field_combo.SRC_ADDR.START_ADDR.load_next) begin
            field_storage.SRC_ADDR.START_ADDR.value <= field_combo.SRC_ADDR.START_ADDR.next;
        end
    end
    assign hwif_out.SRC_ADDR.START_ADDR.value = field_storage.SRC_ADDR.START_ADDR.value;
    // Field: AIDC_LITE_COMP_CFG.DST_ADDR.START_ADDR
    always_comb begin
        automatic logic [31:0] next_c = field_storage.DST_ADDR.START_ADDR.value;
        automatic logic load_next_c = '0;
        if(decoded_reg_strb.DST_ADDR && decoded_req_is_wr) begin // SW write
            next_c = (field_storage.DST_ADDR.START_ADDR.value & ~decoded_wr_biten[31:0]) | (decoded_wr_data[31:0] & decoded_wr_biten[31:0]);
            load_next_c = '1;
        end
        field_combo.DST_ADDR.START_ADDR.next = next_c;
        field_combo.DST_ADDR.START_ADDR.load_next = load_next_c;
    end
    always_ff @(posedge clk) begin
        if(~rst_n) begin
            field_storage.DST_ADDR.START_ADDR.value <= 32'h0;
        end else if(field_combo.DST_ADDR.START_ADDR.load_next) begin
            field_storage.DST_ADDR.START_ADDR.value <= field_combo.DST_ADDR.START_ADDR.next;
        end
    end
    assign hwif_out.DST_ADDR.START_ADDR.value = field_storage.DST_ADDR.START_ADDR.value;
    // Field: AIDC_LITE_COMP_CFG.LEN.BYTE_SIZE
    always_comb begin
        automatic logic [24:0] next_c = field_storage.LEN.BYTE_SIZE.value;
        automatic logic load_next_c = '0;
        if(decoded_reg_strb.LEN && decoded_req_is_wr) begin // SW write
            next_c = (field_storage.LEN.BYTE_SIZE.value & ~decoded_wr_biten[31:7]) | (decoded_wr_data[31:7] & decoded_wr_biten[31:7]);
            load_next_c = '1;
        end
        field_combo.LEN.BYTE_SIZE.next = next_c;
        field_combo.LEN.BYTE_SIZE.load_next = load_next_c;
    end
    always_ff @(posedge clk) begin
        if(~rst_n) begin
            field_storage.LEN.BYTE_SIZE.value <= 25'h0;
        end else if(field_combo.LEN.BYTE_SIZE.load_next) begin
            field_storage.LEN.BYTE_SIZE.value <= field_combo.LEN.BYTE_SIZE.next;
        end
    end
    assign hwif_out.LEN.BYTE_SIZE.value = field_storage.LEN.BYTE_SIZE.value;
    // Field: AIDC_LITE_COMP_CFG.CMD.START
    always_comb begin
        automatic logic [0:0] next_c = field_storage.CMD.START.value;
        automatic logic load_next_c = '0;
        if(decoded_reg_strb.CMD && decoded_req_is_wr) begin // SW write
            next_c = (field_storage.CMD.START.value & ~decoded_wr_biten[0:0]) | (decoded_wr_data[0:0] & decoded_wr_biten[0:0]);
            load_next_c = '1;
        end else begin // singlepulse clears back to 0
            next_c = '0;
            load_next_c = '1;
        end
        field_combo.CMD.START.next = next_c;
        field_combo.CMD.START.load_next = load_next_c;
    end
    always_ff @(posedge clk) begin
        if(~rst_n) begin
            field_storage.CMD.START.value <= 1'h0;
        end else if(field_combo.CMD.START.load_next) begin
            field_storage.CMD.START.value <= field_combo.CMD.START.next;
        end
    end
    assign hwif_out.CMD.START.value = field_storage.CMD.START.value;

    //--------------------------------------------------------------------------
    // Write response
    //--------------------------------------------------------------------------
    assign cpuif_wr_ack = decoded_req & decoded_req_is_wr;
    // Writes are always granted with no error response
    assign cpuif_wr_err = '0;

    //--------------------------------------------------------------------------
    // Readback
    //--------------------------------------------------------------------------

    logic readback_err;
    logic readback_done;
    logic [31:0] readback_data;
    
    // Assign readback values to a flattened array
    logic [31:0] readback_array[7];
    assign readback_array[0][15:0] = (decoded_reg_strb.VERSION && !decoded_req_is_wr) ? hwif_in.VERSION.MICRO.next : '0;
    assign readback_array[0][23:16] = (decoded_reg_strb.VERSION && !decoded_req_is_wr) ? hwif_in.VERSION.MINOR.next : '0;
    assign readback_array[0][31:24] = (decoded_reg_strb.VERSION && !decoded_req_is_wr) ? hwif_in.VERSION.MAJOR.next : '0;
    assign readback_array[1][31:0] = (decoded_reg_strb.GIT && !decoded_req_is_wr) ? hwif_in.GIT.HASH.next : '0;
    assign readback_array[2][31:0] = (decoded_reg_strb.SRC_ADDR && !decoded_req_is_wr) ? field_storage.SRC_ADDR.START_ADDR.value : '0;
    assign readback_array[3][31:0] = (decoded_reg_strb.DST_ADDR && !decoded_req_is_wr) ? field_storage.DST_ADDR.START_ADDR.value : '0;
    assign readback_array[4][6:0] = '0;
    assign readback_array[4][31:7] = (decoded_reg_strb.LEN && !decoded_req_is_wr) ? field_storage.LEN.BYTE_SIZE.value : '0;
    assign readback_array[5][0:0] = (decoded_reg_strb.CMD && !decoded_req_is_wr) ? field_storage.CMD.START.value : '0;
    assign readback_array[5][31:1] = '0;
    assign readback_array[6][0:0] = (decoded_reg_strb.STATUS && !decoded_req_is_wr) ? hwif_in.STATUS.DONE.next : '0;
    assign readback_array[6][31:1] = '0;

    // Reduce the array
    always_comb begin
        automatic logic [31:0] readback_data_var;
        readback_done = decoded_req & ~decoded_req_is_wr;
        readback_err = '0;
        readback_data_var = '0;
        for(int i=0; i<7; i++) readback_data_var |= readback_array[i];
        readback_data = readback_data_var;
    end

    assign cpuif_rd_ack = readback_done;
    assign cpuif_rd_data = readback_data;
    assign cpuif_rd_err = readback_err;
endmodule