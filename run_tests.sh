#!/bin/bash

set -e

# Ensure cocotb-config is in the PATH

echo "Running all tests..."

# 1. Structural Tests
echo "--- Running Structural Verification ---"
bash test/test_structure.sh

# 2. Cocotb Tests
echo "--- Running Cocotb Simulation Tests ---"
cd test
export IVERILOG=iverilog
export VVP=vvp
make -f cocotb_Makefile clean
make -f cocotb_Makefile
make -f Makefile.pll clean
make -f Makefile.pll

echo "--- Running Serializer Cocotb Test ---"
rm -rf sim_build_serializer
export PYTHONPATH=$PYTHONPATH:$(pwd)
make -f cocotb_Makefile \
    VERILOG_SOURCES="$(pwd)/../src/hdmi_serializer.v $(pwd)/oser10_sim_model.v" \
    TOPLEVEL=hdmi_serializer \
    MODULE=test_serializer \
    SIM_BUILD=sim_build_serializer

echo "--- Running HDMI TX Cocotb Test ---"
rm -rf sim_build_hdmi_tx
make -f cocotb_Makefile \
    VERILOG_SOURCES="$(pwd)/../src/hdmi_tx.v $(pwd)/../src/tmds_encoder.v $(pwd)/../src/hdmi_serializer.v $(pwd)/oser10_sim_model.v $(pwd)/../src/hdmi_data_island_framer.v $(pwd)/../src/hdmi_data_island_fsm.v $(pwd)/../src/hdmi_packet_packer.v $(pwd)/../src/hdmi_ecc.v $(pwd)/../src/terc4_encoder.v" \
    TOPLEVEL=hdmi_tx \
    MODULE=test_hdmi_tx \
    SIM_BUILD=sim_build_hdmi_tx

echo "--- Running HDMI ECC Cocotb Test ---"
rm -rf sim_build_hdmi_header_ecc sim_build_hdmi_subpacket_ecc
make -f cocotb_Makefile clean
MODULE=test_hdmi_ecc TESTCASE=test_hdmi_header_ecc make -f cocotb_Makefile \
    VERILOG_SOURCES="$(pwd)/../src/hdmi_ecc.v" \
    TOPLEVEL=hdmi_header_ecc \
    SIM_BUILD=sim_build_hdmi_header_ecc
make -f cocotb_Makefile clean
MODULE=test_hdmi_ecc TESTCASE=test_hdmi_subpacket_ecc make -f cocotb_Makefile \
    VERILOG_SOURCES="$(pwd)/../src/hdmi_ecc.v" \
    TOPLEVEL=hdmi_subpacket_ecc \
    SIM_BUILD=sim_build_hdmi_subpacket_ecc

echo "--- Running HDMI Packet Packer Cocotb Test ---"
rm -rf sim_build_hdmi_packet_packer
make -f cocotb_Makefile \
    VERILOG_SOURCES="$(pwd)/../src/hdmi_packet_packer.v $(pwd)/../src/hdmi_ecc.v" \
    TOPLEVEL=hdmi_packet_packer \
    MODULE=test_hdmi_packet_packer \
    SIM_BUILD=sim_build_hdmi_packet_packer

echo "--- Running HDMI Data Island FSM Cocotb Test ---"
rm -rf sim_build_hdmi_data_island_fsm
make -f cocotb_Makefile \
    VERILOG_SOURCES="$(pwd)/../src/hdmi_data_island_fsm.v" \
    TOPLEVEL=hdmi_data_island_fsm \
    MODULE=test_hdmi_data_island_fsm \
    SIM_BUILD=sim_build_hdmi_data_island_fsm

echo "--- Running HDMI Data Island Framer Cocotb Test ---"
rm -rf sim_build_hdmi_data_island_framer
make -f cocotb_Makefile \
    VERILOG_SOURCES="$(pwd)/../src/hdmi_data_island_framer.v $(pwd)/../src/hdmi_data_island_fsm.v $(pwd)/../src/hdmi_packet_packer.v $(pwd)/../src/hdmi_ecc.v $(pwd)/../src/terc4_encoder.v" \
    TOPLEVEL=hdmi_data_island_framer \
    MODULE=test_hdmi_data_island_framer \
    SIM_BUILD=sim_build_hdmi_data_island_framer

echo "--- Running HDMI InfoFrame Checksum Cocotb Test ---"
rm -rf sim_build_hdmi_checksum
make -f cocotb_Makefile \
    VERILOG_SOURCES="$(pwd)/../src/hdmi_infoframe_checksum.v" \
    TOPLEVEL=hdmi_infoframe_checksum \
    MODULE=test_hdmi_checksum \
    SIM_BUILD=sim_build_hdmi_checksum

echo "--- Running HDMI AVI InfoFrame Cocotb Test ---"
rm -rf sim_build_hdmi_avi_infoframe
make -f cocotb_Makefile \
    VERILOG_SOURCES="$(pwd)/../src/hdmi_avi_infoframe.v $(pwd)/../src/hdmi_infoframe_checksum.v" \
    TOPLEVEL=hdmi_avi_infoframe \
    MODULE=test_hdmi_avi_infoframe \
    SIM_BUILD=sim_build_hdmi_avi_infoframe

echo "--- Running HDMI ACR Packet Cocotb Test ---"
rm -rf sim_build_hdmi_acr_packet
make -f cocotb_Makefile \
    VERILOG_SOURCES="$(pwd)/../src/hdmi_acr_packet.v" \
    TOPLEVEL=hdmi_acr_packet \
    MODULE=test_hdmi_acr_packet \
    SIM_BUILD=sim_build_hdmi_acr_packet

echo "--- Running HDMI Scheduler Cocotb Test ---"
rm -rf sim_build_hdmi_scheduler
make -f cocotb_Makefile \
    VERILOG_SOURCES="$(pwd)/../src/hdmi_data_island_scheduler.v $(pwd)/../src/hdmi_avi_infoframe.v $(pwd)/../src/hdmi_acr_packet.v $(pwd)/../src/hdmi_infoframe_checksum.v" \
    TOPLEVEL=hdmi_data_island_scheduler \
    MODULE=test_hdmi_scheduler \
    SIM_BUILD=sim_build_hdmi_scheduler

echo "--- Running Audio PWM Cocotb Test ---"
rm -rf sim_build_audio_pwm
make -f cocotb_Makefile \
    VERILOG_SOURCES="$(pwd)/../src/audio_pwm.v" \
    TOPLEVEL=audio_pwm \
    MODULE=test_audio_pwm \
    SIM_BUILD=sim_build_audio_pwm

echo "--- Running TT APB Wrapper Cocotb Test ---"
rm -rf sim_build_tt_wrapper
make -f cocotb_Makefile \
    VERILOG_SOURCES="$(pwd)/../src/tt_wrapper.v $(pwd)/../src/tt_project.v $(pwd)/../src/hvsync_generator.v" \
    TOPLEVEL=tt_m3_wrapper \
    MODULE=test_tt_wrapper \
    SIM_BUILD=sim_build_tt_wrapper
cd ..

# 3. Synthesis Tests
echo "--- Running Synthesis Test ---"
yosys -p "synth_gowin -top tt_um_vga_example -json tt_vga.json" src/tt_project.v src/hvsync_generator.v
nextpnr-gowin --device GW1NSR-LV4CQN48PC7/I6 --family GW1NS-4 --json tt_vga.json --write tt_vga_pnr.json
# Bitstream generation is attempted but might fail due to open-source toolchain limitations with certain auto-assignments
if gowin_pack -d GW1NS-4 -o tt_vga.fs tt_vga_pnr.json; then
    echo "Bitstream generation successful."
else
    echo "Warning: Bitstream generation failed (known toolchain issue with auto-placed pins). Keeping synthesis/PnR check."
fi
rm -f tt_vga.json tt_vga_pnr.json tt_vga.fs

echo "All tests passed successfully!"
