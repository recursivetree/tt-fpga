/*
* Copyright (c) 2026 Yuri Honegger. All rights reserved.
*/

module fpga_building_block #(
    parameter integer LutN = 4,
    parameter integer WireLength = 2,
    parameter integer StartCount = 2
) (
    input logic clk_i,
    input logic rst_ni,

    input logic configmode_sc_i,
    input logic config_sc_i,
    output logic config_sc_o,

    input logic [ChannelSize-1:0] west_i,
    input logic [ChannelSize-1:0] north_i,
    input logic [ChannelSize-1:0] east_i,
    input logic [ChannelSize-1:0] south_i,

    output logic [ChannelSize-1:0] west_o,
    output logic [ChannelSize-1:0] north_o,
    output logic [ChannelSize-1:0] east_o,
    output logic [ChannelSize-1:0] south_o,

    input logic carry_i,
    output logic carry_o
);
    localparam integer ChannelSize = WireLength * StartCount;

    // CLB
    logic [LutN-1:0] clb_inputs;
    logic clb_output;
    configurable_logic_block #(
        .LutN(LutN)
    ) i_clb (
        .clk_i(clk_i),
        .rst_ni(rst_ni),

        .configmode_sc_i(configmode_sc_i),
        .config_sc_i(config_sc_i),
        .config_sc_o(clb_input_mux_config[0]),

        .inputs_i(clb_inputs),

        .output_o(clb_output),

        .carry_i(carry_i),
        .carry_o(carry_o)
    );

    // clb input muxes
    logic [LutN:0] clb_input_mux_config;
    generate
        for(genvar i = 0; i < LutN; i++) begin : clb_input_mux
            input_mux #(
                .InputSize(ChannelSize)
            ) i_clb_input_mux (
                .clk_i(clk_i),
                .rst_ni(rst_ni),

                .configmode_sc_i(configmode_sc_i),
                .config_sc_i(clb_input_mux_config[i]),
                .config_sc_o(clb_input_mux_config[i+1]),

                .west_i(west_i),
                .north_i(north_i),
                .east_i(east_i),
                .south_i(south_i),

                .output_o(clb_inputs[i])
            );
        end
    endgenerate

    // switch
    fabric_switch #(

    ) i_fabric_switch (
        .clk_i(clk_i),
        .rst_ni(rst_ni),

        .configmode_sc_i(configmode_sc_i),
        .config_sc_i(clb_input_mux_config[LutN]),
        .config_sc_o(config_sc_o),

        .clb_output_i(clb_output),

        .west_i(west_i),
        .north_i(north_i),
        .east_i(east_i),
        .south_i(south_i),

        .west_o(west_o),
        .north_o(north_o),
        .east_o(east_o),
        .south_o(south_o)
    );
endmodule
