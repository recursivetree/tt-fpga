/*
* Copyright (c) 2026 Yuri Honegger. All rights reserved.
*/

module fabric_switch #(
    parameter integer WireLength = 2,
    parameter integer StartCount = 2
) (
    input logic clk_i,
    input logic rst_ni,

    input logic configmode_sc_i,
    input logic config_sc_i,
    output logic config_sc_o,

    input logic clb_output_i,

    input logic [ChannelSize-1:0] west_i,
    input logic [ChannelSize-1:0] north_i,
    input logic [ChannelSize-1:0] east_i,
    input logic [ChannelSize-1:0] south_i,

    output logic [ChannelSize-1:0] west_o,
    output logic [ChannelSize-1:0] north_o,
    output logic [ChannelSize-1:0] east_o,
    output logic [ChannelSize-1:0] south_o
);
    localparam integer ChannelSize = WireLength * StartCount;
    localparam integer ConfigSize = StartCount*8;

    typedef struct packed {
        logic use_clb;
        logic use_clockwise;
    } fabric_wire_start_t;

    typedef struct packed {
      fabric_wire_start_t [StartCount-1:0] west_config;
      fabric_wire_start_t [StartCount-1:0] north_config;
      fabric_wire_start_t [StartCount-1:0] east_config;
      fabric_wire_start_t [StartCount-1:0] south_config;
    } fabric_switch_t;

    //logic [ConfigSize-1:0] switch_config;
    fabric_switch_t switch_config;
    config_sc_register #(
        .Size(ConfigSize)
    ) i_switch_config_register (
        .clk_i(clk_i),
        .rst_ni(rst_ni),

        .configmode_sc_i(configmode_sc_i),
        .config_sc_i(config_sc_i),
        .config_sc_o(config_sc_o),

        .output_o(switch_config)
    );

    // passthrough connections
    generate
        for (genvar group = 0; group < StartCount; group++) begin : passthrough_group
            for (genvar ttl = 1; ttl < WireLength; ttl++) begin : passthrough_ttl
                localparam integer ChannelPosition = group * WireLength + ttl;
                assign west_o[ChannelPosition] = east_i[ChannelPosition];
                assign north_o[ChannelPosition] = south_i[ChannelPosition];
                assign east_o[ChannelPosition] = west_i[ChannelPosition];
                assign south_o[ChannelPosition] = north_i[ChannelPosition];
            end
        end
    endgenerate

    // starting connections
    generate
        for (genvar group_index = 0; group_index < StartCount; group_index++) begin : start_group
            localparam integer ChannelPosition = group_index * WireLength;

            assign west_o[ChannelPosition] = switch_config.west_config[group_index].use_clb ? clb_output_i :
                                             switch_config.west_config[group_index].use_clockwise ? north_i[ChannelPosition] : south_i[ChannelPosition];

            assign north_o[ChannelPosition] = switch_config.north_config[group_index].use_clb ? clb_output_i :
                                              switch_config.north_config[group_index].use_clockwise ? east_i[ChannelPosition] : west_i[ChannelPosition];

            assign east_o[ChannelPosition] = switch_config.east_config[group_index].use_clb ? clb_output_i :
                                             switch_config.east_config[group_index].use_clockwise ? south_i[ChannelPosition] : north_i[ChannelPosition];

            assign south_o[ChannelPosition] = switch_config.south_config[group_index].use_clb ? clb_output_i :
                                              switch_config.south_config[group_index].use_clockwise ? west_i[ChannelPosition] : east_i[ChannelPosition];

        end
    endgenerate

endmodule
