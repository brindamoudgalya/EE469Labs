
`timescale 1ps/1ps
module pipeline_reg_1bit (q, d, clk, reset, flush_en);
    output logic q;
    input logic d, clk, reset, flush_en;
    logic next_d;
    mux2to1 mux_flush (next_d, d, 1'b0, flush_en); // if flush_en, then flush d (d=0)
    D_FF dff (q, next_d, reset, clk);
endmodule

module pipeline_reg_2bit (q, d, clk, reset, flush_en);
    output logic [1:0] q;
    input logic [1:0] d;
    input logic clk, reset, flush_en;
    
    genvar i;
    generate
        for (i=0; i < 2; i++) begin : pipeline2bit
            pipeline_reg_1bit p (q[i], d[i], clk, reset, flush_en);
        end
    endgenerate
endmodule

module pipeline_reg_3bit (q, d, clk, reset, flush_en);
    output logic [2:0] q;
    input logic [2:0] d;
    input logic clk, reset, flush_en;
    
    genvar i;
    generate
        for (i=0; i < 3; i++) begin : pipeline3bit
            pipeline_reg_1bit p (q[i], d[i], clk, reset, flush_en);
        end
    endgenerate
endmodule

module pipeline_reg_5bit (q, d, clk, reset, flush_en);
    output logic [4:0] q;
    input logic [4:0] d;
    input logic clk, reset, flush_en;
    
    genvar i;
    generate
        for (i=0; i < 5; i++) begin : pipeline5bit
            pipeline_reg_1bit p (q[i], d[i], clk, reset, flush_en);
        end
    endgenerate
endmodule

module pipeline_reg_32bit (q, d, clk, reset, flush_en);
    output logic [31:0] q;
    input logic [31:0] d;
    input logic clk, reset, flush_en;
    
    genvar i;
    generate
        for (i=0; i < 32; i++) begin : pipeline32bit
            pipeline_reg_1bit p (q[i], d[i], clk, reset, flush_en);
        end
    endgenerate
endmodule

module pipeline_reg_64bit (q, d, clk, reset, flush_en);
    output logic [63:0] q;
    input logic [63:0] d;
    input logic clk, reset, flush_en;
    
    genvar i;
    generate
        for (i=0; i < 64; i++) begin : pipeline64bit
            pipeline_reg_1bit p (q[i], d[i], clk, reset, flush_en);
        end
    endgenerate
endmodule