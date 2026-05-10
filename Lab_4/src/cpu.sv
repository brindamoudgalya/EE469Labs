// top level module, instantiates all others

`timescale 1ps/1ps
module cpu (clk, reset);
    input logic clk, reset;

    // pc, instruction fetch
    logic [63:0] pc, pc_next, pc_plus4, pc_plus_imm, br_target, shifted_imm, imm64;
    logic [31:0] instr;

    pc_reg p(.pc_out(pc), .pc_in(pc_next), .clk(clk), .reset(reset));

    logic f1, f2, f3, f4;
    adder pc_add4 (.sum(pc_plus4), .zero(f1), .overflow(f2), .carry_out(f3), .negative(f4), .A(pc), .B(64'd4), .carry_in(1'b0));

    assign shifted_imm = {imm64[61:0], 2'b00};

    logic d1, d2, d3, d4;
    adder pc_add_branch (.sum(pc_plus_imm), .zero(d1), .overflow(d2), .carry_out(d3), .negative(d4), .A(pc), .B(shifted_imm), .carry_in(1'b0));

    instructmem i(.address(pc), .instruction(instr), .clk(clk));

    // ------------------------------------------------------------------------------------------------

    // main_control and alu_control
    logic ALUSource, RegWrite, MemRead, MemWrite, Reg2Loc, Branch, UncondBranch, SetFlags;
    logic CondBranch, CBranchSel, WriteRegSel;
    logic [1:0] ALUOp, MemToReg, ImmSel;
    logic [2:0] ALUcntrl;

    main_control mc(.instruction(instr), .ALUSource(ALUSource), 
        .RegWrite(RegWrite), .MemRead(MemRead), .MemWrite(MemWrite), 
        .Reg2Loc(Reg2Loc), .ALUOp(ALUOp), .MemToReg(MemToReg), .Branch(Branch), 
        .UncondBranch(UncondBranch), .SetFlags(SetFlags), .ImmSel(ImmSel), 
        .CBranchSel(CBranchSel), .WriteRegSel(WriteRegSel), .CondBranch(CondBranch));

    alu_control ac(.ALUOp(ALUOp), .opcode(instr[31:21]), .cntrl(ALUcntrl));

    // ------------------------------------------------------------------------------------------------

    // regfile and sign extender
    logic [4:0] ReadRegister2, WriteRegister;
    logic [63:0] ReadData1, ReadData2, WriteData; // where imm64 declaration used to be

    // mux to choose rm or rd
    mux5x2to1 m1(ReadRegister2, instr[20:16], instr[4:0], Reg2Loc);

    // mux to choose rd or x30 for BL
    mux5x2to1 m2(WriteRegister, instr[4:0], 5'd30, WriteRegSel);

    regfile r(.ReadData1(ReadData1), .ReadData2(ReadData2), 
        .ReadRegister1(instr[9:5]), .ReadRegister2(ReadRegister2), 
        .WriteRegister(WriteRegister), .WriteData(WriteData), 
        .RegWrite(RegWrite), .clk(clk), .reset(reset));
    
    sign_extend se(.imm64(imm64), .instr(instr), .ImmSel(ImmSel));

    // ------------------------------------------------------------------------------------------------

    // alu, flags
    logic [63:0] ALU_B_in, alu_out;
    logic alu_neg, alu_zero, alu_overflow, alu_carry;
    logic flag_neg, flag_zero, flag_overflow, flag_carry;

    // mux to choose ReadData2 or imm for ALU
    mux64x2to1 m_alu(ALU_B_in, ReadData2, imm64, ALUSource);

    alu a(.A(ReadData1), .B(ALU_B_in), .cntrl(ALUcntrl), .result(alu_out), 
        .negative(alu_neg), .zero(alu_zero), .overflow(alu_overflow), .carry_out(alu_carry));

    flag_reg flagregister1(.neg_out(flag_neg), .zero_out(flag_zero), .overflow_out(flag_overflow), 
        .c_out(flag_carry), .neg_in(alu_neg), .zero_in(alu_zero), .overflow_in(alu_overflow), 
        .c_in(alu_carry), .clk(clk), .reset(reset), .SetFlags(SetFlags));

    // ------------------------------------------------------------------------------------------------

    // data mem
    logic [63:0] read_data;

    datamem dm(.address(alu_out), .write_enable(MemWrite), .read_enable(MemRead),
        .write_data(ReadData2), .clk(clk), .xfer_size(4'b1000), .read_data(read_data));
    
    // mux write data (00 = ALU, 01 = Memory, 10 = PC+4 (BL))
    mux64x4to1 memtoreg(.out(WriteData), .in0(alu_out), .in1(read_data), 
        .in2(pc_plus4), .in3(64'b0), .sel(MemToReg));

    // ------------------------------------------------------------------------------------------------

    // branching logic
    logic BrToTake;

    branch_logic bl(.BranchToTake(BrToTake), .UncondBranch(UncondBranch), 
        .Branch(Branch), .CondBranch(CondBranch), .zero(alu_zero), 
        .negative(flag_neg), .overflow(flag_overflow));

    // mux branch target (0 = PC+imm, 1 = Reg[Rd] (BR))
    mux64x2to1 m_branching(.out(br_target), .in0(pc_plus_imm), .in1(ReadData2), .sel(CBranchSel));

    // mux next pc (0 = PC+4, 1 = Branch Target)
    mux64x2to1 m_nextpc(.out(pc_next), .in0(pc_plus4), .in1(br_target), .sel(BrToTake));

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