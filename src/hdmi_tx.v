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
    // Data Island Interface
    input  wire        di_start,
    input  wire [23:0] di_header,
    input  wire [55:0] di_sub0,
    input  wire [55:0] di_sub1,
    input  wire [55:0] di_sub2,
    input  wire [55:0] di_sub3,
    output wire        di_active,
    // Serial Outputs
    output wire       ser_clk,
    output wire       ser_d0,
    output wire       ser_d1,
    output wire       ser_d2
);

    wire [9:0] tmds_d0;
    wire [9:0] tmds_d1;
    wire [9:0] tmds_d2;

    wire [9:0] di_d0;
    wire [9:0] di_d1;
    wire [9:0] di_d2;

    // Data Island Framer
    hdmi_data_island_framer di_framer_inst (
        .clk(clk_pixel),
        .reset(reset),
        .start(di_start),
        .header_data(di_header),
        .sub0_data(di_sub0),
        .sub1_data(di_sub1),
        .sub2_data(di_sub2),
        .sub3_data(di_sub3),
        .hsync(hsync),
        .vsync(vsync),
        .chan0_tmds(di_d0),
        .chan1_tmds(di_d1),
        .chan2_tmds(di_d2),
        .active(di_active)
    );

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

    // Multiplex between Video/Control and Data Island
    wire [9:0] mux_d0 = (vde) ? tmds_d0 : (di_active ? di_d0 : tmds_d0);
    wire [9:0] mux_d1 = (vde) ? tmds_d1 : (di_active ? di_d1 : tmds_d1);
    wire [9:0] mux_d2 = (vde) ? tmds_d2 : (di_active ? di_d2 : tmds_d2);

    // Serializer
    hdmi_serializer serializer_inst (
        .clk_pixel(clk_pixel),
        .clk_x10(clk_x10),
        .reset(reset),
        .tmds_d0(mux_d0),
        .tmds_d1(mux_d1),
        .tmds_d2(mux_d2),
        .tmds_clk(10'b1111100000),
        .ser_d0(ser_d0),
        .ser_d1(ser_d1),
        .ser_d2(ser_d2),
        .ser_clk(ser_clk)
    );

endmodule
