# UART Echo Example

This example demonstrates how to use the UART0 peripheral on the Cortex-M3 "Hard Core" to communicate with a host computer. It receives characters from the host, swaps their case (upper to lower and vice versa), and echoes them back, while toggling the onboard LED for every character processed.

## 1. Features

- **UART0 Configuration**: 115200 baud, 8-bit data, 1 stop bit, no parity.
- **Case Conversion**: Automatically swaps uppercase 'A-Z' to lowercase 'a-z' and vice versa.
- **LED Feedback**: The onboard LED (Pin 10) toggles with each character received.
- **Hardware Integration**: Uses the `Gowin_EMPU_M3` hard core with UART0 routed to physical pins via the FPGA fabric.

## 2. Hardware Mapping

| Interface | Pin | FPGA Port |
| :--- | :--- | :--- |
| UART0 TX | 18 | `uart_tx` |
| UART0 RX | 19 | `uart_rx` |
| LED | 10 | `led_pin` |
| Clock | 45 | `clk_27m` |

## 3. Register Layout

The following registers are used for UART0 (Base `0x40004000`):

| Register | Offset | Description |
| :--- | :--- | :--- |
| `DATA` | `0x00` | Transmit/Receive data. |
| `STATE` | `0x04` | Status bits (Bit 1: RX full, Bit 0: TX full). |
| `CTRL` | `0x08` | Control bits (Bit 1: RX enable, Bit 0: TX enable). |
| `BAUDDIV` | `0x10` | Baud rate divider. |

## 4. Build Instructions

To build the example, run `make` in this directory:

```bash
make
```

This will produce:
- `firmware.bin`: The Cortex-M3 binary.
- `bitstream.fs`: The FPGA bitstream.
