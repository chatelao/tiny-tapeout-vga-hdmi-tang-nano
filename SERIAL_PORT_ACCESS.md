# Serial Port Access

This project utilizes the UART0 peripheral on the Cortex-M3 core of the Tang Nano 4K.

## Configuration
- **Baud Rate**: 115200
- **Data Bits**: 8
- **Stop Bits**: 1
- **Parity**: None

## Physical Pins
- **UART0 TX**: Pin 18 (FPGA `uart0_txd`)
- **UART0 RX**: Pin 19 (FPGA `uart0_rxd`)

## Interacting via Web UART
If using a web-based UART terminal:
1. Connect your Tang Nano 4K to the USB port.
2. Select the correct COM port in the terminal.
3. Configure the baud rate to 115200.
4. Characters typed in the terminal will be sent to the Tang Nano, processed by the M3 core, and echoed back.
