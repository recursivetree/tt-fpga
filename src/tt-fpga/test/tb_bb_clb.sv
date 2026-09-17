/*
* Copyright (c) 2026 Yuri Honegger. All rights reserved.
*/

module tb_bb_clb ();
    import tb_clk_pkg::*;
    import fpga_pkg::*;

    logic clk;
    logic rst_n;

    logic configmode_sc_i;
    logic config_sc_i;
    logic [ChannelSize-1:0] west_i;
    logic [ChannelSize-1:0] north_i;
    logic [ChannelSize-1:0] east_i;
    logic [ChannelSize-1:0] south_i;
    logic [ChannelSize-1:0] west_o;
    logic [ChannelSize-1:0] north_o;
    logic [ChannelSize-1:0] east_o;
    logic [ChannelSize-1:0] south_o;
    logic carry_i;
    logic carry_o;

    initial begin
        west_i = 0;
        north_i = 0;
        east_i = 0;
        south_i = 0;
        carry_i = 0;
    end

    tb_tool i_tb_tool (
        .clk_o(clk),
        .rst_no(rst_n),
        .configmode_sc_o(configmode_sc_i),
        .config_sc_o(config_sc_i)
    );

    fpga_building_block #(
        .LutN(LutN),
        .WireLength(WireLength),
        .StartCount(StartCount)
    ) i_dut (
        .clk_i(clk),
        .rst_ni(rst_n),

        .configmode_sc_i(configmode_sc_i),
        .config_sc_i(config_sc_i),
        .config_sc_o(),

        .west_i(west_i),
        .north_i(north_i),
        .east_i(east_i),
        .south_i(south_i),

        .west_o(west_o),
        .north_o(north_o),
        .east_o(east_o),
        .south_o(south_o),

        .carry_i(carry_i),
        .carry_o(carry_o)
    );

    initial begin
        $display(""); // print newline
        @(posedge rst_n);

        /* BITSTREAM 1: basic LUT test */
        i_tb_tool.load_bitstream("sim/bitstream/test_basic_lut");

        // input value = 0
        @(posedge clk);
        #(EDGE_APPL_DELAY);
        north_i = 0;
        #(APPL_ACQ_DELAY);
        i_tb_tool.tb_assert(west_o == 4'b0000, `__FILE__, `__LINE__);
        i_tb_tool.tb_assert(north_o == 4'b0000, `__FILE__, `__LINE__);
        i_tb_tool.tb_assert(east_o == 4'b0000, `__FILE__, `__LINE__);
        i_tb_tool.tb_assert((south_o & 4'b0101) == 4'b0000, `__FILE__, `__LINE__);

        // input value = 1
        @(posedge clk);
        #(EDGE_APPL_DELAY);
        north_i = 4'b0001;
        #(APPL_ACQ_DELAY);
        i_tb_tool.tb_assert(west_o == 4'b0101, `__FILE__, `__LINE__);
        i_tb_tool.tb_assert(north_o == 4'b0101, `__FILE__, `__LINE__);
        i_tb_tool.tb_assert(east_o == 4'b0101, `__FILE__, `__LINE__);
        i_tb_tool.tb_assert((south_o & 4'b0101) == 4'b0101, `__FILE__, `__LINE__);

        // input value = 2
        @(posedge clk);
        #(EDGE_APPL_DELAY);
        north_i = 4'b0010;
        #(APPL_ACQ_DELAY);
        i_tb_tool.tb_assert(west_o == 4'b0101, `__FILE__, `__LINE__);
        i_tb_tool.tb_assert(north_o == 4'b0101, `__FILE__, `__LINE__);
        i_tb_tool.tb_assert(east_o == 4'b0101, `__FILE__, `__LINE__);
        i_tb_tool.tb_assert((south_o & 4'b0101) == 4'b0101, `__FILE__, `__LINE__);

        // input value = 3
        @(posedge clk);
        #(EDGE_APPL_DELAY);
        north_i = 4'b0011;
        #(APPL_ACQ_DELAY);
        i_tb_tool.tb_assert(west_o == 4'b0000, `__FILE__, `__LINE__);
        i_tb_tool.tb_assert(north_o == 4'b0000, `__FILE__, `__LINE__);
        i_tb_tool.tb_assert(east_o == 4'b0000, `__FILE__, `__LINE__);
        i_tb_tool.tb_assert((south_o & 4'b0101) == 4'b0000, `__FILE__, `__LINE__);

        // input value = 4
        @(posedge clk);
        #(EDGE_APPL_DELAY);
        north_i = 4'b0100;
        #(APPL_ACQ_DELAY);
        i_tb_tool.tb_assert(west_o == 4'b0101, `__FILE__, `__LINE__);
        i_tb_tool.tb_assert(north_o == 4'b0101, `__FILE__, `__LINE__);
        i_tb_tool.tb_assert(east_o == 4'b0101, `__FILE__, `__LINE__);
        i_tb_tool.tb_assert((south_o & 4'b0101) == 4'b0101, `__FILE__, `__LINE__);

        // input value = 8
        @(posedge clk);
        #(EDGE_APPL_DELAY);
        north_i = 4'b1000;
        #(APPL_ACQ_DELAY);
        i_tb_tool.tb_assert(west_o == 4'b0101, `__FILE__, `__LINE__);
        i_tb_tool.tb_assert(north_o == 4'b0101, `__FILE__, `__LINE__);
        i_tb_tool.tb_assert(east_o == 4'b0101, `__FILE__, `__LINE__);
        i_tb_tool.tb_assert((south_o & 4'b0101) == 4'b0101, `__FILE__, `__LINE__);

        /* BITSTREAM 2: adder test */
        i_tb_tool.load_bitstream("sim/bitstream/test_adder");
        // 0+0+0 = sum 0 carry 0
        @(posedge clk);
        #(EDGE_APPL_DELAY);
        carry_i = 0;
        north_i = 4'b0000;
        #(APPL_ACQ_DELAY);
        i_tb_tool.tb_assert(north_o == 4'b0000, `__FILE__, `__LINE__);
        i_tb_tool.tb_assert(carry_o == 1'b0, `__FILE__, `__LINE__);
        // 1+0+0 = sum 1 carry 0
        @(posedge clk);
        #(EDGE_APPL_DELAY);
        carry_i = 1;
        north_i = 4'b0000;
        #(APPL_ACQ_DELAY);
        i_tb_tool.tb_assert(north_o == 4'b0001, `__FILE__, `__LINE__);
        i_tb_tool.tb_assert(carry_o == 1'b0, `__FILE__, `__LINE__);
        // 0+1+0 = sum 1 carry 0
        @(posedge clk);
        #(EDGE_APPL_DELAY);
        carry_i = 0;
        north_i = 4'b0001;
        #(APPL_ACQ_DELAY);
        i_tb_tool.tb_assert(north_o == 4'b0001, `__FILE__, `__LINE__);
        i_tb_tool.tb_assert(carry_o == 1'b0, `__FILE__, `__LINE__);
        // 0+0+1 = sum 1 carry 0
        @(posedge clk);
        #(EDGE_APPL_DELAY);
        carry_i = 0;
        north_i = 4'b0010;
        #(APPL_ACQ_DELAY);
        i_tb_tool.tb_assert(north_o == 4'b0001, `__FILE__, `__LINE__);
        i_tb_tool.tb_assert(carry_o == 1'b0, `__FILE__, `__LINE__);
        // 1+1+0 = sum 0 carry 1
        @(posedge clk);
        #(EDGE_APPL_DELAY);
        carry_i = 1;
        north_i = 4'b0001;
        #(APPL_ACQ_DELAY);
        i_tb_tool.tb_assert(north_o == 4'b0000, `__FILE__, `__LINE__);
        i_tb_tool.tb_assert(carry_o == 1'b1, `__FILE__, `__LINE__);
        // 1+0+1 = sum 0 carry 1
        @(posedge clk);
        #(EDGE_APPL_DELAY);
        carry_i = 1;
        north_i = 4'b0010;
        #(APPL_ACQ_DELAY);
        i_tb_tool.tb_assert(north_o == 4'b0000, `__FILE__, `__LINE__);
        i_tb_tool.tb_assert(carry_o == 1'b1, `__FILE__, `__LINE__);
        // 0+1+1 = sum 0 carry 1
        @(posedge clk);
        #(EDGE_APPL_DELAY);
        carry_i = 0;
        north_i = 4'b0011;
        #(APPL_ACQ_DELAY);
        i_tb_tool.tb_assert(north_o == 4'b0000, `__FILE__, `__LINE__);
        i_tb_tool.tb_assert(carry_o == 1'b1, `__FILE__, `__LINE__);
        // 1+1+1 = sum 1 carry 1
        @(posedge clk);
        #(EDGE_APPL_DELAY);
        carry_i = 1;
        north_i = 4'b0011;
        #(APPL_ACQ_DELAY);
        i_tb_tool.tb_assert(north_o == 4'b0001, `__FILE__, `__LINE__);
        i_tb_tool.tb_assert(carry_o == 1'b1, `__FILE__, `__LINE__);


        /* BITSTREAM 3: register test */
        i_tb_tool.load_bitstream("sim/bitstream/test_register");
        // bring it to a known state
        @(posedge clk);
        #(EDGE_APPL_DELAY);
        north_i = 4'b0000;
        @(posedge clk);
        // change value; output shouldn't change until clock
        #(EDGE_APPL_DELAY);
        north_i = 4'b0001;
        #(APPL_ACQ_DELAY);
        i_tb_tool.tb_assert(north_o == 4'b0000, `__FILE__, `__LINE__);
        // value should change with clock + change it back in next cycle
        @(posedge clk);
        #(EDGE_APPL_DELAY);
        north_i = 4'b0000;
        #(APPL_ACQ_DELAY);
        i_tb_tool.tb_assert(north_o == 4'b0001, `__FILE__, `__LINE__);
        // value should be back to inital state
        @(posedge clk);
        #(EDGE_APPL_DELAY);
        #(APPL_ACQ_DELAY);
        i_tb_tool.tb_assert(north_o == 4'b0000, `__FILE__, `__LINE__);

        /* done */
        i_tb_tool.print_statistics();
    end

    initial begin
        $dumpfile("sim/tb_bb_clb.fst");
        $dumpvars(1, i_dut);
    end

endmodule
