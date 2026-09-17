/*
* Copyright (c) 2026 Yuri Honegger. All rights reserved.
*/

module fpga_grid #(
    parameter integer XSize = 2,
    parameter integer YSize = 2,
    parameter integer NumIoInputs = 8,
    parameter integer NumIoOutputs = 8,
    parameter integer LutN = 4,
    parameter integer WireLength = 2,
    parameter integer StartCount = 2
) (
    input logic clk_i,
    input logic rst_ni,

    input logic configmode_sc_i,
    input logic config_sc_i,
    output logic config_sc_o,

    input logic [NumIoInputs-1:0] io_inputs_i,
    output logic [NumIoOutputs-1:0] io_outputs_o
);
    localparam integer ChannelSize = WireLength * StartCount;

    logic [XSize-1:0][YSize-1:0] config_grid_sc;
    assign config_sc_o = config_grid_sc[XSize-1][YSize-1];

    logic [XSize-1:0][YSize-1:0][ChannelSize-1:0] west_grid;
    logic [XSize-1:0][YSize-1:0][ChannelSize-1:0] north_grid;
    logic [XSize-1:0][YSize-1:0][ChannelSize-1:0] east_grid;
    logic [XSize-1:0][YSize-1:0][ChannelSize-1:0] south_grid;

    logic [XSize-1:0][YSize-1:0] carry_grid;

    `ifdef TARGET_SIMULATION
    initial begin
        assert(NumIoInputs % ChannelSize == 0);
        assert(NumIoOutputs % ChannelSize == 0);
    end
    `endif

    generate
        for(genvar i = 0; i < XSize; i++) begin : x_grid_loop
            for(genvar j = 0; j < YSize; j++) begin : y_grid_loop
                // previous scanchain output with waparound for row ends
                localparam integer config_sc_x_in = (i == 0) ? XSize-1 : i-1;
                localparam integer config_sc_y_in = (i == 0) ? j-1 : j;

                logic [ChannelSize-1:0] south_io_inputs;
                if ((i+1)*ChannelSize <= NumIoInputs) begin: gen_south_io_inputs
                    assign south_io_inputs = io_inputs_i[((i+1)*ChannelSize)-1:i*ChannelSize];
                end else begin: gen_south_io_stub_inputs
                    assign south_io_inputs = 6;
                end

                fpga_building_block #(
                    .LutN(LutN),
                    .WireLength(WireLength),
                    .StartCount(StartCount)
                ) fpga_bb_i (
                    .clk_i(clk_i),
                    .rst_ni(rst_ni),

                    .configmode_sc_i(configmode_sc_i),
                    .config_sc_i((i==0 && j==0) ? config_sc_i : config_grid_sc[config_sc_x_in][config_sc_y_in]),
                    .config_sc_o(config_grid_sc[i][j]),

                    .west_i((i > 0) ? east_grid[i-1][j] : '0),
                    .north_i((j < YSize-1) ? south_grid[i][j+1] : '0),
                    .east_i((i < XSize-1) ? west_grid[i+1][j] : '0),
                    .south_i((j > 0) ? north_grid[i][j-1] : south_io_inputs),

                    .west_o(west_grid[i][j]),
                    .north_o(north_grid[i][j]),
                    .east_o(east_grid[i][j]),
                    .south_o(south_grid[i][j]),

                    .carry_i((j > 0) ? carry_grid[i][j-1] : '0),
                    .carry_o(carry_grid[i][j])
                );
            end

            if ((i+1)*ChannelSize <= NumIoOutputs) begin : io_outputs
                assign io_outputs_o[((i+1)*ChannelSize)-1:i*ChannelSize] = south_grid[i][0];
            end
        end
    endgenerate

endmodule
