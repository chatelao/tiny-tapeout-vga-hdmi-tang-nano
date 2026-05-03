# Tang Nano 4K HDMI Pinout

The Tang Nano 4K (Gowin GW1NSR-LV4C) features an on-board HDMI connector. The following table maps the HDMI connector pins to the FPGA pins and describes their functions.

| HDMI Pin | Signal Name | FPGA Pin | Signal Type | IO Type |
| :--- | :--- | :--- | :--- | :--- |
| 1 | TMDS Data2+ | 35 | Differential Data 2+ | LVCMOS33D |
| 2 | TMDS Data2 Shield | GND | Shielding | - |
| 3 | TMDS Data2- | 34 | Differential Data 2- | LVCMOS33D |
| 4 | TMDS Data1+ | 32 | Differential Data 1+ | LVCMOS33D |
| 5 | TMDS Data1 Shield | GND | Shielding | - |
| 6 | TMDS Data1- | 31 | Differential Data 1- | LVCMOS33D |
| 7 | TMDS Data0+ | 30 | Differential Data 0+ | LVCMOS33D |
| 8 | TMDS Data0 Shield | GND | Shielding | - |
| 9 | TMDS Data0- | 29 | Differential Data 0- | LVCMOS33D |
| 10 | TMDS Clock+ | 28 | Differential Clock+ | LVCMOS33D |
| 11 | TMDS Clock Shield | GND | Shielding | - |
| 12 | TMDS Clock- | 27 | Differential Clock- | LVCMOS33D |
| 13 | CEC | NC / N/A | Consumer Electronics Control | - |
| 14 | Reserved | NC / N/A | Reserved (HDMI 1.4+ HEC) | - |
| 15 | SCL | NC / N/A | DDC Clock (I2C) | - |
| 16 | SDA | NC / N/A | DDC Data (I2C) | - |
| 17 | DDC/CEC GND | GND | Ground | - |
| 18 | +5V Power | +5V | 5V Power Supply | - |
| 19 | Hot Plug Detect | NC / N/A | HPD Signal | - |

## Notes
- **Differential Pairs**: TMDS signals are driven as differential pairs using Gowin's `OSER10` primitives in `LVCMOS33D` mode.
- **Auxiliary Signals**: Signals such as CEC, SCL, SDA, and HPD are not typically connected to the FPGA on the Tang Nano 4K's minimal HDMI implementation or are left as NC (No Connect) in most standard reference designs provided by Sipeed.
- **Termination**: Internal pull-ups/pull-downs are not required as termination is typically provided by the sink device (monitor).

*Source: Verified against Sipeed Tang Nano 4K `top.cst` and official hardware examples.*
