module sign_extend (imm64, instr, ImmSel);
    output logic [63:0] imm64;
    input logic [1:0] ImmSel;
    input logic [31:0] instr;

    // ImmSel:      00: I-type      01: D-type      10: B-type      11: CB-type

    always_comb begin
        case (ImmSel)
            2'b00:
                imm64 = {52'b0, instr[21:10]};
            2'b01:
                imm64 = {55{instr[20]}, instr[20:12]};
            2'b10:
                imm64 = {38{instr[25]}, instr[25:0]};
            2'b11:
                imm64 = {45{instr[23]}, instr[23:5]};
        endcase
    end
endmodule