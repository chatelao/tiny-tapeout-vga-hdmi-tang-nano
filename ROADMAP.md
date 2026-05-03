# ROADMAP

## Current Goals
- [ ] Define a basic Renode peripheral model for the TT APB bridge.
- [ ] Verify APB bridge in Renode with UART echo firmware.
- [x] Create behavioral PLL model for simulation.
- [x] Implement Gowin `rPLL` hardware module.
- [ ] Implement a 10:1 serializer module using Gowin OSER10 primitives.

## Completed
- [x] Implement the TMDS 8b10b encoder logic in `src/tmds_encoder.v`.
- [x] Assign physical pins for HDMI TMDS pairs in `src/top.cst`.
- [x] Expand the APB expansion logic to support full 8-bit TT address space.
- [x] Integrate `tt_um_vga_example` into the top-level design.
- [x] Develop automated synthesis tests for the VGA project in CI.
- [x] Compile smallest TT VGA project in CI.
- [x] Compile all TT VGA projects in CI.
- [x] Initial exploration and base project selection.
- [x] Project Initialization: Set up repository structure and foundational UART project.
- [x] Technical debt cleanup and UART pin synchronization.
- [x] Toolchain installer (`install.sh`) and Cocotb test suite integration (`run_tests.sh`).
- [x] Implement GitHub Actions for automated testing.
- [x] Update project structure and documentation according to GEMINI.md.
- [x] Add VGA Playground examples to `examples/tt_projects`.
- [x] Initialize Renode infrastructure placeholder.
- [x] Fix test suite environment and synthesis scripts.
- [x] Configure Renode to simulate the Tang Nano 4K and verify binaries (Correct peripherals implemented).
