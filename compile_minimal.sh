#!/bin/bash

set -e

PROJECT_DIR="examples/tt_projects/minimal_vga"
TOP_MODULE="tt_um_minimal_vga"
DEVICE="GW1NSR-LV4CQN48PC7/I6"
FAMILY="GW1NS-4"

echo "Compiling $TOP_MODULE..."

# 1. Synthesis
echo "--- Running Synthesis ---"
yosys -p "synth_gowin -top $TOP_MODULE -json minimal_vga.json" "$PROJECT_DIR/project.v"

# 2. Place and Route
echo "--- Running Place and Route ---"
nextpnr-gowin --device "$DEVICE" --family "$FAMILY" --json minimal_vga.json --write minimal_vga_pnr.json

# 3. Bitstream Generation (if gowin_pack is available)
if command -v gowin_pack >/dev/null 2>&1; then
    echo "--- Generating Bitstream ---"
    # Note: gowin_pack usually needs the pnr output and sometimes nextpnr-himbaechel for full bitstream.
    # We attempt it as requested.
    gowin_pack -d "$FAMILY" -o minimal_vga.fs minimal_vga_pnr.json
    echo "Bitstream minimal_vga.fs generated."
else
    echo "--- skipping Bitstream Generation (gowin_pack not found) ---"
fi

# Cleanup
rm -f minimal_vga.json minimal_vga_pnr.json

echo "Compilation of $TOP_MODULE finished."
