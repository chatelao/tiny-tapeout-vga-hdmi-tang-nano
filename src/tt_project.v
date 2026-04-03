/*
 * Minimal Tiny Tapeout Echo Project
 *
 * This design simply echoes the input byte (ui_in) to the output byte (uo_out).
 */

`default_nettype none

module tt_um_minimal_echo (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    // Assign inputs directly to outputs
    assign uo_out  = ui_in;

    // Set UIO to output and show b'10101100
    assign uio_out = 8'b10101100;
    assign uio_oe  = 8'b11111111;

endmodule
