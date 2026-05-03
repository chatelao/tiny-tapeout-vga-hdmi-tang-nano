/*
 * HDMI Clock Generator for Tang Nano 4K (GW1NSR-LV4C)
 *
 * Generates:
 *  - Serial Clock (x10): 252 MHz
 *  - Pixel Clock (x1): 25.2 MHz
 * From:
 *  - Input Clock: 27 MHz
 *
 * Parameters for 640x480 @ 60Hz:
 *  - FCLKIN: 27 MHz
 *  - IDIV_SEL: 2 (IDIV = 3)
 *  - FBDIV_SEL: 27 (FBDIV = 28)
 *  - ODIV_SEL: 4 (ODIV = 4) -- Note: ODIV is often required for VCO stability
 *  - CLKOUTD_SEL: 10 (Divider for CLKOUTD)
 */

`default_nettype none

module hdmi_clk_gen (
    input  wire clk_in,    // 27 MHz
    input  wire reset,     // Active high reset
    output wire clk_pixel, // 25.2 MHz
    output wire clk_x10,   // 252 MHz
    output wire lock       // PLL lock signal
);

    wire clkout_internal;

    rPLL #(
        .FCLKIN("27"),
        .DEVICE("GW1NSR-4C"),
        .IDIV_SEL(2),       // IDIV = 3
        .FBDIV_SEL(55),      // FBDIV = 56
        .ODIV_SEL(2),        // ODIV = 2
        .PSDA_SEL("0000"),
        .DUTYDA_SEL("1000"),
        .CLKOUTD_SRC("CLKOUT"),
        .DYN_SDIV_SEL(10)     // SDIV = 10
    ) pll_inst (
        .CLKIN(clk_in),
        .CLKOUT(clkout_internal),
        .CLKOUTD(clk_pixel),
        .LOCK(lock),
        .RESET(reset),
        .RESET_P(1'b0),
        .CLKFB(1'b0),
        .FBDSEL(6'b0),
        .IDSEL(6'b0),
        .ODSEL(6'b0),
        .DUTYDA(4'b0),
        .FDLY(4'b0)
    );

    assign clk_x10 = clkout_internal;

endmodule
