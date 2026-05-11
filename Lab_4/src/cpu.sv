// top level module, instantiates all others
// deleted old version (lab3 version) to implement pipelined
`timescale 1ps/1ps
module cpu (clk, reset);
    input logic clk, reset;
    
    // -----------------------------------------------------------------------------------------------------------

    // STAGE 1: INSTRUCTION FETCH

    logic [63:0] if_pc, if_pc_next, if_pc_plus4;
    logic [31:0] if_instr;

    logic TakeBranch;
    logic [63:0] ex_target_branch;

    pc_reg program_counter (.pc_plus4(if_pc), .pc_curr(if_pc_next), .clk(clk), .reset(reset));

    logic d1, d2, d3, d4;
    adder pc_add_4 (.sum(if_pc_plus4), .zero(d1), .overflow(d2), .carry_out(d3), 
                    .negative(d4), .A(if_pc), .B(64'd4), .carry_in(1'b0));

    instructmem instrmem (.address(if_pc), .instruction(if_instr), .clk(clk));

    mux64x2to1 m_nextpc (.out(if_pc_next), .in0(if_pc_plus4), 
                        .in1(ex_target_branch), .sel(TakeBranch));

    // -----------------------------------------------------------------------------------------------------------

    // pipeline reg: IF/ID
    logic [63:0] id_pc, id_pc_plus4;
    logic [31:0] id_instr;

    // if branchtaken, FLUSH the instruction
    pipeline_reg_64bit p_if_id_pc (.q(id_pc), .d(if_pc), .clk(clk), .reset(reset), 
                                    .flush_en(TakeBranch));
    pipeline_reg_64bit p_if_id_pc4 (.q(id_pc_plus4), .d(if_pc_plus4), .clk(clk), 
                                    .reset(reset), .flush_en(TakeBranch));
    pipeline_reg_32bit p_if_id_instr (.q(id_instr), .d(if_instr), .clk(clk), .reset(reset), 
                                        .flush_en(TakeBranch));
                                    
    // -----------------------------------------------------------------------------------------------------------

    // STAGE 2: INSTRUCTION DECODE
    logic id_ALUSource, id_RegWrite, id_MemRead, id_MemWrite, id_Reg2Loc;
    logic id_Branch, id_UncondBranch, id_SetFlags, id_CBranchSel, id_WriteRegSel, id_CondBranch;
    logic [1:0] id_ALUOp, id_MemToReg, id_ImmSel;
    logic [2:0] id_ALU_cntrl_3bit;

    main_control mc(
        .instruction(id_instr), .ALUSource(id_ALUSource), .RegWrite(id_RegWrite),
        .MemRead(id_MemRead), .MemWrite(id_MemWrite), .Reg2Loc(id_Reg2Loc),
        .Branch(id_Branch), .UncondBranch(id_UncondBranch), .SetFlags(id_SetFlags),
        .ALUOp(id_ALUOp), .MemToReg(id_MemToReg), .ImmSel(id_ImmSel),
        .CBranchSel(id_CBranchSel), .WriteRegSel(id_WriteRegSel), .CondBranch(id_CondBranch)
    );

    alu_control ac (.ALUOp(id_ALUOp), .opcode(id_instr[31:21]), .cntrl(id_ALU_cntrl_3bit));

    logic [4:0] id_ReadReg2, id_WriteReg;
    logic [63:0] id_ReadData1, id_ReadData2, id_imm64;

    mux5x2to1 m_reg2loc (.out(id_ReadReg2), .in0(id_instr[20:16]), .in1(id_instr[4:0]), .sel(id_Reg2Loc));
    mux5x2to1 m_writereg (.out(id_WriteReg), .in0(id_instr[4:0]), .in1(5'd30), .sel(id_WriteRegSel));

    logic wb_RegWrite;
    logic [4:0] wb_WriteReg;
    logic [63:0] wb_WriteData;

    regfile rf (
        .ReadData1(id_ReadData1), .ReadData2(id_ReadData2), .ReadRegister1(id_instr[9:5]), 
        .ReadRegister2 (id_ReadReg2), .WriteRegister(wb_WriteReg), .WriteData(wb_WriteData), 
        .RegWrite(wb_RegWrite), .clk(clk), .reset(reset)
    );

    sign_extend se (.imm64(id_imm64), .instr(id_instr), .ImmSel(id_ImmSel));

    // -----------------------------------------------------------------------------------------------------------

    // pipeline reg: ID/EX
    logic ex_ALUSource, ex_RegWrite, ex_MemRead, ex_MemWrite, ex_Branch, ex_UncondBranch, ex_SetFlags, ex_CBranchSel, ex_CondBranch;
    logic [1:0] ex_MemToReg;
    logic [2:0] ex_ALU_cntrl_3bit;
    logic [63:0] ex_ReadData1, ex_ReadData2, ex_imm64, ex_pc, ex_pc_plus4;
    logic [4:0] ex_Rn, ex_Rm, ex_WriteReg;

    pipeline_reg_1bit  p_id_ex_c1  (.q(ex_ALUSource), .d(id_ALUSource), .clk(clk), .reset(reset), .flush_en(1'b0));
    pipeline_reg_1bit  p_id_ex_c2  (.q(ex_RegWrite), .d(id_RegWrite), .clk(clk), .reset(reset), .flush_en(1'b0));
    pipeline_reg_1bit  p_id_ex_c3  (.q(ex_MemRead), .d(id_MemRead), .clk(clk), .reset(reset), .flush_en(1'b0));
    pipeline_reg_1bit  p_id_ex_c4  (.q(ex_MemWrite), .d(id_MemWrite), .clk(clk), .reset(reset), .flush_en(1'b0));
    pipeline_reg_1bit  p_id_ex_c5  (.q(ex_Branch), .d(id_Branch), .clk(clk), .reset(reset), .flush_en(1'b0));
    pipeline_reg_1bit  p_id_ex_c6  (.q(ex_UncondBranch), .d(id_UncondBranch), .clk(clk), .reset(reset), .flush_en(1'b0));
    pipeline_reg_1bit  p_id_ex_c7  (.q(ex_SetFlags), .d(id_SetFlags), .clk(clk), .reset(reset), .flush_en(1'b0));
    pipeline_reg_1bit  p_id_ex_c8  (.q(ex_CBranchSel), .d(id_CBranchSel), .clk(clk), .reset(reset), .flush_en(1'b0));
    pipeline_reg_1bit  p_id_ex_c9  (.q(ex_CondBranch), .d(id_CondBranch), .clk(clk), .reset(reset), .flush_en(1'b0));
    pipeline_reg_2bit  p_id_ex_c10 (.q(ex_MemToReg), .d(id_MemToReg), .clk(clk), .reset(reset), .flush_en(1'b0));
    pipeline_reg_3bit  p_id_ex_c11 (.q(ex_ALU_cntrl_3bit), .d(id_ALU_cntrl_3bit), .clk(clk), .reset(reset), .flush_en(1'b0));

    pipeline_reg_64bit p_id_ex_d1  (.q(ex_ReadData1), .d(id_ReadData1), .clk(clk), .reset(reset), .flush_en(1'b0));
    pipeline_reg_64bit p_id_ex_d2  (.q(ex_ReadData2), .d(id_ReadData2), .clk(clk), .reset(reset), .flush_en(1'b0));
    pipeline_reg_64bit p_id_ex_d3  (.q(ex_imm64), .d(id_imm64), .clk(clk), .reset(reset), .flush_en(1'b0));
    pipeline_reg_64bit p_id_ex_d4  (.q(ex_pc), .d(id_pc), .clk(clk), .reset(reset), .flush_en(1'b0));
    pipeline_reg_64bit p_id_ex_d5  (.q(ex_pc_plus4), .d(id_pc_plus4), .clk(clk), .reset(reset), .flush_en(1'b0));

    pipeline_reg_5bit  p_id_ex_r1  (.q(ex_Rn), .d(id_instr[9:5]), .clk(clk), .reset(reset), .flush_en(1'b0));
    pipeline_reg_5bit  p_id_ex_r2  (.q(ex_Rm), .d(id_ReadReg2), .clk(clk), .reset(reset), .flush_en(1'b0));
    pipeline_reg_5bit  p_id_ex_r3  (.q(ex_WriteReg), .d(id_WriteReg), .clk(clk), .reset(reset), .flush_en(1'b0));

    // -----------------------------------------------------------------------------------------------------------

    // STAGE 3: EXECUTE
    logic [1:0] ForwardA, ForwardB;
    logic [63:0] Forwarded_A, Forwarded_B, ALU_B_in, ex_alu_result, ex_shifted_imm, ex_target_branch_offset;
    logic alu_negative, alu_zero, alu_overflow, alu_carry;
    logic flag_n, flag_z, flag_v, flag_c;

    // fwding muxes: 00 = Normal, 01 = From MEM/WB, 10 = From EX/MEM
    // mem_ALU_result evaluated in mem stage below... wb_WriteData loops back from wb.
    logic [63:0] mem_ALU_result; 
    mux64x4to1 m_fwd_a (.out(Forwarded_A), .in0(ex_ReadData1), .in1(wb_WriteData), .in2(mem_ALU_result), .in3(64'b0), .sel(ForwardA));
    mux64x4to1 m_fwd_b (.out(Forwarded_B), .in0(ex_ReadData2), .in1(wb_WriteData), .in2(mem_ALU_result), .in3(64'b0), .sel(ForwardB));

    mux64x2to1 m_alusrc (.out(ALU_B_in), .in0(Forwarded_B), .in1(ex_imm64), .sel(ex_ALUSource));

    alu main_alu (
        .A(Forwarded_A), .B(ALU_B_in), .cntrl(ex_ALU_cntrl_3bit),
        .result(ex_alu_result), .negative(alu_negative), .zero(alu_zero),
        .overflow(alu_overflow), .carry_out(alu_carry)
    );

    flag_reg f1(
        .neg_out(flag_n), .zero_out(flag_z), .overflow_out(flag_v), .c_out(flag_c),
        .neg_in(alu_negative), .zero_in(alu_zero), .overflow_in(alu_overflow), .c_in(alu_carry),
        .clk(clk), .reset(reset), .SetFlags(ex_SetFlags)
    );

    assign ex_shifted_imm = {ex_imm64[61:0], 2'b00};
    logic d5, d6, d7, d8; 
    adder branch_adder (.sum(ex_target_branch_offset), .zero(d5), .overflow(d6), .carry_out(d7), .negative(d8), .A(ex_pc), .B(ex_shifted_imm), .carry_in(1'b0));

    mux64x2to1 m_br_target (.out(ex_target_branch), .in0(ex_target_branch_offset), .in1(Forwarded_B), .sel(ex_CBranchSel));

    branch_logic bl(
        .BranchToTake(TakeBranch), .UncondBranch(ex_UncondBranch), .Branch(ex_Branch), 
        .CondBranch(ex_CondBranch), .zero(alu_zero), .negative(flag_n), .overflow(flag_v)
    );

    // -----------------------------------------------------------------------------------------------------------

    // pipeline reg: EX/MEM
    logic mem_RegWrite, mem_MemRead, mem_MemWrite;
    logic [1:0] mem_MemToReg;
    logic [63:0] mem_Forwarded_B, mem_pc_plus4;
    logic [4:0] mem_WriteReg;

    pipeline_reg_1bit  p_ex_mem_c1 (.q(mem_RegWrite), .d(ex_RegWrite), .clk(clk), .reset(reset), .flush_en(1'b0));
    pipeline_reg_1bit  p_ex_mem_c2 (.q(mem_MemRead), .d(ex_MemRead), .clk(clk), .reset(reset), .flush_en(1'b0));
    pipeline_reg_1bit  p_ex_mem_c3 (.q(mem_MemWrite), .d(ex_MemWrite), .clk(clk), .reset(reset), .flush_en(1'b0));
    pipeline_reg_2bit  p_ex_mem_c4 (.q(mem_MemToReg), .d(ex_MemToReg), .clk(clk), .reset(reset), .flush_en(1'b0));

    pipeline_reg_64bit p_ex_mem_d1 (.q(mem_ALU_result), .d(ex_alu_result), .clk(clk), .reset(reset), .flush_en(1'b0));
    pipeline_reg_64bit p_ex_mem_d2 (.q(mem_Forwarded_B), .d(Forwarded_B), .clk(clk), .reset(reset), .flush_en(1'b0));
    pipeline_reg_64bit p_ex_mem_d3 (.q(mem_pc_plus4), .d(ex_pc_plus4), .clk(clk), .reset(reset), .flush_en(1'b0));

    pipeline_reg_5bit  p_ex_mem_r1 (.q(mem_WriteReg), .d(ex_WriteReg), .clk(clk), .reset(reset), .flush_en(1'b0));

    // -----------------------------------------------------------------------------------------------------------

    // STAGE 4: MEMORY
    logic [63:0] mem_read_data;

    datamem dm(
        .address(mem_ALU_result), .write_enable(mem_MemWrite), .read_enable(mem_MemRead),
        .write_data(mem_Forwarded_B), .clk(clk), .xfer_size(4'b1000), .read_data(mem_read_data)
    );

    // -----------------------------------------------------------------------------------------------------------

    // pipeline reg: MEM/WB
    logic [1:0] wb_MemToReg;
    logic [63:0] wb_read_data, wb_ALU_result, wb_pc_plus4;

    pipeline_reg_1bit  p_mem_wb_c1 (.q(wb_RegWrite), .d(mem_RegWrite), .clk(clk), .reset(reset), .flush_en(1'b0));
    pipeline_reg_2bit  p_mem_wb_c2 (.q(wb_MemToReg), .d(mem_MemToReg), .clk(clk), .reset(reset), .flush_en(1'b0));

    pipeline_reg_64bit p_mem_wb_d1 (.q(wb_read_data), .d(mem_read_data), .clk(clk), .reset(reset), .flush_en(1'b0));
    pipeline_reg_64bit p_mem_wb_d2 (.q(wb_ALU_result), .d(mem_ALU_result), .clk(clk), .reset(reset), .flush_en(1'b0));
    pipeline_reg_64bit p_mem_wb_d3 (.q(wb_pc_plus4), .d(mem_pc_plus4), .clk(clk), .reset(reset), .flush_en(1'b0));

    pipeline_reg_5bit  p_mem_wb_r1 (.q(wb_WriteReg), .d(mem_WriteReg), .clk(clk), .reset(reset), .flush_en(1'b0));

    // -----------------------------------------------------------------------------------------------------------

    // STAGE 5: WRITEBACK
    
    // Mux write data (00 = ALU, 01 = Memory, 10 = PC+4 for BL)
    mux64x4to1 memtoreg_mux (
        .out(wb_WriteData), .in0(wb_ALU_result), .in1(wb_read_data), 
        .in2(wb_pc_plus4), .in3(64'b0), .sel(wb_MemToReg)
    );

    // -----------------------------------------------------------------------------------------------------------

    // FWDING UNIT
    forwarding_unit fwd (
        .id_ex_Rn(ex_Rn), 
        .id_ex_Rm(ex_Rm),
        .ex_mem_WriteReg(mem_WriteReg), 
        .mem_wb_WriteReg(wb_WriteReg),
        .ex_mem_RegWrite(mem_RegWrite), 
        .mem_wb_RegWrite(wb_RegWrite),
        .ForwardA(ForwardA), 
        .ForwardB(ForwardB)
    );
endmodule

module cpu_testbench ();
    logic clk, reset;

    cpu dut (.clk, .reset);
	
	parameter clk_period = 100000;

    initial begin
        clk <= 0;
        forever #(clk_period/2) clk <= ~clk;
    end // initial clock

	integer i;
	initial begin
        reset <= 1; @(posedge clk);
        reset <= 0; @(posedge clk);

		for (i=0; i <= 500; i++) begin
			@(posedge clk);
        end
        $stop;
    end
endmodule