onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /reg64_testbench/clk
add wave -noupdate /reg64_testbench/reset
add wave -noupdate -radix hexadecimal /reg64_testbench/enable
add wave -noupdate -radix hexadecimal /reg64_testbench/in
add wave -noupdate -radix hexadecimal /reg64_testbench/out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 81
configure wave -valuecolwidth 118
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
WaveRestoreZoom {647499050 ps} {647500114 ps}
