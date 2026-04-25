# VGA Playground Examples

This directory contains example Verilog projects from the [VGA Playground](https://vga-playground.com/).

VGA Playground is an online tool created by Uri Shaked that allows you to write and run Verilog code to generate VGA signals in the browser.

## Contents

- `common/`: Shared modules used by the presets.
  - `hvsync_generator.v`: Standard VGA sync generator.
  - `gamepad_pmod.v`: Driver for the Tiny Tapeout Gamepad PMOD (used by `gamepad` preset).
- `stripes/`: Simple moving stripes pattern.
- `music/`: Visualizer-style preset with audio generation.
- `rings/`: Concentric rings pattern.
- `logo/`: Tiny Tapeout logo display. Includes `bitmap_rom.v` and `palette.v`.
- `conway/`: Conway's Game of Life.
- `checkers/`: Checkerboard pattern.
- `drop/`: Animated drop effect.
- `gamepad/`: Gamepad input visualization. Requires `common/gamepad_pmod.v`.

## Usage

These projects follow the Tiny Tapeout module interface. They have been slightly modified for compatibility with local toolchains like Icarus Verilog (e.g., removing trailing semicolons from macro definitions).

The VGA signals are mapped to `uo_out` as follows:
- `uo_out[7]`: HSync
- `uo_out[6]`: Blue 0
- `uo_out[5]`: Green 0
- `uo_out[4]`: Red 0
- `uo_out[3]`: VSync
- `uo_out[2]`: Blue 1
- `uo_out[1]`: Green 1
- `uo_out[0]`: Red 1

## Credits

These examples were originally developed for [Tiny Tapeout VGA Playground](https://github.com/TinyTapeout/vga-playground) by Uri Shaked and other contributors. All files are licensed under Apache-2.0 or as specified in their respective headers.
