onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /cpu_pipelined_testbench/clk
add wave -noupdate /cpu_pipelined_testbench/reset
add wave -noupdate -expand -group IF -radix hexadecimal /cpu_pipelined_testbench/dut/if_pc
add wave -noupdate -expand -group IF -radix hexadecimal /cpu_pipelined_testbench/dut/if_instr
add wave -noupdate -expand -group ID -radix hexadecimal /cpu_pipelined_testbench/dut/id_pc
add wave -noupdate -expand -group ID -radix hexadecimal /cpu_pipelined_testbench/dut/id_instr
add wave -noupdate -expand -group ID -radix hexadecimal /cpu_pipelined_testbench/dut/id_ReadReg2
add wave -noupdate -expand -group ID -radix hexadecimal /cpu_pipelined_testbench/dut/id_WriteRegSel
add wave -noupdate -expand -group EX -radix hexadecimal /cpu_pipelined_testbench/dut/ex_pc
add wave -noupdate -expand -group EX -radix hexadecimal /cpu_pipelined_testbench/dut/forwardA
add wave -noupdate -expand -group EX -radix hexadecimal /cpu_pipelined_testbench/dut/forwardB
add wave -noupdate -expand -group EX -radix decimal /cpu_pipelined_testbench/dut/ex_alu_result
add wave -noupdate -expand -group EX -radix hexadecimal /cpu_pipelined_testbench/dut/TakeBranch
add wave -noupdate -expand -group MEM -radix hexadecimal /cpu_pipelined_testbench/dut/mem_ALU_result
add wave -noupdate -expand -group MEM -radix hexadecimal /cpu_pipelined_testbench/dut/mem_MemWrite
add wave -noupdate -expand -group MEM -radix hexadecimal /cpu_pipelined_testbench/dut/mem_MemRead
add wave -noupdate -expand -group WB -radix hexadecimal /cpu_pipelined_testbench/dut/wb_RegWrite
add wave -noupdate -expand -group WB -radix hexadecimal /cpu_pipelined_testbench/dut/wb_WriteReg
add wave -noupdate -expand -group WB -radix decimal /cpu_pipelined_testbench/dut/wb_WriteData
add wave -noupdate -radix decimal -childformat {{{/cpu_pipelined_testbench/dut/rf/regOut[31]} -radix decimal} {{/cpu_pipelined_testbench/dut/rf/regOut[30]} -radix decimal} {{/cpu_pipelined_testbench/dut/rf/regOut[29]} -radix decimal} {{/cpu_pipelined_testbench/dut/rf/regOut[28]} -radix decimal} {{/cpu_pipelined_testbench/dut/rf/regOut[27]} -radix decimal} {{/cpu_pipelined_testbench/dut/rf/regOut[26]} -radix decimal} {{/cpu_pipelined_testbench/dut/rf/regOut[25]} -radix decimal} {{/cpu_pipelined_testbench/dut/rf/regOut[24]} -radix decimal} {{/cpu_pipelined_testbench/dut/rf/regOut[23]} -radix decimal} {{/cpu_pipelined_testbench/dut/rf/regOut[22]} -radix decimal} {{/cpu_pipelined_testbench/dut/rf/regOut[21]} -radix decimal} {{/cpu_pipelined_testbench/dut/rf/regOut[20]} -radix decimal} {{/cpu_pipelined_testbench/dut/rf/regOut[19]} -radix decimal} {{/cpu_pipelined_testbench/dut/rf/regOut[18]} -radix decimal} {{/cpu_pipelined_testbench/dut/rf/regOut[17]} -radix decimal} {{/cpu_pipelined_testbench/dut/rf/regOut[16]} -radix decimal} {{/cpu_pipelined_testbench/dut/rf/regOut[15]} -radix decimal} {{/cpu_pipelined_testbench/dut/rf/regOut[14]} -radix decimal} {{/cpu_pipelined_testbench/dut/rf/regOut[13]} -radix decimal} {{/cpu_pipelined_testbench/dut/rf/regOut[12]} -radix decimal} {{/cpu_pipelined_testbench/dut/rf/regOut[11]} -radix decimal} {{/cpu_pipelined_testbench/dut/rf/regOut[10]} -radix decimal} {{/cpu_pipelined_testbench/dut/rf/regOut[9]} -radix decimal} {{/cpu_pipelined_testbench/dut/rf/regOut[8]} -radix decimal} {{/cpu_pipelined_testbench/dut/rf/regOut[7]} -radix decimal} {{/cpu_pipelined_testbench/dut/rf/regOut[6]} -radix decimal} {{/cpu_pipelined_testbench/dut/rf/regOut[5]} -radix decimal} {{/cpu_pipelined_testbench/dut/rf/regOut[4]} -radix decimal} {{/cpu_pipelined_testbench/dut/rf/regOut[3]} -radix decimal} {{/cpu_pipelined_testbench/dut/rf/regOut[2]} -radix decimal} {{/cpu_pipelined_testbench/dut/rf/regOut[1]} -radix decimal} {{/cpu_pipelined_testbench/dut/rf/regOut[0]} -radix decimal}} -expand -subitemconfig {{/cpu_pipelined_testbench/dut/rf/regOut[31]} {-height 15 -radix decimal} {/cpu_pipelined_testbench/dut/rf/regOut[30]} {-height 15 -radix decimal} {/cpu_pipelined_testbench/dut/rf/regOut[29]} {-height 15 -radix decimal} {/cpu_pipelined_testbench/dut/rf/regOut[28]} {-height 15 -radix decimal} {/cpu_pipelined_testbench/dut/rf/regOut[27]} {-height 15 -radix decimal} {/cpu_pipelined_testbench/dut/rf/regOut[26]} {-height 15 -radix decimal} {/cpu_pipelined_testbench/dut/rf/regOut[25]} {-height 15 -radix decimal} {/cpu_pipelined_testbench/dut/rf/regOut[24]} {-height 15 -radix decimal} {/cpu_pipelined_testbench/dut/rf/regOut[23]} {-height 15 -radix decimal} {/cpu_pipelined_testbench/dut/rf/regOut[22]} {-height 15 -radix decimal} {/cpu_pipelined_testbench/dut/rf/regOut[21]} {-height 15 -radix decimal} {/cpu_pipelined_testbench/dut/rf/regOut[20]} {-height 15 -radix decimal} {/cpu_pipelined_testbench/dut/rf/regOut[19]} {-height 15 -radix decimal} {/cpu_pipelined_testbench/dut/rf/regOut[18]} {-height 15 -radix decimal} {/cpu_pipelined_testbench/dut/rf/regOut[17]} {-height 15 -radix decimal} {/cpu_pipelined_testbench/dut/rf/regOut[16]} {-height 15 -radix decimal} {/cpu_pipelined_testbench/dut/rf/regOut[15]} {-height 15 -radix decimal} {/cpu_pipelined_testbench/dut/rf/regOut[14]} {-height 15 -radix decimal} {/cpu_pipelined_testbench/dut/rf/regOut[13]} {-height 15 -radix decimal} {/cpu_pipelined_testbench/dut/rf/regOut[12]} {-height 15 -radix decimal} {/cpu_pipelined_testbench/dut/rf/regOut[11]} {-height 15 -radix decimal} {/cpu_pipelined_testbench/dut/rf/regOut[10]} {-height 15 -radix decimal} {/cpu_pipelined_testbench/dut/rf/regOut[9]} {-height 15 -radix decimal} {/cpu_pipelined_testbench/dut/rf/regOut[8]} {-height 15 -radix decimal} {/cpu_pipelined_testbench/dut/rf/regOut[7]} {-height 15 -radix decimal} {/cpu_pipelined_testbench/dut/rf/regOut[6]} {-height 15 -radix decimal} {/cpu_pipelined_testbench/dut/rf/regOut[5]} {-height 15 -radix decimal} {/cpu_pipelined_testbench/dut/rf/regOut[4]} {-height 15 -radix decimal} {/cpu_pipelined_testbench/dut/rf/regOut[3]} {-height 15 -radix decimal} {/cpu_pipelined_testbench/dut/rf/regOut[2]} {-height 15 -radix decimal} {/cpu_pipelined_testbench/dut/rf/regOut[1]} {-height 15 -radix decimal} {/cpu_pipelined_testbench/dut/rf/regOut[0]} {-height 15 -radix decimal}} /cpu_pipelined_testbench/dut/rf/regOut
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1435491 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 133
configure wave -valuecolwidth 102
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
WaveRestoreZoom {0 ps} {6595320 ps}
