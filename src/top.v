/* top.v - VGA to HDMI on Tang Nano 4K */
`default_nettype none

module top (
    input  wire       clk_27m,      // Pin 45
    output wire       uart0_txd,    // Pin 18
    input  wire       uart0_rxd,    // Pin 19
    output wire       led_pin,      // LED
    input  wire       btn1_pin,     // BTN-1
    input  wire       btn2_pin,     // BTN-2 (Reset)

    // HDMI/DVI
    output wire       tmds_clk_p,
    output wire [2:0] tmds_d_p
);

    wire [15:0] m3_gpio;

    // --- M3 System ---
    Gowin_EMPU_Top m3_inst (
        .sys_clk(clk_27m),
        .gpio(m3_gpio),
        .uart0_rxd(uart0_rxd),
        .uart0_txd(uart0_txd),
        .reset_n(btn2_pin)
    );

    // --- Clock Generation ---
    wire clk_pixel;
    wire clk_x10;
    wire pll_lock;

    hdmi_clk_gen clk_gen_inst (
        .clk_in(clk_27m),
        .reset(~btn2_pin),
        .clk_pixel(clk_pixel),
        .clk_x10(clk_x10),
        .lock(pll_lock)
    );

    // --- VGA Source (TT Module) ---
    wire [7:0] tt_uo_out;
    wire [7:0] tt_uio_out;

    tt_um_vga_example vga_source_inst (
        .ui_in(8'b0),
        .uo_out(tt_uo_out),
        .uio_in(8'b0),
        .uio_out(tt_uio_out),
        .uio_oe(),
        .ena(1'b1),
        .clk(clk_pixel),
        .rst_n(btn2_pin && pll_lock)
    );

    // Map TinyVGA PMOD signals from tt_uo_out
    // tt_uo_out = {hsync, B0, G0, R0, vsync, B1, G1, R1}
    wire vga_hsync = tt_uo_out[7];
    wire vga_vsync = tt_uo_out[3];
    wire vga_vde   = tt_uio_out[0];
    wire [7:0] vga_r = {tt_uo_out[0], tt_uo_out[4], 6'b0};
    wire [7:0] vga_g = {tt_uo_out[1], tt_uo_out[5], 6'b0};
    wire [7:0] vga_b = {tt_uo_out[2], tt_uo_out[6], 6'b0};

    // --- HDMI Transmitter ---
    hdmi_tx hdmi_tx_inst (
        .clk_pixel(clk_pixel),
        .clk_x10(clk_x10),
        .reset(~pll_lock),
        .red(vga_r),
        .green(vga_g),
        .blue(vga_b),
        .hsync(vga_hsync),
        .vsync(vga_vsync),
        .vde(vga_vde),
        .di_start(1'b0),
        .di_header(24'b0),
        .di_sub0(56'b0),
        .di_sub1(56'b0),
        .di_sub2(56'b0),
        .di_sub3(56'b0),
        .di_active(),
        .ser_clk(tmds_clk_p),
        .ser_d0(tmds_d_p[0]),
        .ser_d1(tmds_d_p[1]),
        .ser_d2(tmds_d_p[2])
    );

    assign led_pin = btn1_pin ^ btn2_pin ^ uart0_txd ^ pll_lock;

endmodule
