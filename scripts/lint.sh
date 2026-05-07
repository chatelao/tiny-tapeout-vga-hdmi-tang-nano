#!/bin/bash

# Verilog Linting Script using Verilator

set -e

echo "Running Verilog linting..."

# Run Verilator linting
# - -lint-only: Perform linting without generating code
# - -Isrc: Include source directory for header files
# - src/top.v: Top-level source file
# - test/lint_stubs.v: Stubs for external/primitive modules
# - --top-module top: Specify the top-level module
# - -Wall: Enable all warnings (optional, adjust as needed)

echo "--- Linting WITH M3 (default) ---"
verilator --lint-only -Isrc src/top.v src/hdmi_ecc.v test/lint_stubs.v --top-module top

echo "--- Linting WITHOUT M3 ---"
verilator --lint-only -Isrc -DWITHOUT_M3 src/top.v src/hdmi_ecc.v test/lint_stubs.v --top-module top

echo "Verilog linting passed successfully!"
