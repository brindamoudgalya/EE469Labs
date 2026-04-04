
module 2to4dec (out, in, enable);
    output logic [3:0] out;
    input logic [1:0] in;
    input logic enable; // enable is RegWrite

    logic nin0, nin1, in0, in1;

    // CAN'T USE "~" >:(
    not #(50) n0(nin0, in[0]);
    not #(50) n1(nin1, in[1]);

    // and there is a weird in-between state for ANDs when one inp passes thru negation (50ps delay) and other inp doesn't (0ps delay). so:
    buf #(50) b0(in0, in[0]);
    buf #(50) b1(in1, in[1]);

    and #(50) e0(out[0], nin1, nin0, enable);
    and #(50) e1(out[1], nin1, in0, enable);
    and #(50) e2(out[2], in1, nin0, enable);
    and #(50) e3(out[3], in1, in0, enable);
endmodule

module 2to4dec_testbench();
    logic [31:0] out;
    logic [4:0] in;
    logic enable;

    5to32dec dut (.*);

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
    end
endmodule

// -------------------------------------------------------

module 3to8dec (out, in, enable);
    output logic [7:0] out;
    input logic [2:0] in;
    input logic enable; // enable is out[0], out[1], ... from 2to4dec file

    logic nin0, nin1, nin2;

    not #(50) n0(nin0, in[0]);
    not #(50) n1(nin1, in[1]);
    not #(50) n2(nin2, in[2]);
    
    buf #(50) b0(in0, in[0]);
    buf #(50) b1(in1, in[1]);
    buf #(50) b2(in2, in[2]);

    and #(50) e0(out[0], nin2, nin1, nin0, enable);
    and #(50) e1(out[1], nin2, nin1, in0, enable);
    and #(50) e2(out[2], nin2, in0, nin0, enable);
    and #(50) e3(out[3], nin2, in1, in0, enable);
    and #(50) e4(out[4], in2, nin1, nin0, enable);
    and #(50) e5(out[5], in2, nin1, in0, enable);
    and #(50) e6(out[6], in2, in1, nin0, enable);
    and #(50) e7(out[7], in2, in1, in0, enable);
endmodule

module 3to8dec_testbench();
    logic [31:0] out;
    logic [4:0] in;
    logic enable;

    5to32dec dut (.*);

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
    end
endmodule

// -------------------------------------------------------

module 5to32dec (out, in, enable);
    output logic [31:0] out;
    input logic [4:0] in;
    input logic enable; // this is RegWrite -- same enable as 2:4 decoder enable

    logic [3:0] 2to4out;

    2to4dec e(2to4out, in[1:0], enable);
    
    3to8dec d0(out[7:0], in[4:2], 2to4out[0]);
    3to8dec d1(out[15:8], in[4:2], 2to4out[1]);
    3to8dec d2(out[23:16], in[4:2], 2to4out[2]);
    3to8dec d3(out[31:24], in[4:2], 2to4out[3]);
endmodule

module 5to32dec_testbench();
    logic [31:0] out;
    logic [4:0] in;
    logic enable;

    5to32dec dut (.*);

    parameter clk_period = 100;
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
    end
endmodule