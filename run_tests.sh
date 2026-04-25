#!/bin/bash

set -e

echo "Running all tests..."

# 1. Structural Tests
echo "--- Running Structural Verification ---"
bash test/test_structure.sh

# 2. Cocotb Tests
echo "--- Running Cocotb Simulation Tests ---"
cd test
make -f cocotb_Makefile
cd ..

# 3. Synthesis Tests
echo "--- Running Synthesis Test (Main Project) ---"
yosys -p "synth_gowin -top tt_um_vga_example -json tt_vga.json" src/tt_project.v src/hvsync_generator.v
nextpnr-gowin --device GW1NSR-LV4CQN48PC7/I6 --family GW1NS-4 --json tt_vga.json --write tt_vga_pnr.json
rm tt_vga.json tt_vga_pnr.json

echo "--- Running Synthesis Test (Minimal VGA Project) ---"
bash compile_minimal.sh

echo "All tests passed successfully!"
