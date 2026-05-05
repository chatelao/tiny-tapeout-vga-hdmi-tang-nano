/*
 * VGA and Audio Example for Tiny Tapeout
 *
 * This project generates a simple VGA pattern and a square wave audio signal.
 * The audio frequency changes automatically over time and can be further
 * offset using the dedicated inputs (ui_in).
 *
 * Copyright (c) 2024 Jules
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_vga_audio(
  input  wire [7:0] ui_in,    // Dedicated inputs
  output wire [7:0] uo_out,   // Dedicated outputs
  input  wire [7:0] uio_in,   // IOs: Input path
  output wire [7:0] uio_out,  // IOs: Output path
  output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
  input  wire       ena,      // always 1 when the design is powered, so you can ignore it
  input  wire       clk,      // clock
  input  wire       rst_n     // reset_n - low to reset
);

  // VGA counter logic
  reg [9:0] h_count;
  reg [9:0] v_count;

  always @(posedge clk or negedge rst_n) begin
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

  // VGA sync and active signals
  wire hsync = ~(h_count >= 656 && h_count < 752);
  wire vsync = ~(v_count >= 490 && v_count < 492);
  wire video_active = (h_count < 640 && v_count < 480);

  // Simple color pattern
  wire [1:0] R = video_active ? {h_count[7], h_count[6]} : 2'b00;
  wire [1:0] G = video_active ? {v_count[7], v_count[6]} : 2'b00;
  wire [1:0] B = video_active ? {h_count[8], v_count[8]} : 2'b00;

  // TinyVGA PMOD: {hsync, B0, G0, R0, vsync, B1, G1, R1}
  assign uo_out = {hsync, B[0], G[0], R[0], vsync, B[1], G[1], R[1]};

  // Automatic frequency sweep logic
  reg [7:0] sweep_counter;
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      sweep_counter <= 0;
    end else if (h_count == 0 && v_count == 0) begin
      sweep_counter <= sweep_counter + 1'b1;
    end
  end

  // Audio generation: Square wave
  reg [16:0] audio_counter;
  reg audio_out;
  // Use ui_in and sweep_counter to control frequency.
  wire [7:0] combined_freq = ui_in + sweep_counter;
  // Period is (combined_freq << 8) + 2048 cycles.
  wire [16:0] audio_period = {1'b0, combined_freq, 8'h00} + 17'h00800;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      audio_counter <= 0;
      audio_out <= 0;
    end else begin
      if (audio_counter >= audio_period) begin
        audio_counter <= 0;
        audio_out <= ~audio_out;
      end else begin
        audio_counter <= audio_counter + 1'b1;
      end
    end
  end

  // uio_out[7]: Audio signal
  // uio_out[0]: Video Data Enable (VDE) for HDMI compatibility
  assign uio_out = {audio_out, 6'b0, video_active};
  assign uio_oe  = 8'h81; // uio_out[7] and uio_out[0] as outputs

  // Suppress unused signals warning
  wire _unused = &{uio_in, ena};

endmodule
