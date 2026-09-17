/*
* Copyright (c) 2026 Yuri Honegger. All rights reserved.
*/

module tb_tool #(

) (
    output logic clk_o,
    output logic rst_no,

    output logic configmode_sc_o,
    output logic config_sc_o
);
    rst_clk_gen i_rst_clk_gen (
        .clk_o(clk_o),
        .rst_no(rst_no)
    );

    config_sc_loader i_sc_loader (
        .clk_i(clk_o),
        .configmode_sc_o(configmode_sc_o),
        .config_sc_o(config_sc_o)
    );

    task automatic load_bitstream(
        input string bitstream_file
    );
        i_sc_loader.load_bitstream(bitstream_file);
    endtask

    integer successful_tests = 0;
    integer failed_tests = 0;
    task tb_assert(
        input logic ok,
        input string file,
        input integer line
    );
        if (ok) begin
            successful_tests += 1;
        end else begin
            failed_tests += 1;
            $display("TEST FAILED: %s:%0d time=%0t", file, line, $time);
        end
    endtask
//`define TB_ASSERT(ok) \
//    tb_assert((ok), `__FILE__, `__LINE__)

    task print_statistics();
        $display("\nresults: %0d successful, %0d failed", successful_tests, failed_tests);
        if (failed_tests == 0) begin
            $display(""); // print newline
            $finish();
        end else begin
            $display("there are failures!\n");
            $fatal(1, "tests failed");
        end
    endtask
endmodule
