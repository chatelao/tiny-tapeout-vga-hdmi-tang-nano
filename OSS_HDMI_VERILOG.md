# Open Source Verilog HDMI Implementations for Tang Nano 4K

This document lists open-source Verilog implementations for HDMI output on the Sipeed Tang Nano 4K (Gowin GW1NSR-4C).

## 1. Sipeed Tang Nano 4K Official Examples
- **Repository**: [sipeed/TangNano-4K-example](https://github.com/sipeed/TangNano-4K-example)
- **Description**: The official example repository from Sipeed. It contains several HDMI-related projects:
    - `camera_hdmi`: Demonstrates driving an OV2640 camera and outputting the video to HDMI.
    - `hdmi_720p`: A 720p HDMI frame demo based on [SimpleVOut (SVO)](https://github.com/cliffordwolf/SimpleVOut).
    - `hdmi_2k_no_video`: A demo showing 2K output (detected by monitor but no video content).

## 2. nano4k_hdmi_tx
- **Repository**: [verilog-indeed/nano4k_hdmi_tx](https://github.com/verilog-indeed/nano4k_hdmi_tx)
- **Description**: A dedicated open-source HDMI/DVI transmitter for the Tang Nano 4K.
- **Features**:
    - Defaults to 720x480@60Hz resolution with 24-bit color.
    - Transmits a forwards-compatible DVI signal.
    - RTL written in Verilog utilizing Gowin's OSER10 blocks.
    - Includes demonstrations: PAL bar test, Bouncy box, and SRAM Framebuffer.
