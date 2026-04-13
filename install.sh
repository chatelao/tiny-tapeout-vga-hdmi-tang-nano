#!/bin/bash

set -e

echo "Installing Toolchain for VGA-to-HDMI Project..."

# Update package list
sudo apt-get update

# Install FPGA Tools
echo "Installing FPGA Tools (Yosys, Nextpnr-Gowin, Iverilog)..."
sudo apt-get install -y yosys nextpnr-gowin iverilog

# Install ARM Cross-Compiler
echo "Installing ARM Cross-Compiler..."
sudo apt-get install -y gcc-arm-none-eabi binutils-arm-none-eabi libnewlib-arm-none-eabi

# Install Python Tools (Cocotb, Apycula)
echo "Installing Python Tools (Cocotb, Apycula)..."
pip3 install --upgrade pip
pip3 install cocotb cocotb-test apycula

echo "Toolchain installation complete!"
