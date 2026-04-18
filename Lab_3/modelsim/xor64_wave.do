onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /xor64_testbench/clk
add wave -noupdate /xor64_testbench/A
add wave -noupdate /xor64_testbench/B
add wave -noupdate /xor64_testbench/out
add wave -noupdate /xor64_testbench/zero
add wave -noupdate /xor64_testbench/negative
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {161 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 95
configure wave -valuecolwidth 397
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
WaveRestoreZoom {0 ps} {718 ps}
