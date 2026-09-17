/*
* Copyright (c) 2026 Yuri Honegger. All rights reserved.
*
* Test whether a fpga_building_block's scanchain works correctly
*/

module tb_bb_scanchain ();
    import tb_clk_pkg::*;
    import fpga_pkg::*;

    logic clk;
    logic rst_n;

    rst_clk_gen i_rst_clk_gen (
        .clk_o(clk),
        .rst_no(rst_n)
    );

    logic scanchain_enable;
    logic scanchain_in;
    logic bb_scanchain_out;
    logic sr_scanchain_out;

    fpga_building_block #(
        .LutN(LutN),
        .WireLength(WireLength),
        .StartCount(StartCount)
    ) i_dut (
        .clk_i(clk),
        .rst_ni(rst_n),

        .configmode_sc_i(scanchain_enable),
        .config_sc_i(scanchain_in),
        .config_sc_o(bb_scanchain_out),

        .west_i('0),
        .north_i('0),
        .east_i('0),
        .south_i('0),

        .west_o(),
        .north_o(),
        .east_o(),
        .south_o(),

        .carry_i(0),
        .carry_o()
    );

    config_sc_register #(
        .Size(ScanchainLength)
    ) i_golden_model_scanchain (
        .clk_i(clk),
        .rst_ni(rst_n),

        .configmode_sc_i(scanchain_enable),
        .config_sc_i(scanchain_in),
        .config_sc_o(sr_scanchain_out),

        .output_o()
    );

    initial begin
        scanchain_in = 0;
        scanchain_enable = 0;
        @(posedge rst_n);

        for (int i=0; i<1000*ScanchainLength; i++) begin
            @(posedge clk);
            #(EDGE_APPL_DELAY);
            std::randomize(scanchain_in);
            std::randomize(scanchain_enable);
            #(APPL_ACQ_DELAY);
            assert(bb_scanchain_out == sr_scanchain_out);
        end

        $finish();
    end

endmodule
