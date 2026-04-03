# Project Goal
- Create a VGA to HDMI for Tiny Tapeout designs running on a Tang Nano 4K.

# Default Architecture
- **HDMI-Output**: The video and audio output is deliverd to the HDMI adapter.
- **Tiny Tapeout PMOD interfaces**: The Verilog module take (binary) VGA and Audio as defined for the Tiny-Tapeout PMOD modules.

# Planning & Progress tracking
- Keep an up to date file `ROADMAP.md` with the next 5 steps and all past steps having checkboxes.

# Project structure
- `/` - Keep root directory clean with relevant `.md` files: `README.md`, `ROADMAP.md`, `SERIAL_PORT_ACCESS.md`
- `/definitions` - Datasheets and Standards to be used, download and convert to `.md` on first time read.
- `/examples` - Example data scripts
- `/examples/tt_projects` - Example Tiny-Tapeout VGA FPGA projects.
- `/test` - Unit, System and End-2-End test concepts and cases to be executed after each change. Use Renode to verify the binaries.
- `/src` - Source files, only accepted if working and covered by tests.
- `/.github/workflows` - For release tag publish the installer/binary.
- `README.md` - Update overview of the product.
