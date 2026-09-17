/*
* Copyright (c) 2026 Yuri Honegger. All rights reserved.
*/

module input_mux #(
    parameter integer InputSize = 1
) (
    input logic clk_i,
    input logic rst_ni,

    input logic configmode_sc_i,
    input logic config_sc_i,
    output logic config_sc_o,

    input logic [InputSize-1:0] west_i,
    input logic [InputSize-1:0] north_i,
    input logic [InputSize-1:0] east_i,
    input logic [InputSize-1:0] south_i,

    output logic output_o
);
    localparam ConfigSize = $clog2(InputSize)+2;

    logic [ConfigSize-1:0] mux_config;
    logic [1:0] heading_config;
    logic [$clog2(InputSize)-1:0] signal_config;

    config_sc_register #(
        .Size(ConfigSize)
    ) i_input_mux_config (
        .clk_i(clk_i),
        .rst_ni(rst_ni),

        .configmode_sc_i(configmode_sc_i),
        .config_sc_i(config_sc_i),
        .config_sc_o(config_sc_o),

        .output_o(mux_config)
    );

    assign heading_config = mux_config[ConfigSize-1:ConfigSize-2];
    assign signal_config = mux_config[ConfigSize-2-1:0];

    logic [InputSize-1:0] selected_heading;
    always_comb begin
        case (heading_config)
            2'b00: selected_heading = west_i;
            2'b01: selected_heading = north_i;
            2'b10: selected_heading = east_i;
            2'b11: selected_heading = south_i;
        endcase
    end

    assign output_o = selected_heading[signal_config];

endmodule
