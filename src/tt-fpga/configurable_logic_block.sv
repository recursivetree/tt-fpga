/*
* Copyright (c) 2026 Yuri Honegger. All rights reserved.
*/

module configurable_logic_block #(
    parameter integer LutN = 4
) (
    input logic clk_i,
    input logic rst_ni,

    input logic configmode_sc_i,
    input logic config_sc_i,
    output logic config_sc_o,
    
    input logic [LutN-1:0] inputs_i,

    output logic output_o,

    input logic carry_i,
    output logic carry_o
);

    logic [1:0] bundled_config;
    logic use_adder;
    logic use_register;
    logic config_register_config_chain;
    config_sc_register #(
        .Size(2)
    ) i_clb_config (
        .clk_i(clk_i),
        .rst_ni(rst_ni),

        .configmode_sc_i(configmode_sc_i),
        .config_sc_i(config_sc_i),
        .config_sc_o(config_register_config_chain),

        .output_o(bundled_config)
    );
    assign use_adder = bundled_config[0];
    assign use_register = bundled_config[1];
    
    logic [1:0] dual_lut_result;
    logic lut_combined_result;
    logic lut_config_chain;
    lutN #(
        .LutN(LutN-1)
    ) i_dual_lut_0 (
        .clk_i(clk_i),
        .rst_ni(rst_ni),

        .configmode_sc_i(configmode_sc_i),
        .config_sc_i(config_register_config_chain),
        .config_sc_o(lut_config_chain),

        .inputs_i(inputs_i[LutN-2:0]),
        .output_o(dual_lut_result[0])
    );
     lutN #(
        .LutN(LutN-1)
    ) i_dual_lut_1 (
        .clk_i(clk_i),
        .rst_ni(rst_ni),

        .configmode_sc_i(configmode_sc_i),
        .config_sc_i(lut_config_chain),
        .config_sc_o(config_sc_o),

        .inputs_i(inputs_i[LutN-2:0]),
        .output_o(dual_lut_result[1])
    );
    assign lut_combined_result = inputs_i[LutN-1] ? dual_lut_result[1] : dual_lut_result[0];
    
    // adder stage
    logic adder_stage_result;
    logic sum_value;
    assign sum_value = dual_lut_result[0] ^ dual_lut_result[1] ^ carry_i;
    assign carry_o = (dual_lut_result[0] && carry_i) || (dual_lut_result[1] && carry_i) || (dual_lut_result[0] && dual_lut_result[1]);
    assign adder_stage_result = use_adder ? sum_value : lut_combined_result;

    // register stage
    logic reg_d, reg_q;
    assign reg_d = adder_stage_result;
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            reg_q <= '0;
        end else begin
            reg_q <= reg_d;
        end
    end
    assign output_o = use_register ? reg_q : adder_stage_result;

endmodule
