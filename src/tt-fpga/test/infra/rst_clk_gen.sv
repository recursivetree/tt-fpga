/*
* Copyright (c) 2026 Yuri Honegger. All rights reserved.
*/

module rst_clk_gen #(

) (
    output logic clk_o,
    output logic rst_no
);
    import tb_clk_pkg::*;

    initial begin
        clk_o = 1;
        rst_no = 0;

        @(posedge clk_o);
        rst_no = 1;
    end

    always begin
        #(CLOCK_CYCLE / 2);
        clk_o = !clk_o;
    end

endmodule
