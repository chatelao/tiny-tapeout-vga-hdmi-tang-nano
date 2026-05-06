#!/bin/bash

# Do not set -e so we can continue on bitstream failure
# set -e

RELEASES_DIR="releases"
mkdir -p "$RELEASES_DIR"

# Use the device that seems most compatible with the installed nextpnr-gowin
DEVICE="GW1NSR-LV4CQN48PC7/I6"
FAMILY="GW1NS-4"
CST="src/top.cst"

# HDMI Source files (excluding M3 for better compatibility with open toolchain)
HDMI_SOURCES="src/top.v src/hdmi_clk_gen.v src/hdmi_tx.v src/tmds_encoder.v src/hdmi_serializer.v \
src/hdmi_data_island_framer.v src/hdmi_data_island_fsm.v src/hdmi_packet_packer.v \
src/hdmi_ecc.v src/terc4_encoder.v src/hdmi_data_island_scheduler.v \
src/hdmi_avi_infoframe.v src/hdmi_acr_packet.v src/hdmi_infoframe_checksum.v \
src/hvsync_generator.v test/stubs.v"

build_example() {
    local name=$1
    local dir=$2
    local top_mod=$3
    local extra_sources=$4

    echo "================================================================================"
    echo "Building example: $name"
    echo "Source: $dir"
    echo "================================================================================"

    # Collect all .v files in the example directory
    local example_sources=$(find "$dir" -maxdepth 1 -name "*.v")

    local all_sources="$HDMI_SOURCES $example_sources $extra_sources"

    # Synthesis
    local yosys_cmd=""
    for src in $all_sources; do
        yosys_cmd+="read_verilog $src; "
    done
    if [ "$top_mod" != "tt_um_vga_example" ]; then
        yosys_cmd+="rename $top_mod tt_um_vga_example; "
    fi
    yosys_cmd+="synth_gowin -top top -json $RELEASES_DIR/${name}.json"

    echo "--- Running Synthesis ---"
    if ! yosys -p "$yosys_cmd" > "$RELEASES_DIR/${name}_synth.log" 2>&1; then
        echo "Error: Synthesis failed for $name. Check $RELEASES_DIR/${name}_synth.log"
        return 1
    fi

    echo "--- Running Place and Route ---"
    if ! nextpnr-gowin --device "$DEVICE" --family "$FAMILY" --json "$RELEASES_DIR/${name}.json" --write "$RELEASES_DIR/${name}_pnr.json" --cst "$CST" > "$RELEASES_DIR/${name}_pnr.log" 2>&1; then
        echo "Warning: Place and Route failed for $name. Check $RELEASES_DIR/${name}_pnr.log"
        # We continue even if PnR fails as it might be due to rPLL/M3 issues mentioned in roadmap
    else
        echo "--- Running Bitstream Generation ---"
        if gowin_pack -d "$FAMILY" -o "$RELEASES_DIR/${name}.fs" "$RELEASES_DIR/${name}_pnr.json" > "$RELEASES_DIR/${name}_pack.log" 2>&1; then
            echo "Successfully generated $RELEASES_DIR/${name}.fs"
        else
            echo "Warning: Bitstream generation failed for $name. Check $RELEASES_DIR/${name}_pack.log"
        fi
    fi

    # Cleanup temporary json files but keep logs
    # rm -f "$RELEASES_DIR/${name}.json" "$RELEASES_DIR/${name}_pnr.json"
}

# 1. Minimal VGA
build_example "minimal_vga" "examples/tt_projects/minimal_vga" "tt_um_minimal_vga" ""

# 2. VGA Audio
build_example "vga_audio" "examples/tt_projects/vga_audio" "tt_um_vga_audio" ""

# 3. VGA Playground Examples
PLAYGROUND_DIR="examples/tt_projects/vga-playground"
COMMON_DIR="$PLAYGROUND_DIR/common"

for ex_dir in "$PLAYGROUND_DIR"/*/; do
    ex_name=$(basename "$ex_dir")
    if [ "$ex_name" == "common" ]; then
        continue
    fi

    extra=""
    if [ "$ex_name" == "gamepad" ]; then
        extra="$COMMON_DIR/gamepad_pmod.v"
    fi

    build_example "$ex_name" "$ex_dir" "tt_um_vga_example" "$extra"
done

echo "================================================================================"
echo "Build process finished. Check $RELEASES_DIR/ for outputs and logs."
echo "================================================================================"
