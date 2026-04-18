module controller (instruction, ALUSource, RegWrite, MemRead, MemWrite, RegToLoc, ALUOp, MemToReg, Branch, UncondBranch);
    input logic [31:0] instruction;
    output logic ALUSource, RegWrite, MemRead, MemWrite, RegToLoc;
    output logic [1:0] ALUOp;


endmodule