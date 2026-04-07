
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
    output logic [31:0][63:0] out;
    input logic [63:0] in;
    input logic [31:0] enable;
    input logic reset, clk;

    genvar i, j;
    generate
        for (i = 0; i < 32; i++) begin : make_32_registers
            for (j = 0; j < 64; j++) begin : dff_registers_64
                logic din, dhold, dchange;

                not #(50) n(n_enable, enable[i]);
                and #(50) a0(dhold, n_enable, out[i][j]);
                and #(50) a1(dchange, enable[i], in[j]);

                or #(50) o_reg64(din, dhold, dchange);

                D_FF d(out[i][j], din, reset, clk);
            end
        end
    endgenerate
endmodule

module reg64_testbench ();
    logic [31:0][63:0] out;
    logic [63:0] in;
    logic [31:0] enable;
    logic reset, clk;

    reg64 dut (.*);

    parameter clk_period = 5000;

    // clock generation
    initial begin
        clk <= 0;
        forever #(clk_period/2) clk <= ~clk;
    end

    integer i;
    initial begin
        in <= 64'b0;
        enable <= 32'b0;
        reset <= 1'b1;

        @(posedge clk);
        @(posedge clk);

        reset <= 1'b0;

        // iterate thru all registers
        for (i = 0; i < 32; i++) begin
            // apply input pattern
            in <= 64'hFFFFFFFFFFFFFFFF;
            enable <= 32'b0;
            enable[i] <= 1'b1;

            @(posedge clk);
            @(posedge clk);

            // disable write
            enable[i] <= 1'b0;
            in <= 64'b0;

            @(posedge clk);
            @(posedge clk);
        end
        $stop;
    end
endmodule