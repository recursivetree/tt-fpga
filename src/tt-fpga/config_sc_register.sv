/*
* Copyright (c) 2026 Yuri Honegger. All rights reserved.
*/

module config_sc_register #(
    parameter integer Size = 1
) (
    input logic clk_i,
    input logic rst_ni,

    input logic configmode_sc_i,
    input logic config_sc_i,
    output logic config_sc_o,
    
    output logic [Size-1:0] output_o
);
    logic [Size-1:0] config_d, config_q;
    
    always_comb begin
        config_d = config_q;

        if (configmode_sc_i) begin
            config_d = {config_q[Size-2:0], config_sc_i};
        end
    end

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            config_q <= '0;
        end else begin
            config_q <= config_d;
        end
    end

    assign config_sc_o = config_q[Size-1];
    assign output_o = config_q;
endmodule
