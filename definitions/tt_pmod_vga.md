# Tiny Tapeout VGA PMOD Specification (Draft)

**Status**: To be verified with official Tiny Tapeout documentation.

Based on common Tiny Tapeout community projects, the VGA PMOD typically uses the `uo_out` port with the following mapping:

| Bit | Signal | Description |
|-----|--------|-------------|
| 7   | VSync  | Vertical Sync |
| 6   | B1     | Blue (MSB) |
| 5   | B0     | Blue (LSB) |
| 4   | G1     | Green (MSB) |
| 3   | HSync  | Horizontal Sync |
| 2   | G0     | Green (LSB) |
| 1   | R1     | Red (MSB) |
| 0   | R0     | Red (LSB) |

Note: Some versions might use a different mapping or 6-bit R2G2B2.
