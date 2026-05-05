# VGA and Audio Example

This example demonstrates generating both VGA video and square wave audio on a Tiny Tapeout chip.

## Features

- **640x480 VGA Output**: Generates standard VGA timing signals and a simple color bar pattern.
- **Controlled Audio**: Generates a square wave audio signal. The frequency of the signal is adjustable using the `ui_in` inputs.
- **HDMI Compatibility**: Includes a Video Data Enable (VDE) signal on `uio_out[0]`, making it compatible with the project's HDMI transmitter integration.

## Pinout

### Outputs (`uo_out`) - TinyVGA PMOD
- `uo_out[7]`: HSync
- `uo_out[6]`: Blue 0
- `uo_out[5]`: Green 0
- `uo_out[4]`: Red 0
- `uo_out[3]`: VSync
- `uo_out[2]`: Blue 1
- `uo_out[1]`: Green 1
- `uo_out[0]`: Red 1

### Bidirectional IOs (`uio_out`)
- `uio_out[7]`: Audio Square Wave
- `uio_out[0]`: Video Data Enable (VDE)

### Inputs (`ui_in`)
- `ui_in[7:0]`: Controls the audio frequency (period is proportional to the input value).
