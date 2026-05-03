# MIGRATION ROADMAP

This document breaks down the high-level goals in `ROADMAP.md` into modest, feasible, and verifiable steps.

## VGA to HDMI Integration
- [x] Implement the TMDS 8b10b encoder logic in `src/tmds_encoder.v`.
- [x] Assign physical pins for HDMI TMDS pairs in `src/top.cst`.
- [x] Create behavioral PLL model for simulation.
- [x] Implement Gowin `rPLL` hardware module for HDMI clock generation (Pixel/Serial clocks).
- [x] Verify PLL clock outputs and lock signal in simulation.
- [ ] Implement a 10:1 serializer module using Gowin OSER10 primitives.
- [ ] Map serializer outputs to differential pairs in the top-level design.
- [ ] Integrate components into a top-level `hdmi_tx` module.
- [ ] Connect `tt_um_vga_example` signals to the `hdmi_tx` core.
- [ ] Verify HDMI output timing and encoding via Cocotb simulation.

## Renode Simulation
- [x] Correct Renode platform definition (`.repl`) to match CMSDK peripherals.
- [ ] Define a basic Renode peripheral model for the TT APB bridge.
- [ ] Verify APB bridge in Renode with UART echo firmware.
- [ ] Create a Renode `.robot` test script to verify UART echo firmware.
- [ ] Extend Renode simulation to verify TT module interaction via APB registers.
- [ ] Integrate Renode verification into `run_tests.sh`.

## APB Expansion & Bridge
- [x] Expand `tt_wrapper.v` to support full 8-bit address decoding (preventing aliasing).
- [x] Document the TT APB register map in `README.md`.
- [ ] Update `m3_regs.h` with additional TT control/status registers if needed.
- [ ] Implement firmware-based read-back verification for all TT registers.

## Automated E2E & Verification
- [ ] Develop a Cocotb test bench for the complete `top` module.
- [ ] Implement a "pixel-perfect" check in simulation to verify TT-to-HDMI path.
- [ ] Fix `gowin_pack` bitstream generation in the CI environment.
- [ ] Add a "smoke test" bitstream that can be loaded to hardware to verify HDMI link.
