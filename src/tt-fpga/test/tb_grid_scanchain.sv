/*
* Copyright (c) 2026 Yuri Honegger. All rights reserved.
*
* Test whether a fpga_building_block's scanchain works correctly
*/

module tb_grid_scanchain ();
    import tb_clk_pkg::*;
    import fpga_pkg::*;

    localparam integer GridScanchainLength = 3*3*ScanchainLength;

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

    fpga_grid #(
        .XSize(3),
        .YSize(3),
        .NumIoInputs(8),
        .NumIoOutputs(8),
        .LutN(LutN),
        .WireLength(WireLength),
        .StartCount(StartCount)
    ) i_dut (
        .clk_i(clk),
        .rst_ni(rst_n),

        .configmode_sc_i(scanchain_enable),
        .config_sc_i(scanchain_in),
        .config_sc_o(bb_scanchain_out),

        .io_inputs_i('0),
        .io_outputs_o()
    );

    config_sc_register #(
        .Size(GridScanchainLength)
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

        for (int i=0; i<1000*GridScanchainLength; i++) begin
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
