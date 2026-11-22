@echo off
REM Synthesis for Lattice iCE40-HX8K: Yosys + nextpnr-ice40 (OSS CAD Suite)
for %%M in (spi_master spi_slave) do (
  yosys -p "synth_ice40 -top %%M -json %%M.json; stat" src\%%M.v > synth_%%M.log
  nextpnr-ice40 --hx8k --package ct256 --json %%M.json --freq 50 2> pnr_%%M.log
)
echo.
echo ===== Resources =====
findstr /C:"SB_LUT4" /C:"SB_DFF" /C:"SB_CARRY" /C:"Number of cells" synth_spi_master.log synth_spi_slave.log
echo.
echo ===== Fmax =====
findstr /C:"Max frequency" /C:"ICESTORM_LC:" pnr_spi_master.log pnr_spi_slave.log
