module controller (instruction, ALUSource, RegWrite, MemRead, MemWrite, RegToLoc, ALUOp, MemToReg, Branch, UncondBranch);
    input logic [31:0] instruction;
    output logic ALUSource, RegWrite, MemRead, MemWrite, RegToLoc, Branch, UncondBranch, SetFlags;
    output logic [1:0] ALUOp, MemToReg, ImmSel;

    // ImmSel:      00: I-type      01: D-type      10: B-type      11: CB-type

    logic [10:0] opcode;
    assign opcode = instruction[31:21];

    always_comb begin
        // defaults
        RegToLoc = 0; ALUSource = 0; Branch = 0; RegWrite = 0; 
        MemRead = 0; MemWrite = 0; UncondBranch = 0; SetFlags = 0;
        MemToReg = 2'b0; ALUOp = 2'b0; ImmSel = 2'b0;

        // casez : case statement with don't cares = z or ?
        casez (opcode)
            // ADDI
            11'b1001000100x: begin
                ImmSel = 2'b00;
                ALUOp = 2'b; // TODO: FIX THESE
            end

            // ADDS
            11'b10101011000: begin
                SetFlags = 1;
                ALUOp = 2'b;
            end

            // B
            11'b000101xxxxx: begin
                UncondBranch = 1; ImmSel = 2'b10;
            end

            // B.LT
            11'b01010100xxx: begin
                Branch = 1; ImmSel = 2'b11;
                ALUOp = 2'b;
            end

            // BL
            11'b100101xxxxx: begin
                UncondBranch = 1; ImmSel = 2'b10;
            end

            // BR
            11'b11010110000: begin
                UncondBranch = 1;
            end

            // CBZ
            11'b10110100xxx: begin
                Branch = 1; ImmSel = 2'b11;
                ALUOp = 2'b;
            end

            // LDUR
            11'b11111000010: begin

            end

            // STUR
            11'b11111000000: begin

            end

            // SUBS
            11'b11101011000: begin

            end
        endcase
    end
endmodule