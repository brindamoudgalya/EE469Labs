
`timescale 1ps/1ps
module dec2to4 (out, in, enable);
    output logic [3:0] out;
    input logic [1:0] in;
    input logic enable; // enable is RegWrite

    logic nin0, nin1, in0, in1;

    // CAN'T USE "~" >:(
    not #(50) n0(nin0, in[0]);
    not #(50) n1(nin1, in[1]);

    // // and there is a weird in-between state for ANDs when one inp passes thru negation (50ps delay) and other inp doesn't (0ps delay). so:
    // buf #(50) b0(in0, in[0]);
    // buf #(50) b1(in1, in[1]);

    and #(50) e0(out[0], nin1, nin0, enable);
    and #(50) e1(out[1], nin1, in[0], enable);
    and #(50) e2(out[2], in[1], nin0, enable);
    and #(50) e3(out[3], in[1], in[0], enable);
endmodule

module dec2to4_testbench();
    logic [3:0] out;
    logic [1:0] in;
    logic enable;
    logic clk;

    dec2to4 dut (.*);

    parameter clk_period = 100;
    initial begin
        clk <= 0;
        forever #(clk_period/2) clk <= ~clk;
    end // initial clock

    integer i; 
	initial begin
        @(posedge clk);
        enable <= 0; in <= 5'b00; @(posedge clk);
        for (i=0; i < 2**2; i++) begin
            in <= i;
            @(posedge clk);
        end
        enable <= 1; in <= 5'b00; @(posedge clk);
        for (i=0; i < 2**2; i++) begin
            in <= i;
            @(posedge clk);
        end
        @(posedge clk);
        $stop;
    end
endmodule

// -------------------------------------------------------

module dec3to8 (out, in, enable);
    output logic [7:0] out;
    input logic [2:0] in;
    input logic enable; // enable is out[0], out[1], ... from 2to4dec file

    logic nin0, nin1, nin2;

    not #(50) n0(nin0, in[0]);
    not #(50) n1(nin1, in[1]);
    not #(50) n2(nin2, in[2]);
    
    // buf #(50) b0(in0, in[0]);
    // buf #(50) b1(in1, in[1]);
    // buf #(50) b2(in2, in[2]);

    and #(50) e0(out[0], nin2, nin1, nin0, enable);
    and #(50) e1(out[1], nin2, nin1, in[0], enable);
    and #(50) e2(out[2], nin2, in[1], nin0, enable);
    and #(50) e3(out[3], nin2, in[1], in[0], enable);
    and #(50) e4(out[4], in[2], nin1, nin0, enable);
    and #(50) e5(out[5], in[2], nin1, in[0], enable);
    and #(50) e6(out[6], in[2], in[1], nin0, enable);
    and #(50) e7(out[7], in[2], in[1], in[0], enable);
endmodule

module dec3to8_testbench();
    logic [7:0] out;
    logic [2:0] in;
    logic enable;
    logic clk;

    dec3to8 dut (.*);

    parameter clk_period = 100;
    initial begin
        clk <= 0;
        forever #(clk_period/2) clk <= ~clk;
    end // initial clock

    integer i; 
	initial begin
        @(posedge clk);
        enable <= 0; in <= 5'b000; @(posedge clk);
        for (i=0; i < 2**3; i++) begin
            in <= i;
            @(posedge clk);
        end
        enable <= 1; in <= 5'b000; @(posedge clk);
        for (i=0; i < 2**3; i++) begin
            in <= i;
            @(posedge clk);
        end
        @(posedge clk);
        $stop;
    end
endmodule

// -------------------------------------------------------

module dec5to32 (out, in, enable);
    output logic [31:0] out;
    input logic [4:0] in;
    input logic enable; // this is RegWrite -- same enable as 2:4 decoder enable

    logic [3:0] out2to4;

    dec2to4 e(out2to4, in[4:3], enable);
    
    dec3to8 d0(out[7:0], in[2:0], out2to4[0]);
    dec3to8 d1(out[15:8], in[2:0], out2to4[1]);
    dec3to8 d2(out[23:16], in[2:0], out2to4[2]);
    dec3to8 d3(out[31:24], in[2:0], out2to4[3]);
endmodule

module dec5to32_testbench();
    logic [31:0] out;
    logic [4:0] in;
    logic enable;
    logic clk;

    dec5to32 dut (.*);

    parameter clk_period = 200;
    initial begin
        clk <= 0;
        forever #(clk_period/2) clk <= ~clk;
    end // initial clock

    integer i; 
	initial begin
        @(posedge clk);
        enable <= 0; in <= 5'b00000; @(posedge clk);
        for (i=0; i < 2**5; i++) begin
            in <= i;
            @(posedge clk);
        end
        enable <= 1; in <= 5'b00000; @(posedge clk);
        for (i=0; i < 2**5; i++) begin
            in <= i;
            @(posedge clk);
        end
        $stop;
    end
endmodule