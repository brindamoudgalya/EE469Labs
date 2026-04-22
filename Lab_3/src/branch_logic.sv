module branch_logic (BranchToTake, UncondBranch, Branch, CondBranch, zero, negative, overflow);
    output logic BranchToTake;
    input logic UncondBranch, Branch, CondBranch;
    input logic zero, negative, overflow;

    // check if B.LT
    // compare first and second inputs (which go into ALU), then branch if:
    // either difference is negative OR if there is overflow (neg - pos)
    logic neg_xor_ovf;
    xor #(50) x(neg_xor_ovf, negative, overflow);

    // CBZ vs B.LT
    logic cond;
    mux2to1 m(cond, zero, neg_xor_ovf, CondBranch);

    // AND branch with cond
    logic br_and_cond;
    and #(50) a(br_and_cond, Branch, cond);

    // OR with uncond branch signal (B, BL, BR)
    or #(50) o(BranchToTake, UncondBranch, br_and_cond);
endmodule