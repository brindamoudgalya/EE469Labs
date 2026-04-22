// conditional branching will look at the flags set at that point and branch accordingly

`timescale 1ps/1ps
module flag_reg (neg_out, zero_out, overflow_out, c_out, neg_in, zero_in, overflow_in, c_in, clk, reset, SetFlags);
    output logic neg_out, zero_out, overflow_out, c_out;
    input logic c_out, neg_in, zero_in, overflow_in, c_in;
    input logic clk, reset, SetFlags;

    logic neg_temp, zero_temp, overflow_temp, c_temp;

    // based on SetFlags (sel), set flag to the CURRENT VALUE (~SF) or the NEW VALUE (SF)
    mux2to1 m1(neg_temp, neg_out, neg_in, SetFlags);
    mux2to1 m2(zero_temp, zero_out, zero_in, SetFlags);
    mux2to1 m3(overflow_temp, overflow_out, overflow_in, SetFlags);
    mux2to1 m4(c_temp, c_out, c_in, SetFlags);

    // now set the actual output from temp output
    D_FF d1(neg_out, neg_temp, reset, clk);
    D_FF d2(zero_out, zero_temp, reset, clk);
    D_FF d3(overflow_out, overflow_temp, reset, clk);
    D_FF d4(c_out, c_temp, reset, clk);
endmodule