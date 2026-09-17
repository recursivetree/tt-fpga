/*
* Copyright (c) 2026 Yuri Honegger. All rights reserved.
*/

package fpga_pkg;
    localparam integer LutN = 4;
    localparam integer WireLength = 2;
    localparam integer StartCount = 2;
    localparam integer ChannelSize = WireLength * StartCount;
    localparam integer ScanchainLength =    2+(1<<LutN) // CLB
                                            + ($clog2(ChannelSize)+2)*LutN // input
                                            + StartCount*8; // fabric switch
endpackage
