# VGA to HDMI for Tiny Tapeout on Tang Nano 4K

This project aims to provide a bridge between Tiny Tapeout designs (using the VGA PMOD interface) and modern HDMI displays using the Tang Nano 4K FPGA board.

## Current Project Status
This repository is currently in its **initialization phase**. The code provides a foundational UART echo implementation running on the Cortex-M3 core of the Tang Nano 4K. This serves as a starting point for building more complex I/O interfaces, such as VGA input and HDMI output.

- **Completed**: Project structure, base UART code integration, pin assignment synchronization.
- **In Progress**: Defining VGA to HDMI conversion logic, preparing Tiny Tapeout project integration.

## Project Structure
- `/src`: Foundational FPGA and firmware source code (currently a UART echo base).
- `/definitions`: Datasheets and standard specifications.
- `/examples`: Tiny Tapeout project examples.
- `/test`: Unit and system tests.
- `ROADMAP.md`: Project progress and upcoming milestones.
- `SERIAL_PORT_ACCESS.md`: Instructions for interacting with the on-board UART.

## Getting Started
The base of this project is a UART echo implementation for the Cortex-M3 core on the Tang Nano 4K.
See `src/UART_README.md` for more details on the original base project.
See `SERIAL_PORT_ACCESS.md` for how to connect to the UART.
