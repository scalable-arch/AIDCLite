module AIDC_LITE_COMP_ZRLE
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
    output  logic                       fail_o
);

    //----------------------------------------------------------
    // combinational logic part
    //----------------------------------------------------------
    logic   [3:0]                       zero_vec;
    logic   [65:0]                      cur_comp_data;
    logic   [6:0]                       cur_comp_size;  // bit size

    assign  zero_vec[3]                 = (data_i[63:48]=='d0);
    assign  zero_vec[2]                 = (data_i[47:32]=='d0);
    assign  zero_vec[1]                 = (data_i[31:16]=='d0);
    assign  zero_vec[0]                 = (data_i[15: 0]=='d0);

    always_comb begin
        case (zero_vec)
            4'b1111: begin  // Z-Z-Z-Z
                cur_comp_data               = {6'b000000, 60'd0};
                cur_comp_size               = 'd6;
            end
            4'b1110: begin  // Z-Z-Z-N
                cur_comp_data               = {6'b000001, data_i[15:0], 44'd0};
                cur_comp_size               = 'd22;
            end
            4'b1101: begin  // Z-Z-N-Z
                cur_comp_data               = {5'b00001, data_i[31:16], 45'd0};
                cur_comp_size               = 'd21;
            end
            4'b1011: begin  // Z-N-Z-Z
                cur_comp_data               = {5'b00010, data_i[47:32], 45'd0};
                cur_comp_size               = 'd21;
            end
            4'b0111: begin  // N-Z-Z-Z
                cur_comp_data               = {5'b00011, data_i[63:48], 45'd0};
                cur_comp_size               = 'd21;
            end
            4'b1100: begin  // Z-Z-N-N
                cur_comp_data               = {4'b0010, data_i[31:16], data_i[15:0], 30'd0};
                cur_comp_size               = 'd36;
            end
            4'b1010: begin  // Z-N-Z-N
                cur_comp_data               = {4'b0011, data_i[47:32], data_i[15:0], 30'd0};
                cur_comp_size               = 'd36;
            end
            4'b0110: begin  // N-Z-Z-N
                cur_comp_data               = {4'b0100, data_i[63:48], data_i[15:0], 30'd0};
                cur_comp_size               = 'd36;
            end
            4'b1001: begin  // Z-N-N-Z
                cur_comp_data               = {4'b0101, data_i[47:32], data_i[31:16], 30'd0};
                cur_comp_size               = 'd36;
            end
            4'b0101: begin  // N-Z-N-Z
                cur_comp_data               = {4'b0110, data_i[63:48], data_i[31:16], 30'd0};
                cur_comp_size               = 'd36;
            end
            4'b0011: begin  // N-N-Z-Z
                cur_comp_data               = {4'b0111, data_i[63:48], data_i[47:32], 30'd0};
                cur_comp_size               = 'd36;
            end
            4'b1000: begin  // Z-N-N-N
                cur_comp_data               = {4'b1000, data_i[47:32], data_i[31:16], data_i[15:0], 14'd0};
                cur_comp_size               = 'd52;
            end
            4'b0100: begin  // N-Z-N-N
                cur_comp_data               = {4'b1001, data_i[63:48], data_i[31:16], data_i[15:0], 14'd0};
                cur_comp_size               = 'd52;
            end
            4'b0010: begin  // N-N-Z-N
                cur_comp_data               = {4'b1010, data_i[63:48], data_i[47:32], data_i[15:0], 14'd0};
                cur_comp_size               = 'd52;
            end
            4'b0001: begin  // N-N-N-Z
                cur_comp_data               = {4'b1011, data_i[63:48], data_i[47:32], data_i[31:16], 14'd0};
                cur_comp_size               = 'd52;
            end
            default: begin  // 4'b0000 N-N-N-N
                cur_comp_data               = {2'b11, data_i};
                cur_comp_size               = 'd66;
            end
        endcase
    end

    //----------------------------------------------------------
    // Code concatenate
    //----------------------------------------------------------
    wire    [10:0]                      blk_size;
    AIDC_LITE_CODE_CONCATENATE          u_concat
    (
        .clk                            (clk),
        .rst_n                          (rst_n),

        .valid_i                        (valid_i),
        .sop_i                          (sop_i),
        .eop_i                          (eop_i),
        .data_i                         (cur_comp_data),
        .size_i                         (cur_comp_size),

        .valid_o                        (valid_o),
        .addr_o                         (addr_o),
        .data_o                         (data_o),
        .blk_size_o                     (blk_size)
    );

    assign  fail_o                      = (blk_size>11'd512);

endmodule
