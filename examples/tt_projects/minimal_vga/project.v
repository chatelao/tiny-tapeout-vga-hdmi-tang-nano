/*
 * Copyright (c) 2024 Tiny Tapeout
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_minimal_vga(
  input  wire [7:0] ui_in,    // Dedicated inputs
  output wire [7:0] uo_out,   // Dedicated outputs
  input  wire [7:0] uio_in,   // IOs: Input path
  output wire [7:0] uio_out,  // IOs: Output path
  output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
  input  wire       ena,      // always 1 when the design is powered, so you can ignore it
  input  wire       clk,      // clock
  input  wire       rst_n     // reset_n - low to reset
);

  reg [9:0] h_count;
  reg [9:0] v_count;

  always @(posedge clk) begin
    if (!rst_n) begin
      h_count <= 0;
      v_count <= 0;
    end else begin
      if (h_count == 799) begin
        h_count <= 0;
        if (v_count == 524)
          v_count <= 0;
        else
          v_count <= v_count + 1;
      end else begin
        h_count <= h_count + 1;
      end
    end
  end

  wire hsync = ~(h_count >= 656 && h_count < 752);
  wire vsync = ~(v_count >= 490 && v_count < 492);
  wire video_active = (h_count < 640 && v_count < 480);

  // TinyVGA PMOD: {hsync, B0, G0, R0, vsync, B1, G1, R1}
  // Output a white screen when active
  assign uo_out = {hsync, video_active, video_active, video_active, vsync, video_active, video_active, video_active};

  assign uio_out = 0;
  assign uio_oe  = 0;

  wire _unused = &{ui_in, uio_in, ena};

endmodule
