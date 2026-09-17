/*
* Copyright (c) 2026 Yuri Honegger. All rights reserved.
*/

package tb_clk_pkg;
    localparam time CLOCK_CYCLE = 20ns;
    localparam time EDGE_APPL_DELAY = CLOCK_CYCLE/4;
    localparam time APPL_ACQ_DELAY = CLOCK_CYCLE/2;
endpackage
