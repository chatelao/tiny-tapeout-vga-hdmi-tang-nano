/*
 * HDMI Serializer for Tang Nano 4K (GW1NSR-LV4C)
 *
 * This module uses Gowin OSER10 primitives to serialize 10-bit TMDS words
 * into a high-speed serial bitstream.
 */

`default_nettype none

module hdmi_serializer (
    input  wire       clk_pixel, // 25.2 MHz (Pixel Clock)
    input  wire       clk_x10,   // 252 MHz  (Serial Clock)
    input  wire       reset,     // Active high reset
    input  wire [9:0] tmds_d0,   // Blue/Hsync/Vsync
    input  wire [9:0] tmds_d1,   // Green/Control
    input  wire [9:0] tmds_d2,   // Red/Control
    input  wire [9:0] tmds_clk,  // TMDS Clock word (usually 10'b1111100000)
    output wire       ser_d0,
    output wire       ser_d1,
    output wire       ser_d2,
    output wire       ser_clk
);

    // Blue Channel (D0)
    OSER10 oser_d0_inst (
        .Q(ser_d0),
        .D0(tmds_d0[0]),
        .D1(tmds_d0[1]),
        .D2(tmds_d0[2]),
        .D3(tmds_d0[3]),
        .D4(tmds_d0[4]),
        .D5(tmds_d0[5]),
        .D6(tmds_d0[6]),
        .D7(tmds_d0[7]),
        .D8(tmds_d0[8]),
        .D9(tmds_d0[9]),
        .PCLK(clk_pixel),
        .FCLK(clk_x10),
        .RESET(reset)
    );

    // Green Channel (D1)
    OSER10 oser_d1_inst (
        .Q(ser_d1),
        .D0(tmds_d1[0]),
        .D1(tmds_d1[1]),
        .D2(tmds_d1[2]),
        .D3(tmds_d1[3]),
        .D4(tmds_d1[4]),
        .D5(tmds_d1[5]),
        .D6(tmds_d1[6]),
        .D7(tmds_d1[7]),
        .D8(tmds_d1[8]),
        .D9(tmds_d1[9]),
        .PCLK(clk_pixel),
        .FCLK(clk_x10),
        .RESET(reset)
    );

    // Red Channel (D2)
    OSER10 oser_d2_inst (
        .Q(ser_d2),
        .D0(tmds_d2[0]),
        .D1(tmds_d2[1]),
        .D2(tmds_d2[2]),
        .D3(tmds_d2[3]),
        .D4(tmds_d2[4]),
        .D5(tmds_d2[5]),
        .D6(tmds_d2[6]),
        .D7(tmds_d2[7]),
        .D8(tmds_d2[8]),
        .D9(tmds_d2[9]),
        .PCLK(clk_pixel),
        .FCLK(clk_x10),
        .RESET(reset)
    );

    // TMDS Clock Channel
    OSER10 oser_clk_inst (
        .Q(ser_clk),
        .D0(tmds_clk[0]),
        .D1(tmds_clk[1]),
        .D2(tmds_clk[2]),
        .D3(tmds_clk[3]),
        .D4(tmds_clk[4]),
        .D5(tmds_clk[5]),
        .D6(tmds_clk[6]),
        .D7(tmds_clk[7]),
        .D8(tmds_clk[8]),
        .D9(tmds_clk[9]),
        .PCLK(clk_pixel),
        .FCLK(clk_x10),
        .RESET(reset)
    );

endmodule
