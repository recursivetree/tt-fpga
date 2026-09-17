/*
* Copyright (c) 2026 Yuri Honegger. All rights reserved.
*/

module config_sc_loader #(

) (
    input logic clk_i,

    output logic configmode_sc_o,
    output logic config_sc_o
);
    import tb_clk_pkg::*;

    initial begin
        configmode_sc_o = 0;
    end

    task automatic load_bitstream(
        input string bitstream_file
    );
        logic [31:0] version_hdr;
        logic [31:0] size_hdr;
        logic [7:0] bitstream_byte;
        integer fd;
        integer bitstream_len;

        fd = $fopen(bitstream_file, "rb");
        if (fd == 0) begin
          $fatal("Could not open data.bin");
        end

        // read version header
        $fread(version_hdr, fd);
        assert(version_hdr == 32'h01000000); // little-endian

        // length size
        $fread(size_hdr, fd);
        bitstream_len = {size_hdr[7:0], size_hdr[15:8], size_hdr[23:16], size_hdr[31:24]};
        $display("%s: version = %h bitstream length = %0d bits", bitstream_file, version_hdr, bitstream_len);

        // read bistream file and shift it in
        @(posedge clk_i);
         #(EDGE_APPL_DELAY);
        configmode_sc_o = 1;

        while (!$feof(fd)) begin
            $fread(bitstream_byte, fd);

            for (integer i=0; i<8 && bitstream_len > 0; i++) begin
                config_sc_o = bitstream_byte[0];
                bitstream_byte = bitstream_byte >>> 1;
                bitstream_len = bitstream_len - 1;
                @(posedge clk_i);
                #(EDGE_APPL_DELAY);
            end
        end
        configmode_sc_o = 0;
        @(posedge clk_i);
    endtask

endmodule
