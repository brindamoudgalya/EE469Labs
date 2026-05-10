`timescale 1ps/1ps
module alu_control (ALUOp, opcode, cntrl);
    output logic [2:0] cntrl;
    input logic [1:0] ALUOp;
    input logic [10:0] opcode;

    always_comb begin
        case (ALUOp)
            2'b00: // load/store -- ADDER (010)
                cntrl = 3'b010; 
            2'b01: // branching -- PASS B (000)
                cntrl = 3'b000;
            2'b10: // arithmetic -- look at opcode
                casez (opcode) // ADDI -- 010 | ADDS -- 010 | SUBS -- 011
                    11'b1001000100z:
                        cntrl = 3'b010;
                    11'b10101011000:
                        cntrl = 3'b010;
                    11'b11101011000:
                        cntrl = 3'b011;
                    default: 
                        cntrl = 3'b000;
                endcase
            default:
                cntrl = 3'b000;
        endcase
    end
endmodule