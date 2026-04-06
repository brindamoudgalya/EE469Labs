
`timescale 1ns/10ps
module D_FF (q, d, reset, clk);
    output reg q;
    input d, reset, clk;

    always_ff @(posedge clk)
        if (reset)
            q <= 0; // on reset, set to 0
        else
            q <= d; // otherwise out = d
endmodule

// -----------------------------------------------------

module reg64 (out, in, enable, reset, clk);
    output logic [63:0] out;
    input logic [63:0] in;
    input logic [31:0] enable;
    input logic reset, clk;

    genvar i;
    generate
        for (i = 0; i < 64; i++) begin : dff_registers_64
            logic din, dhold, dchange;

            not #(50) n(n_enable, enable);
            and #(50) a0(dhold, n_enable, out[i]);
            and #(50) a1(dchange, enable, in[i]);

            or #(50) o_reg64(din, dhold, dchange);

            D_FF d(out[i], din, reset, clk);
        end
    endgenerate
endmodule

// NEED TESTBENCH