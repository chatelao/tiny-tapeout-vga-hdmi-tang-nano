# ROADMAP

## Current Goals
- [ ] Implement VGA to HDMI conversion logic in Verilog.
- [ ] Configure Renode to simulate the Tang Nano 4K and verify binaries (Correct peripherals implemented).
- [ ] Integrate an open-source HDMI transmitter core (e.g., from `nano4k_hdmi_tx`).
- [ ] Develop automated E2E tests for video signal integrity.
- [ ] Implement a custom Renode peripheral for the TT APB bridge.

## Completed
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
