// update program counter every clock cycle (output goes into mux)

`timescale 1ps/1ps
module pc_adder (pc_plus4, pc_curr, clk, reset);
    output logic [63:0] pc_plus4;
    input logic [63:0] pc_curr;
    input logic clk, reset;

    genvar i;
    generate
        for (i=0; i < 64; i++) begin : pc_64_bit_register
            D_FF d(pc_plus4[i], pc_curr[i], reset, clk);
        end
    endgenerate
endmodule