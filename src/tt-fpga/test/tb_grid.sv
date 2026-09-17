/*
* Copyright (c) 2026 Yuri Honegger. All rights reserved.
*/

module tb_grid ();
    import tb_clk_pkg::*;
    import fpga_pkg::*;

    logic clk;
    logic rst_n;

    logic configmode_sc;
    logic config_sc;

    logic [7:0] io_inputs;
    logic [7:0] io_outputs;

    initial begin
        io_inputs = '0;
    end

    tb_tool i_tb_tool (
        .clk_o(clk),
        .rst_no(rst_n),
        .configmode_sc_o(configmode_sc),
        .config_sc_o(config_sc)
    );

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

        .configmode_sc_i(configmode_sc),
        .config_sc_i(config_sc),
        .config_sc_o(),

        .io_inputs_i(io_inputs),
        .io_outputs_o(io_outputs)
    );

    initial begin
        $display(""); // print newline
        @(posedge rst_n);

        /* first test: only configure the first CLB and check if IOs work */
        i_tb_tool.load_bitstream("sim/bitstream/test_single_bb_io");
        // check if input 0 is passed through to output 0
        @(posedge clk);
        #(EDGE_APPL_DELAY);
        io_inputs[0] = 0;
        #(APPL_ACQ_DELAY);
        i_tb_tool.tb_assert(io_outputs[0] == 0, `__FILE__, `__LINE__);
        @(posedge clk);
        #(EDGE_APPL_DELAY);
        io_inputs[0] = 1;
        #(APPL_ACQ_DELAY);
        i_tb_tool.tb_assert(io_outputs[0] == 1, `__FILE__, `__LINE__);

        /* done */
        i_tb_tool.print_statistics();
    end

    initial begin
        $dumpfile("sim/tb_grid.fst");
        $dumpvars(1, i_dut);
    end

endmodule
