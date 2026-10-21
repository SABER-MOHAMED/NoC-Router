#!/usr/bin/env bash
set -e

# Change to repository root
cd "$(dirname "$0")/.."

# Ensure waveform directory exists
mkdir -p sim/waves

echo "==> Compiling router unit testbench with iverilog..."
iverilog -g2012 -o sim/router_sim \
    rtl/noc_pkg.sv \
    rtl/routing_xy.sv \
    rtl/router.sv \
    tb/router_tb.sv

echo "==> Running simulation with vvp..."
vvp sim/router_sim


echo "==> Waveforms generated at: sim/waves/router.vcd"
# echo "==> To view waveforms, run: gtkwave sim/waves/router.vcd"
gtkwave sim/waves/router.vcd