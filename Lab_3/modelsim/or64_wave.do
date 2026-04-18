onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /or64_testbench/clk
add wave -noupdate /or64_testbench/A
add wave -noupdate /or64_testbench/B
add wave -noupdate /or64_testbench/out
add wave -noupdate /or64_testbench/zero
add wave -noupdate /or64_testbench/negative
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {119 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 83
configure wave -valuecolwidth 391
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
WaveRestoreZoom {0 ps} {735 ps}
