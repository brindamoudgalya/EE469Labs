// extend immediate from 32-bit instruction to be 64 bits (based on instruction type)

`timescale 1ps/1ps
module sign_extend (imm64, instr, ImmSel);
    output logic [63:0] imm64;
    input logic [1:0] ImmSel;
    input logic [31:0] instr;

    // ImmSel:      00: I-type      01: D-type      10: B-type      11: CB-type

    logic [63:0] se00, se01, se10, se11;

    assign se00 = {52'b0, instr[21:10]};
    assign se01 = {55{instr[20]}, instr[20:12]};
    assign se10 = {38{instr[25]}, instr[25:0]};
    assign se11 = {45{instr[23]}, instr[23:5]};
    
    mux64x4to1 m(imm64, se00, se01, se10, se11, ImmSel);
endmodule