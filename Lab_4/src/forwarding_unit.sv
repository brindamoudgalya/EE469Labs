module forwarding_unit (forwardA, forwardB, id_ex_Rn, id_ex_Rm, ex_mem_WriteReg, mem_wb_WriteReg, ex_mem_RegWrite,
                        mem_wb_RegWrite);
    output logic [1:0] forwardA, forwardB;
    input logic [4:0] id_ex_Rn, id_ex_Rm, ex_mem_WriteReg, mem_wb_WriteReg;
    input logic ex_mem_RegWrite, mem_wb_RegWrite;

    // ex hazard: next instruction down
    // mem hazard: two instructions down
    always_comb begin
        // default = 00: take data naturally from id/ex reg
        forwardA = 2'b00;
        forwardB = 2'b00;

        // fwd A (Rn)
        // ex hazard (data just computed in alu being passed to [R?] instruction)
        if (ex_mem_RegWrite && (ex_mem_WriteReg != 5'd31) && (ex_mem_WriteReg == id_ex_Rn)) begin
            forwardA = 2'b10; // IGNORE REG FILE AND ROUTE DATA BACK FROM EX/MEM REG
        end
        // mem hazard (data corrupt from data mem / prev alu instruction)
        else if (mem_wb_RegWrite && (mem_wb_WriteReg != 5'd31) && (mem_wb_WriteReg == id_ex_Rn)) begin
            forwardA = 2'b01;
        end

        // fwd B (Rm)
        // ex hazard
        if (ex_mem_RegWrite && (ex_mem_WriteReg != 5'd31) && (ex_mem_WriteReg == id_ex_Rm)) begin
            forwardB = 2'b10;
        end
        // mem hazard
        else if (mem_wb_RegWrite && (mem_wb_WriteReg != 5'd31) && (mem_wb_WriteReg == id_ex_Rm)) begin
            forwardB = 2'b01;
        end
    end
endmodule