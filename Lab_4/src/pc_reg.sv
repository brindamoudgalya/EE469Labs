// update program counter every clock cycle (output goes into mux)

`timescale 1ps/1ps
module pc_reg (pc_out, pc_in, clk, reset);
    output logic [63:0] pc_out;
    input logic [63:0] pc_in;
    input logic clk, reset;

    genvar i;
    generate
        for (i=0; i < 64; i++) begin : pc_64_bit_register
            D_FF d(pc_out[i], pc_in[i], reset, clk);
        end
    endgenerate
endmodule