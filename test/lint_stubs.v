/* Linting stubs for Gowin primitives and other external modules */

module rPLL #(
    parameter FCLKIN = "27",
    parameter DEVICE = "GW1NSR-4C",
    parameter IDIV_SEL = 0,
    parameter FBDIV_SEL = 0,
    parameter ODIV_SEL = 0,
    parameter PSDA_SEL = "0000",
    parameter DUTYDA_SEL = "1000",
    parameter CLKOUTD_SRC = "CLKOUT",
    parameter DYN_SDIV_SEL = 2
) (
    input  wire CLKIN,
    output wire CLKOUT,
    output wire CLKOUTD,
    output wire LOCK,
    input  wire RESET,
    input  wire RESET_P,
    input  wire CLKFB,
    input  wire [5:0] FBDSEL,
    input  wire [5:0] IDSEL,
    input  wire [5:0] ODSEL,
    input  wire [3:0] DUTYDA,
    input  wire [3:0] FDLY
);
    // Stub implementation
    assign CLKOUT = CLKIN;
    assign CLKOUTD = CLKIN;
    assign LOCK = 1'b1;
endmodule

module OSER10 (
    output wire Q,
    input  wire D0, D1, D2, D3, D4, D5, D6, D7, D8, D9,
    input  wire PCLK,
    input  wire FCLK,
    input  wire RESET
);
    // Stub implementation
    assign Q = D0;
endmodule

module tt_um_vga_example (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);
    // Stub implementation
    assign uo_out = 8'b0;
    assign uio_out = 8'b0;
    assign uio_oe = 8'b0;
endmodule

module Gowin_EMPU_Top (
    input sys_clk,
    inout [15:0] gpio,
    input uart0_rxd,
    output uart0_txd,
    input reset_n
);
    assign uart0_txd = 1'b1;
endmodule
