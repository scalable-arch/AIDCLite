module AIDC_ADDR_CONVERTER
(
    input   wire                        clk,
    input   wire                        rst_n,

    AXI4_A_INTF.slave                   core_a_if,
    AXI4_A_INTF.master                  mem_a_if
);

    always_comb begin
        `AXI4_A_INTF_CONNECT(core_a_if, mem_a_if);

        // convert 16-beat burst to 8-beat burst
        if (core_a_if.alen==8'hf) begin
            mem_a_if.alen                  = 8'h7;
        end
    end

endmodule
