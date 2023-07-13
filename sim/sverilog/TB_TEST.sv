program AHB_TEST(
        AHB2_MST_INTF.master_tb               mst_ahb_if  (.hclk(clk), .hreset_n(rst_n));
        AHB2_SLV_INTF.slave_tb                slv_ahb_if  (.hclk(clk), .hreset_n(rst_n));
    );

    ahb_env env;
    
    initial begin
        $display("AHB_Test start");

        $display("AHB_env initialize");
        env = new(
            mst_ahb_if
            slv_ahb_if
            );

        $display("AHB_env run");
        env.run();
        
        $display("AHB_Test end");
        $finish();
    end

endprogram


program APB_TEST(
        APB_INTF                    apb_if      (.pclk(clk), .preset_n(rst_n));
    );
    apb_env   env;
    initial begin
        $display("APB_TEST start");

        $display("APB_env initialize");
        env = new(
            apbb_if
            );

        $display("APB_env run");
        env.run();
        
        $display("APB_Test end");
        $finish();
    end
endprogram
