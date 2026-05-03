/*
 * HDMI Transmitter Module for Tang Nano 4K
 *
 * This module integrates the TMDS encoders and the serializer to convert
 * parallel RGB/Sync data into a high-speed TMDS bitstream.
 */

`default_nettype none

module hdmi_tx (
    input  wire       clk_pixel, // 25.2 MHz
    input  wire       clk_x10,   // 252 MHz
    input  wire       reset,
    input  wire [7:0] red,
    input  wire [7:0] green,
    input  wire [7:0] blue,
    input  wire       hsync,
    input  wire       vsync,
    input  wire       vde,
    output wire       ser_clk,
    output wire       ser_d0,
    output wire       ser_d1,
    output wire       ser_d2
);

    wire [9:0] tmds_d0;
    wire [9:0] tmds_d1;
    wire [9:0] tmds_d2;

    // TMDS Encoders
    tmds_encoder enc_blue (
        .clk(clk_pixel),
        .reset(reset),
        .data(blue),
        .ctrl({vsync, hsync}),
        .vde(vde),
        .tmds(tmds_d0)
    );

    tmds_encoder enc_green (
        .clk(clk_pixel),
        .reset(reset),
        .data(green),
        .ctrl(2'b00),
        .vde(vde),
        .tmds(tmds_d1)
    );

    tmds_encoder enc_red (
        .clk(clk_pixel),
        .reset(reset),
        .data(red),
        .ctrl(2'b00),
        .vde(vde),
        .tmds(tmds_d2)
    );

    // Serializer
    hdmi_serializer serializer_inst (
        .clk_pixel(clk_pixel),
        .clk_x10(clk_x10),
        .reset(reset),
        .tmds_d0(tmds_d0),
        .tmds_d1(tmds_d1),
        .tmds_d2(tmds_d2),
        .tmds_clk(10'b1111100000),
        .ser_d0(ser_d0),
        .ser_d1(ser_d1),
        .ser_d2(ser_d2),
        .ser_clk(ser_clk)
    );

endmodule
