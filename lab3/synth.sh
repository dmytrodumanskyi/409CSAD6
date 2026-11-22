#!/usr/bin/env bash
# Synthesis + place&route + timing for Lattice iCE40-HX8K (CT256), 50 MHz target
# Requires OSS CAD Suite: source ~/oss-cad-suite/environment
set -e
mkdir -p build
for M in spi_master spi_slave; do
  echo "===== $M ====="
  yosys -q -l build/synth_$M.log -p "synth_ice40 -top $M -json build/$M.json; stat" src/$M.v
  nextpnr-ice40 --hx8k --package ct256 --json build/$M.json --freq 50 -l build/pnr_$M.log >/dev/null 2>&1
  echo "-- Yosys (cells):"
  grep -E "Number of cells|SB_LUT4|SB_DFF|SB_CARRY" build/synth_$M.log | tail -n 8
  echo "-- nextpnr (utilisation / Fmax):"
  grep -E "ICESTORM_LC:|Max frequency" build/pnr_$M.log | tail -n 3
done
