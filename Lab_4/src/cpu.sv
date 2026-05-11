// top level module, instantiates all others
// deleted old version (lab3 version) to implement pipelined
`timescale 1ps/1ps
module cpu (clk, reset);
    input logic clk, reset;
    
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

    // STAGE 2: INSTRUCTION DECODE
    logic id_ALUSource, id_RegWrite, id_MemRead, id_MemWrite, id_Reg2Loc;
    logic id_Branch, id_UncondBranch, id_SetFlags, id_CBranchSel, id_WriteRegSel, id_CondBranch;
    logic [1:0] id_ALUOp, id_MemToReg, id_ImmSel;
    logic [2:0] id_ALU_control_3bit;

    main_control mc(
        .instruction(id_instr), .ALUSource(id_ALUSource), .RegWrite(id_RegWrite),
        .MemRead(id_MemRead), .MemWrite(id_MemWrite), .Reg2Loc(id_Reg2Loc),
        .Branch(id_Branch), .UncondBranch(id_UncondBranch), .SetFlags(id_SetFlags),
        .ALUOp(id_ALUOp), .MemToReg(id_MemToReg), .ImmSel(id_ImmSel),
        .CBranchSel(id_CBranchSel), .WriteRegSel(id_WriteRegSel), .CondBranch(id_CondBranch)
    );

    alu_control ac (.ALUOp(id_ALUOp), .opcode(id_instr[31:21]), .cntrl(id_ALU_control_3bit));

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

    sign_extend se (.imm64(imm64), .instr(id_instr), .ImmSel(id_ImmSel));

    // pipeline reg: ID/EX

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
        reset = 1; @(posedge clk);
        reset = 0; @(posedge clk);

		for (i=0; i <= 100; i++) begin
			@(posedge clk);
        end
        $stop;
    end
endmodule