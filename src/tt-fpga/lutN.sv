/*
* Copyright (c) 2026 Yuri Honegger. All rights reserved.
*/

module lutN #(
    parameter integer LutN = 4
) (
    input logic clk_i,
    input logic rst_ni,

    input logic configmode_sc_i,
    input logic config_sc_i,
    output logic config_sc_o,

    input logic [LutN-1:0] inputs_i,
    output logic output_o
);
    localparam integer ConfigBits = 1 << LutN;

    logic [ConfigBits-1:0] lookup_table;

    config_sc_register #(
        .Size(ConfigBits)
    ) i_lut_config (
        .clk_i(clk_i),
        .rst_ni(rst_ni),

        .configmode_sc_i(configmode_sc_i),
        .config_sc_i(config_sc_i),
        .config_sc_o(config_sc_o),

        .output_o(lookup_table)
    );

    assign output_o = lookup_table[inputs_i];
endmodule
