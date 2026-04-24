# Tang Nano 4K HDMI Pinout

The Tang Nano 4K (Gowin GW1NSR-LV4C) connects its HDMI/DVI port to the following FPGA pins:

| Signal | Pin (P) | Pin (N) |
|--------|---------|---------|
| TMDS D0| 30      | 29      |
| TMDS D1| 32      | 31      |
| TMDS D2| 35      | 34      |
| TMDS CLK| 28     | 27      |

- **IO Type**: LVCMOS33 (Driven as Differential via Gowin OSER10 blocks).
- **Termination**: External pull-ups/pull-downs are typically handled by the HDMI connector/monitor.

*Source: Derived from Sipeed Tang Nano 4K official examples.*
