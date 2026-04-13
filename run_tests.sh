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

echo "All tests passed successfully!"
