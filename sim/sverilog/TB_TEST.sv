program TEST_CASE_1(
        AHB2_MST_INTF               mst_ahb_if  (.hclk(clk), .hreset_n(rst_n));
        AHB2_SLV_INTF               slv_ahb_if  (.hclk(clk), .hreset_n(rst_n));
  
    );

    Test_env env;
    
    initial begin
        $display("Test Case 1 start");

        $display("Test_env initialize");
        env = new(
            mst_ahb_if
            slv_ahb_if
            );

        $display("Test_env run");
        env.run();
        
        $display("Test Case 1 end");
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
