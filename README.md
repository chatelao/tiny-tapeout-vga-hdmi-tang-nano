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

## Getting Started
Run `bash install.sh` to set up the toolchain.
Run `bash run_tests.sh` to execute the verification suite.
