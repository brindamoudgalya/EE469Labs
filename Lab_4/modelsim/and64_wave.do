onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /and64_testbench/clk
add wave -noupdate -radix binary /and64_testbench/A
add wave -noupdate -radix binary /and64_testbench/B
add wave -noupdate -radix binary /and64_testbench/out
add wave -noupdate -radix binary /and64_testbench/zero
add wave -noupdate -radix binary /and64_testbench/negative
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 86
configure wave -valuecolwidth 390
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
WaveRestoreZoom {0 ps} {782 ps}
