# HDMI Data Island Packet Layouts

This document describes the byte-level layouts for specific HDMI Data Island packets.

## 1. Auxiliary Video Information (AVI) InfoFrame
Used to inform the sink about the video format, color space, and aspect ratio.

- **Packet Type**: 0x82
- **Version**: 0x02
- **Length**: 13 bytes (0x0D)

### Header
- **HB0**: 0x82 (Packet Type)
- **HB1**: 0x02 (Version)
- **HB2**: 0x0D (Length)

### Data Bytes
- **DB1**: Checksum (8-bit sum of all header and data bytes must be 0 mod 256)
- **DB2**: [7:7] Reserved, [6:5] Y1Y0 (RGB/YUV), [4:4] A0 (Active Format Info), [3:2] B1B0 (Bar Info), [1:0] S1S0 (Scan Info)
- **DB3**: [7:6] C1C0 (Colorimetry), [5:4] M1M0 (Aspect Ratio), [3:0] R3R0 (Active Format Aspect Ratio)
- **DB4**: [7:7] ITC (IT Content), [6:4] EC2EC0 (Extended Colorimetry), [3:2] Q1Q0 (Quantization Range), [1:0] SC1SC0 (Non-uniform Picture Scaling)
- **DB5**: [7:0] VIC (Video Identification Code) - e.g., 1 for 640x480p
- **DB6**: [7:4] YQ1YQ0 (YCC Quantization Range), [3:2] CN1CN0 (Content Type), [1:0] PR3PR0 (Pixel Repetition Factor)
- **DB7-DB8**: Line number of End of Top Bar (16-bit, LSB first)
- **DB9-DB10**: Line number of Start of Bottom Bar (16-bit, LSB first)
- **DB11-DB12**: Pixel number of End of Left Bar (16-bit, LSB first)
- **DB13-DB14**: Pixel number of Start of Right Bar (16-bit, LSB first)

## 2. Audio Clock Regeneration (ACR) Packet
Used to synchronize the audio clock at the sink.

- **Packet Type**: 0x01
- **Version**: 0x00
- **Length**: 0x00 (Implicitly uses 4 subpackets)

### Header
- **HB0**: 0x01 (Packet Type)
- **HB1**: 0x00
- **HB2**: 0x00

### Subpacket Layout
All four subpackets (0-3) typically contain the same N and CTS values.

- **Byte 0**: Reserved (0x00)
- **Byte 1**: [7:4] Reserved, [3:0] CTS [19:16]
- **Byte 2**: [7:0] CTS [15:8]
- **Byte 3**: [7:0] CTS [7:0]
- **Byte 4**: [7:4] Reserved, [3:0] N [19:16]
- **Byte 5**: [7:0] N [15:8]
- **Byte 6**: [7:0] N [7:0]

The CTS (Cycle Time Stamp) and N values are used by the sink to regenerate the audio clock ($f_{audio} = f_{pixel} \times \frac{N}{CTS}$).
