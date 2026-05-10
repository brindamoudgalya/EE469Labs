# Create work library
vlib work

# Compile Verilog
#     All Verilog files that are part of this design should have
#     their own "vlog" line below.
vlog "../src/alu_control.sv"
vlog "../src/ALU.sv"
vlog "../src/alustim.sv"
vlog "../src/branch_logic.sv"
vlog "../src/cpu.sv"
vlog "../src/D_FF.sv"
vlog "../src/datamem.sv"
vlog "../src/decoders.sv"
vlog "../src/flag_reg.sv"
vlog "../src/instructmem.sv"
vlog "../src/main_control.sv"
vlog "../src/math.sv"
vlog "../src/multiplexers.sv"
vlog "../src/pc_reg.sv"
vlog "../src/regfile.sv"
vlog "../src/regstim.sv"
vlog "../src/sign_extend.sv"


# Call vsim to invoke simulator
#     Make sure the last item on the line is the name of the
#     testbench module you want to execute.
vsim -voptargs="+acc" -t 1ps -lib work cpu_testbench

# Source the wave do file
#     This should be the file that sets up the signal window for
#     the module you are testing.
do cpu_wave.do

# Set the window types
view wave
view structure
view signals

# Run the simulation
run -all

# End
