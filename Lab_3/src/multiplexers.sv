
`timescale 1ps/1ps
module mux2to1 (out, in0, in1, sel);
    output logic out;
    input logic in0, in1, sel;

    logic nsel, out0, out1;
    not #(50) s(nsel, sel);

    and #(50) a0(out0, in0, nsel);
    and #(50) a1(out1, in1, sel);

    or #(50) o_2to1mux(out, out0, out1);
endmodule

module mux2to1_testbench ();
    logic out;
    logic in0, in1, sel;
    logic clk;

    mux2to1 dut (.*);

    parameter clk_period = 200;
    initial begin
        clk <= 0;
        forever #(clk_period/2) clk <= ~clk;
    end // initial clock

    integer i; 
	initial begin
        @(posedge clk);
        sel <= 0; in0 <= 1'b0; in1 <= 1'b0; @(posedge clk); // output should be 1'b0
        in1 <= 1'b1; @(posedge clk); // output should be 1'b0
        sel <= 1; @(posedge clk); // output should be 1'b1
        in1 <= 1'b0; @(posedge clk); // output should be 1'b0
        @(posedge clk);
        $stop;
    end
endmodule

// ------------------------------------------------------------

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
            mux2to1 m(l1out[i], l0out[2*i], l0out[2*i + 1], sel[1]);
        end
        for (i=0; i < 4; i++) begin : l2
            mux2to1 m(l2out[i], l1out[2*i], l1out[2*i + 1], sel[2]);
        end
        for (i=0; i < 2; i++) begin : l3
            mux2to1 m(l3out[i], l2out[2*i], l2out[2*i + 1], sel[3]);
        end
    endgenerate
    
    mux2to1 final_m(out, l3out[0], l3out[1], sel[4]);
endmodule

module mux32to1_testbench();
    logic out;
    logic [31:0] in;
    logic [4:0] sel;

    // logic [15:0] l0out;
    // logic [7:0] l1out;
    // logic [3:0] l2out;
    // logic [1:0] l3out;
    logic clk;

    mux32to1 dut (.*);

    parameter clk_period = 5000;
    initial begin
        clk <= 0;
        forever #(clk_period/2) clk <= ~clk;
    end // initial clock

    integer i; 
	initial begin
        in <= 32'b0;
        for (i = 0; i < 2**5; i++) begin
            sel <= i;
            @(posedge clk);
            @(posedge clk);
            in[i] <= 1'b1;
            @(posedge clk);
            @(posedge clk);
            in[i] <= 1'b0;
        end
        $stop;
    end

endmodule

// -----------------------------------------------------------------------------

module mux64x32to1 (out, in, sel);
    output logic [63:0] out;
    input logic [31:0][63:0] in;
    input logic [4:0] sel;

    genvar i, j;
    generate
        for (i=0; i < 64; i++) begin : mux32to1_64times
            // store all 0th bits from mux 31:0, then 1st bit, then 2nd, etc.
            logic [31:0] bus_to_store;
            for (j=0; j < 32; j++) begin : store_in_bus
                assign bus_to_store[j] = in[j][i];
            end
            mux32to1 m(out[i], bus_to_store, sel);
        end
    endgenerate
endmodule

module mux64x32to1_testbench ();
    logic [63:0] out;
    logic [31:0][63:0] in;
    logic [4:0] sel;
    logic clk;

    mux64x32to1 dut (.*);

    parameter clk_period = 5000;
    initial begin
        clk <= 0;
        forever #(clk_period/2) clk <= ~clk;
    end

    integer i, j;
    initial begin
        in <= '0;
        sel <= 5'b0;

        for (i = 0; i < 32; i++) begin
            sel <= i;
            @(posedge clk);
            @(posedge clk);

            // set entire 64-bit word high
            in[i] <= 64'hFFFFFFFFFFFFFFFF;
            @(posedge clk);
            @(posedge clk);

            // bring it back to 0
            in[i] <= 64'b0;
        end
        $stop;
    end
endmodule

// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

// lab3:

module mux64x2to1 (out, in0, in1, sel);
    output logic [63:0] out;
    input logic [63:0] in0, in1;
    input logic sel;

    genvar i;
    generate
        for (i=0; i < 64; i++) begin : mux1
            mux2to1 m(out[i], in0[i], in1[i], sel);
        end
    endgenerate
endmodule

module mux64x4to1 (out, in0, in1, in2, in3, sel);
    output logic [63:0] out;
    input logic [63:0] in0, in1, in2, in3;
    input logic [1:0] sel;

    logic [63:0] lower_m, upper_m;

    mux64x2to1 m0(lower_m, in0, in1, sel[0]);
    mux64x2to1 m1(upper_m, in2, in3, sel[0]);
    mux64x2to1 m2(out, lower_m, upper_m, sel[1]); // CHECK (TODO): is order correct?
endmodule

module mux5x2to1 (out, in0, in1, sel);
    output logic [4:0] out;
    input logic [4:0] in0, in1;
    input logic sel;

    genvar i;
    generate
        for (i=0; i < 5; i++) begin : mux1
            mux2to1 m(out[i], in0[i], in1[i], sel);
        end
    endgenerate
endmodule