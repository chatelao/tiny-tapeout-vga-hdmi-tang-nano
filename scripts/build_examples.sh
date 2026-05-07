#!/bin/bash

# Do not set -e so we can continue on bitstream failure
# set -e

RELEASES_DIR="releases"
mkdir -p "$RELEASES_DIR"

# Options
WITHOUT_M3=${WITHOUT_M3:-1}

# Use the device that seems most compatible with the installed nextpnr-gowin
if [ "$WITHOUT_M3" -eq 1 ]; then
    # GW1NSR-4C (Tang Nano 4K) often has issues with rPLL in older nextpnr-gowin versions.
    # Using GW1N-4 as a compatible target for the FPGA fabric.
    DEVICE="GW1N-LV4QN48C6/I5"
    FAMILY="GW1N-4"
    SUFFIX="_without_m3"
else
    DEVICE="GW1NSR-LV4CQN48PC7/I6"
    FAMILY="GW1NS-4"
    SUFFIX=""
fi
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

    local out_name="${name}${SUFFIX}"

    echo "================================================================================"
    echo "Building example: $name (Target: ${out_name}.fs)"
    echo "Source: $dir"
    echo "Top Module: $top_mod"
    echo "================================================================================"

    # Collect all .v files in the example directory
    local example_sources=$(find "$dir" -maxdepth 1 -name "*.v")

    local all_sources="$HDMI_SOURCES $example_sources $extra_sources"

    # Synthesis
    local yosys_cmd=""
    local read_verilog_flags=""
    if [ "$WITHOUT_M3" -eq 1 ]; then
        read_verilog_flags="-DWITHOUT_M3"
    fi

    for src in $all_sources; do
        yosys_cmd+="read_verilog $read_verilog_flags $src; "
    done

    # Rename the user's top module to the expected name in top.v
    if [ "$top_mod" != "tt_um_vga_example" ]; then
        yosys_cmd+="rename $top_mod tt_um_vga_example; "
    fi
    yosys_cmd+="synth_gowin -top top -json $RELEASES_DIR/${out_name}.json"

    echo "--- Running Synthesis ---"
    if ! yosys -p "$yosys_cmd" > "$RELEASES_DIR/${out_name}_synth.log" 2>&1; then
        echo "Error: Synthesis failed for $name. Check $RELEASES_DIR/${out_name}_synth.log"
        return 1
    fi

    echo "--- Running Place and Route ---"
    if ! nextpnr-gowin --device "$DEVICE" --family "$FAMILY" --json "$RELEASES_DIR/${out_name}.json" --write "$RELEASES_DIR/${out_name}_pnr.json" --cst "$CST" > "$RELEASES_DIR/${out_name}_pnr.log" 2>&1; then
        echo "Warning: Place and Route failed for $name. Check $RELEASES_DIR/${out_name}_pnr.log"
    else
        echo "--- Running Bitstream Generation ---"
        if gowin_pack -d "$FAMILY" -o "$RELEASES_DIR/${out_name}.fs" "$RELEASES_DIR/${out_name}_pnr.json" > "$RELEASES_DIR/${out_name}_pack.log" 2>&1; then
            echo "Successfully generated $RELEASES_DIR/${out_name}.fs"
        else
            echo "Warning: Bitstream generation failed for $name. Check $RELEASES_DIR/${out_name}_pack.log"
        fi
    fi

    # Cleanup temporary json files but keep logs
    rm -f "$RELEASES_DIR/${out_name}.json" "$RELEASES_DIR/${out_name}_pnr.json"
}

# Dynamically find all projects
PROJECT_FILES=$(find examples/tt_projects -name "project.v" | sort)
COMMON_DIR="examples/tt_projects/vga-playground/common"

for PROJECT_FILE in $PROJECT_FILES; do
    PROJECT_DIR=$(dirname "$PROJECT_FILE")
    PROJECT_NAME=$(basename "$PROJECT_DIR")

    # Extract top module name: tt_um_*
    TOP_MODULE=$(grep -E "module[[:space:]]+tt_um_[^[:space:](]+" "$PROJECT_FILE" | sed -E 's/.*module[[:space:]]+(tt_um_[^[:space:](]+).*/\1/')

    if [ -z "$TOP_MODULE" ]; then
        echo "Could not find tt_um_* module in $PROJECT_FILE, skipping."
        continue
    fi

    EXTRA=""
    if [[ "$PROJECT_DIR" == *"vga-playground"* ]]; then
        # vga-playground projects might need common files
        # Check if they use gamepad
        if [[ "$PROJECT_NAME" == "gamepad" ]]; then
            EXTRA="$COMMON_DIR/gamepad_pmod.v"
        fi
        # Note: hvsync_generator.v is already in HDMI_SOURCES
    fi

    build_example "$PROJECT_NAME" "$PROJECT_DIR" "$TOP_MODULE" "$EXTRA"
done

echo "================================================================================"
echo "Build process finished. Check $RELEASES_DIR/ for outputs and logs."
echo "================================================================================"
