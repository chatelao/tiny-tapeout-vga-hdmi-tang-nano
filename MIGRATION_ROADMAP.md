# MIGRATION ROADMAP

This document breaks down the high-level goals in `ROADMAP.md` into modest, feasible, and verifiable steps.

## VGA to HDMI Integration
- [ ] Implement/Verify a basic DVI/TMDS encoder in Verilog.
- [ ] Integrate `nano4k_hdmi_tx` core into the top-level design.
- [ ] Connect VGA signals from the Tiny Tapeout module to the HDMI transmitter.
- [ ] Verify HDMI output timing (e.g., 720x480@60Hz) via Cocotb simulation.
- [ ] Assign physical pins for HDMI TMDS pairs in `top.cst`.

## Renode Simulation
- [x] Correct Renode platform definition (`.repl`) to match CMSDK peripherals.
- [ ] Implement a custom Renode peripheral model (in C# or Python) for the TT APB bridge.
- [ ] Create a Renode `.robot` test script to verify UART echo firmware.
- [ ] Extend Renode simulation to verify TT module interaction via APB registers.
- [ ] Integrate Renode verification into `run_tests.sh`.

## APB Expansion & Bridge
- [x] Expand `tt_wrapper.v` to support full 8-bit address decoding (preventing aliasing).
- [ ] Update `m3_regs.h` with additional TT control/status registers if needed.
- [ ] Implement firmware-based read-back verification for all TT registers.
- [ ] Document the TT APB register map in `README.md`.

## Automated E2E & Verification
- [ ] Develop a Cocotb test bench for the complete `top` module.
- [ ] Implement a "pixel-perfect" check in simulation to verify TT-to-HDMI path.
- [ ] Fix `gowin_pack` bitstream generation in the CI environment.
- [ ] Add a "smoke test" bitstream that can be loaded to hardware to verify HDMI link.
