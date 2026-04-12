# Create work library
vlib work

# Compile Verilog
#     All Verilog files that are part of this design should have
#     their own "vlog" line below.
vlog "../src/D_FF.sv"
vlog "../src/decoders.sv"
vlog "../src/multiplexers.sv"
vlog "../src/regfile.sv"
vlog "../src/regstim.sv"
vlog "../src/ALU.sv"
vlog "../src/alustim.sv"

# Call vsim to invoke simulator
#     Make sure the last item on the line is the name of the
#     testbench module you want to execute.
vsim -voptargs="+acc" -t 1ps -lib work alustim

# Source the wave do file
#     This should be the file that sets up the signal window for
#     the module you are testing.
do alustim_wave.do

# Set the window types
view wave
view structure
view signals

# Run the simulation
run -all

# End
