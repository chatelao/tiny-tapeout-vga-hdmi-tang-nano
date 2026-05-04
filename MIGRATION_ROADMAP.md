# MIGRATION ROADMAP

This document breaks down the high-level goals in `ROADMAP.md` into modest, feasible, and verifiable steps.

## VGA to HDMI Integration
- [x] Implement the TMDS 8b10b encoder logic in `src/tmds_encoder.v`.
- [x] Assign physical pins for HDMI TMDS pairs in `src/top.cst`.
- [x] Create behavioral PLL model for simulation.
- [x] Implement Gowin `rPLL` hardware module for HDMI clock generation (Pixel/Serial clocks).
- [x] Verify PLL clock outputs and lock signal in simulation.
- [x] Implement a 10:1 serializer module using Gowin OSER10 primitives.
- [/] Map serializer outputs to differential pairs in the top-level design.
- [x] Integrate components into a top-level `hdmi_tx` module.
- [/] Connect `tt_um_vga_example` signals to the `hdmi_tx` core.
- [/] Verify HDMI output timing and encoding via Cocotb simulation.

## Renode Simulation
- [x] Correct Renode platform definition (`.repl`) to match CMSDK peripherals.
- [ ] Implement basic APB register logic in Renode Python model.
- [ ] Define the Python peripheral class for the Tiny Tapeout APB bridge in Renode.
- [ ] Implement register read/write logic in the Renode model matching `tt_wrapper.v`.
- [ ] Integrate a behavioral model of the TT design into the Renode peripheral.
- [ ] Create a Robot test script to verify M3-to-TT interaction in Renode.
- [ ] Integrate Renode verification into `run_tests.sh`.

## APB Expansion & Bridge
- [x] Expand `tt_wrapper.v` to support full 8-bit address decoding (preventing aliasing).
- [x] Document the TT APB register map in `README.md`.
- [x] Verify TT APB bridge (`tt_m3_wrapper`) via Cocotb simulation.
- [ ] Update `m3_regs.h` with additional TT control/status registers if needed.
- [ ] Implement firmware-based read-back verification for all TT registers.

## HDMI Audio & Data Island Packets
- [ ] Research and document HDMI ACR and InfoFrame byte layouts.
- [ ] Implement InfoFrame Checksum calculation logic.
- [ ] Implement AVI InfoFrame generator for 640x480p.
- [ ] Implement Audio Clock Regeneration (ACR) packet generator.
- [ ] Define Data Island Packet interface and basic arbiter.
- [ ] Implement scanline-based trigger logic for Data Island packets.
- [ ] Multiplex AVI InfoFrame and ACR packets in the scheduler.
- [ ] Design 1-bit PWM audio generator for 48kHz sampling.
- [x] Implement TERC4 encoder for HDMI Data Islands.
- [x] Research and document BCH ECC parity equations for HDMI packets.
- [x] Implement 24-bit Header ECC and 56-bit Subpacket ECC encoders.
- [x] Implement HDMI Data Island FSM (Preamble, Guard Bands, and Data timing).
- [x] Implement HDMI Data Island Framer (Multiplexing TERC4 and Packet Packer).
- [x] Integrate Data Island support into `hdmi_tx`.
- [ ] Implement HDMI Audio Sample packet generation.

## Automated E2E & Verification
- [ ] Develop a Cocotb test bench for the complete `top` module.
- [ ] Implement a "pixel-perfect" check in simulation to verify TT-to-HDMI path.
- [ ] Fix `gowin_pack` bitstream generation in the CI environment.
- [ ] Add a "smoke test" bitstream that can be loaded to hardware to verify HDMI link.
