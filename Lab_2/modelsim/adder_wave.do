onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /adder_testbench/clk
add wave -noupdate -radix decimal /adder_testbench/A
add wave -noupdate -radix decimal /adder_testbench/B
add wave -noupdate -radix decimal /adder_testbench/sum
add wave -noupdate /adder_testbench/zero
add wave -noupdate /adder_testbench/overflow
add wave -noupdate /adder_testbench/carry_out
add wave -noupdate /adder_testbench/negative
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 96
configure wave -valuecolwidth 82
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
WaveRestoreZoom {0 ps} {1025 ps}
