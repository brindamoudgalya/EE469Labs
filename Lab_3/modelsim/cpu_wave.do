onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /cpu_testbench/clk
add wave -noupdate /cpu_testbench/reset
add wave -noupdate -radix hexadecimal /cpu_testbench/dut/pc
add wave -noupdate -radix hexadecimal /cpu_testbench/dut/instr
add wave -noupdate /cpu_testbench/dut/RegWrite
add wave -noupdate /cpu_testbench/dut/MemWrite
add wave -noupdate /cpu_testbench/dut/MemRead
add wave -noupdate /cpu_testbench/dut/BrToTake
add wave -noupdate /cpu_testbench/dut/WriteRegister
add wave -noupdate -radix decimal /cpu_testbench/dut/WriteData
add wave -noupdate -radix decimal /cpu_testbench/dut/alu_out
add wave -noupdate /cpu_testbench/dut/flag_neg
add wave -noupdate /cpu_testbench/dut/flag_zero
add wave -noupdate /cpu_testbench/dut/flag_overflow
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {767820 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 115
configure wave -valuecolwidth 103
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {627479 ps} {1218105 ps}
