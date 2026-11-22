@echo off
REM Simulation: Icarus Verilog + GTKWave (OSS CAD Suite)
iverilog -g2012 -o sim.vvp src\tb_spi.v src\spi_master.v src\spi_slave.v
if errorlevel 1 exit /b 1
vvp sim.vvp
start "" gtkwave tb_spi.vcd tb_spi.gtkw
