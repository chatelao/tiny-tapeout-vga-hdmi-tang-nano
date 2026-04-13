#!/bin/bash

echo "Verifying project structure according to GEMINI.md..."

# List of required directories
dirs=("definitions" "examples/tt_projects" "src" "test")

for dir in "${dirs[@]}"; do
  if [ -d "$dir" ]; then
    echo "[OK] Directory $dir exists."
  else
    echo "[ERROR] Directory $dir is missing!"
    exit 1
  fi
done

# List of required root files
root_files=("README.md" "ROADMAP.md" "SERIAL_PORT_ACCESS.md" "GEMINI.md")

for file in "${root_files[@]}"; do
  if [ -f "$file" ]; then
    echo "[OK] Root file $file exists."
  else
    echo "[ERROR] Root file $file is missing!"
    exit 1
  fi
done

# List of essential source files
src_files=("src/main.c" "src/top.v" "src/top.cst" "src/Makefile" "src/UART_README.md")

for file in "${src_files[@]}"; do
  if [ -f "$file" ]; then
    echo "[OK] Source file $file exists."
  else
    echo "[ERROR] Source file $file is missing!"
    exit 1
  fi
done

# Check for technical debt cleanup (should NOT exist)
debt_files=("src/top.v.orig" "src/top.cst.orig" "src/gowin_empu/temp")

for file in "${debt_files[@]}"; do
  if [ -e "$file" ]; then
    echo "[ERROR] Technical debt file $file still exists!"
    exit 1
  else
    echo "[OK] Technical debt file $file is absent."
  fi
done

echo "Project structure verification complete!"
exit 0
