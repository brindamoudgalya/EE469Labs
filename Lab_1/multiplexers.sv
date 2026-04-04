module 2to1mux (out, in0, in1, sel);
    output logic out;
    input logic in0, in1, sel;

    logic nsel, out0, out1;
    not #(50) s(nsel, sel);

    and #(50) a0(out0, in0, nsel);
    and #(50) a1(out1, in1, sel);

    or #(50) o_2to1mux(out, out0, out1);

endmodule

module 64x2to1mux (out, in0, in1, sel);
    output logic [63:0] out;
    input logic [63:0] in0, in1;
    input logic sel;

    genvar i;
    generate
        for (i=0; i < 64; i++) begin : mux1
            2to1mux m(out[i], in0[i], in1[i], sel);
        end
    endgenerate
endmodule