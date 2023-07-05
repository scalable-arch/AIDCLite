module AIDC_SOP_GEN (
    input   wire                        clk,
    input   wire                        rst_n,

    input   wire                        valid_i,
    input   wire                        ready_i,
    input   wire                        last_i,
    output  wire                        sop_o
);

    logic                               sop;

    always @(posedge clk) begin
        if (!rst_n) begin
            sop                             <= 1'b1;
        end
        else if(valid_i & ready_i) begin
            if (last_i)
                sop                         <= 1'b1;
            else
                sop                         <= 1'b0;
        end
    end

    assign  sop_o                       = sop;

endmodule
