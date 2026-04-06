
`timescale 1ns/10ps
module mux2to1 (out, in0, in1, sel);
    output logic out;
    input logic in0, in1, sel;

    logic nsel, out0, out1;
    not #(50) s(nsel, sel);

    and #(50) a0(out0, in0, nsel);
    and #(50) a1(out1, in1, sel);

    or #(50) o_2to1mux(out, out0, out1);

endmodule

// module mux64x2to1 (out, in0, in1, sel);
//     output logic [63:0] out;
//     input logic [63:0] in0, in1;
//     input logic sel;

//     genvar i;
//     generate
//         for (i=0; i < 64; i++) begin : mux1
//             2to1mux m(out[i], in0[i], in1[i], sel);
//         end
//     endgenerate
// endmodule

module mux32to1 (out, in, sel);
    output logic out;
    input logic [31:0] in;
    input logic [4:0] sel;

    logic [15:0] l0out;
    logic [7:0] l1out;
    logic [3:0] l2out;
    logic [1:0] l3out;

    genvar i;
    generate
        for (i=0; i < 16; i++) begin : l0
            mux2to1 m(l0out[i], in[2*i], in[2*i + 1], sel[0]);
        end
        for (i=0; i < 8; i++) begin : l1
            mux2to1 m(l1out[i], in[2*i], in[2*i + 1], sel[1]);
        end
        for (i=0; i < 4; i++) begin : l2
            mux2to1 m(l2out[i], in[2*i], in[2*i + 1], sel[2]);
        end
        for (i=0; i < 2; i++) begin : l3
            mux2to1 m(l3out[i], in[2*i], in[2*i + 1], sel[3]);
        end
    endgenerate
    
    mux2to1 final_m(out, l3out[0], l3out[1], sel[4]);
endmodule

module mux64x32to1 (out, in, sel);
    output logic [63:0] out;
    input logic [31:0][63:0] in;
    input logic [4:0] sel;

    genvar i, j;
    generate
        for (i=0; i < 64; i++) begin : mux31to1_64times
            // store all 0th bits from mux 31:0, then 1st bit, then 2nd, etc.
            logic [31:0] bus_to_store;
            for (j=0; j < 32; j++) begin : store_in_bus
                assign bus_to_store[j] = in[j][i];
            end
            mux32to1 m(out[i], bus_to_store, sel);
        end
    endgenerate

endmodule