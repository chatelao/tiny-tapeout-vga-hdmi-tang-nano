#!/bin/bash

DEVICE="GW1NSR-LV4CQN48PC7/I6"
FAMILY="GW1NS-4"
COMMON_DIR="examples/tt_projects/vga-playground/common"
BITSTREAM_DIR="bitstreams"

mkdir -p "$BITSTREAM_DIR"

# Find all project.v files
PROJECT_FILES=$(find examples/tt_projects -name "project.v" | sort)

FAILED_SYNTH=""
FAILED_PNR=""
PASSED=""

for PROJECT_FILE in $PROJECT_FILES; do
    PROJECT_DIR=$(dirname "$PROJECT_FILE")
    PROJECT_NAME=$(basename "$PROJECT_DIR")
    echo "Processing project $PROJECT_NAME in $PROJECT_DIR..."

    # Extract top module name
    TOP_MODULE=$(grep -E "module[[:space:]]+tt_um_[^[:space:](]+" "$PROJECT_FILE" | sed -E 's/.*module[[:space:]]+(tt_um_[^[:space:](]+).*/\1/')

    if [ -z "$TOP_MODULE" ]; then
        echo "Could not find tt_um_* module in $PROJECT_FILE, skipping."
        continue
    fi

    # Collect source files
    SOURCES="$PROJECT_FILE"
    OTHER_V=$(find "$PROJECT_DIR" -name "*.v" ! -name "project.v")
    SOURCES="$SOURCES $OTHER_V"

    if [[ "$PROJECT_DIR" == *"vga-playground"* ]]; then
        SOURCES="$SOURCES $(ls $COMMON_DIR/*.v)"
    fi

    # 1. Synthesis
    echo "--- Running Synthesis for $PROJECT_NAME ($TOP_MODULE) ---"
    if ! yosys -q -p "synth_gowin -top $TOP_MODULE -json ${PROJECT_NAME}.json" $SOURCES > "${PROJECT_NAME}_synth.log" 2>&1; then
        echo "Synthesis FAILED for $PROJECT_NAME. Check ${PROJECT_NAME}_synth.log"
        FAILED_SYNTH="$FAILED_SYNTH $PROJECT_NAME"
        continue
    fi

    # 2. Place and Route
    # Some projects are known to be too large for the Tang Nano 4K (GW1NSR-4C)
    if [[ "$PROJECT_NAME" == "checkers" || "$PROJECT_NAME" == "conway" ]]; then
        echo "--- Skipping Place and Route for $PROJECT_NAME (known to exceed GW1NSR-4C resources) ---"
        rm -f "${PROJECT_NAME}.json"
        rm -f "${PROJECT_NAME}_synth.log"
        PASSED="$PASSED $PROJECT_NAME(synth-only)"
        continue
    fi

    echo "--- Running Place and Route for $PROJECT_NAME ($TOP_MODULE) ---"
    if ! nextpnr-gowin -q --device "$DEVICE" --family "$FAMILY" --json "${PROJECT_NAME}.json" --write "${PROJECT_NAME}_pnr.json" > "${PROJECT_NAME}_pnr.log" 2>&1; then
        echo "Place and Route FAILED for $PROJECT_NAME. Check ${PROJECT_NAME}_pnr.log"
        FAILED_PNR="$FAILED_PNR $PROJECT_NAME"
        rm -f "${PROJECT_NAME}.json"
        continue
    fi

    # 3. Bitstream Generation
    echo "--- Running Bitstream Generation for $PROJECT_NAME ---"
    # Bitstream generation is attempted but might fail due to open-source toolchain limitations with certain auto-assignments
    # We use --allow_pinless_io to increase chances of success
    if gowin_pack -d "$FAMILY" -o "${BITSTREAM_DIR}/${PROJECT_NAME}.fs" "${PROJECT_NAME}_pnr.json" --allow_pinless_io > "${PROJECT_NAME}_pack.log" 2>&1; then
        echo "Bitstream generation successful for $PROJECT_NAME."
        PASSED="$PASSED $PROJECT_NAME"
    else
        echo "Warning: Bitstream generation failed for $PROJECT_NAME (known toolchain issue). Keeping synth/PnR."
        PASSED="$PASSED $PROJECT_NAME(no-fs)"
    fi

    # Cleanup
    rm -f "${PROJECT_NAME}.json" "${PROJECT_NAME}_pnr.json"
    rm -f "${PROJECT_NAME}_synth.log" "${PROJECT_NAME}_pnr.log" "${PROJECT_NAME}_pack.log"

    echo "Compilation of $PROJECT_NAME finished."
    echo "------------------------------------------"
done

echo "=========================================="
echo "Summary:"
echo "Passed: $PASSED"
if [ -n "$FAILED_SYNTH" ]; then echo "Failed Synthesis: $FAILED_SYNTH"; fi
if [ -n "$FAILED_PNR" ]; then echo "Failed P&R: $FAILED_PNR"; fi
echo "=========================================="

if [ -n "$FAILED_SYNTH" ] || [ -n "$FAILED_PNR" ]; then
    exit 1
fi

exit 0
