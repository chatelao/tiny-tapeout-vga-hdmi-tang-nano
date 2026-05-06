# Example Bitstreams

This directory is intended to hold the generated bitstreams for the Tang Nano 4K.

## Current Status

The bitstreams are currently not included in the repository due to limitations in the open-source toolchain (nextpnr-gowin) regarding `rPLL` and `Gowin_EMPU_Top` primitives on the `GW1NSR-4C` device.

You can attempt to build them using the provided script:
\`\`\`bash
bash scripts/build_examples.sh
\`\`\`

The script will:
1. Synthesize the HDMI top-level wrapper with the chosen example.
2. Attempt Place and Route using \`nextpnr-gowin\`.
3. Attempt Bitstream generation using \`gowin_pack\`.

Logs and intermediate JSON files will be produced in this directory.
