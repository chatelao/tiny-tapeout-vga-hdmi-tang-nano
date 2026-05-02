# ROADMAP

## Current Goals
- [ ] Implement a custom Renode peripheral model for the TT APB bridge.
- [ ] Develop automated E2E tests for video signal integrity.
- [ ] Implement the TMDS clocking logic (PLL for 5x/10x serialization clock).
- [ ] Implement the OSER10-based serializer for Gowin GW1NSR-4C.
- [ ] Integrate components into a top-level `hdmi_tx` module.

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
