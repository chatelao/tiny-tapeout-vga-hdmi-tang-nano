# VGA to HDMI for Tiny Tapeout on Tang Nano 4K

This project provides a hardware bridge to display Tiny Tapeout (TT) VGA designs on modern HDMI monitors using the Sipeed Tang Nano 4K FPGA board.

## Goals
- **HDMI-Output**: High-quality digital video and audio output.
- **TT PMOD Support**: Compatibility with Tiny Tapeout VGA and Audio PMOD specifications.
- **Verification**: Robust testing using Cocotb for RTL and Renode for firmware/system verification.

## Architecture
- **Tang Nano 4K**: Powered by the Gowin GW1NSR-LV4C, featuring a Cortex-M3 hard core and FPGA fabric.
- **Tiny Tapeout Wrapper**: An APB-to-TT bridge allowing the Cortex-M3 to interact with TT designs.
- **VGA to HDMI**: RTL logic to convert 2-bit (or 6-bit) VGA signals to TMDS signals for HDMI.

## Project Structure
- `/src`: Verilog source and C firmware.
- `/definitions`: Hardware specifications and pinout documentation.
- `/examples`: Example TT projects and data scripts.
- `/test`: Test suite including Cocotb and Renode configurations.
- `ROADMAP.md`: Tracking progress and future milestones.

## Tiny Tapeout APB Register Map
The Cortex-M3 interacts with the Tiny Tapeout module via an APB bridge located at base address `0x40002400`.

| Offset | Name     | Access | Description |
|--------|----------|--------|-------------|
| 0x00   | DATA     | R/W    | Write: `ui_in`, Read: `uo_out` |
| 0x04   | UIO_DATA | R/W    | Write: `uio_in`, Read: `uio_out` |
| 0x08   | UIO_OE   | R      | Read: `uio_oe` |
| 0x0C   | CTRL     | R/W    | [0]=clk, [1]=rst_n (Active Low), [2]=ena |

## Getting Started
Run `bash install.sh` to set up the toolchain.
Run `bash run_tests.sh` to execute the verification suite.
