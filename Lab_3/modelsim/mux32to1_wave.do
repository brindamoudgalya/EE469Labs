onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /mux32to1_testbench/clk
add wave -noupdate /mux32to1_testbench/sel
add wave -noupdate /mux32to1_testbench/in
add wave -noupdate /mux32to1_testbench/out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {9452022 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 80
configure wave -valuecolwidth 203
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
WaveRestoreZoom {0 ps} {655626605 ps}
