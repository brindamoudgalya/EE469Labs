
`timescale 1ps/1ps
module alu (A, B, cntrl, result, negative, zero, overflow, carry_out);
    output logic [63:0] result;
    output logic zero, overflow, carry_out, negative;
    input logic [2:0] cntrl;
    input logic [63:0] A, B;

    logic [63:0] notB;

    logic [63:0] add_out, sub_out, and_out, or_out, xor_out;
    logic add_zero, sub_zero, and_zero, or_zero, xor_zero;
    logic add_negative, sub_negative, and_negative, or_negative, xor_negative;
    logic add_overflow, sub_overflow;
    logic add_carry_out, sub_carry_out;

    genvar i;
    generate
        for (i = 0; i < 64; i++) begin : invert_B
            not #(50) n1(notB[i], B[i]);
        end
    endgenerate

    logic [7:0] temp_overall_out;

    // 000:
    // B is just the 64 bit input B

    // 001:
    //empty for now

    // 010:
    adder add(add_out, add_zero, add_overflow, add_carry_out, add_negative, A, B, 1'b0);

    // 011:
    adder sub(sub_out, sub_zero, sub_overflow, sub_carry_out, sub_negative, A, notB, 1'b1);

    // 100:
    and64 a64(and_out, and_zero, and_negative, A, B);

    // 101:
    or64 o64(or_out, or_zero, or_negative, A, B);

    // 110:
    xor64 x64(xor_out, xor_zero, xor_negative, A, B);

    // 111:
    // empty for now

    // assign temp_overall_out[0] = B[0];
    // assign temp_overall_out[1] = 1'b0;
    // assign temp_overall_out[2] = add_out;
    // assign temp_overall_out[3] = sub_out;
    // assign temp_overall_out[4] = and_out;
    // assign temp_overall_out[5] = or_out;
    // assign temp_overall_out[6] = xor_out;
    // assign temp_overall_out[7] = 1'b0;

    generate
        for (i = 0; i < 64; i++) begin : alu_64_mux_out
            mux8to1 m81(result[i], {1'b0, xor_out[i], or_out[i], and_out[i], sub_out[i], add_out[i], 1'b0, B[i]}, cntrl);
        end
    endgenerate

    // generate
    //     for (i = 0; i < 64; i++) begin : alu_64_mux_out
    //         mux8to1 m81(out[i], temp_overall_out, control);
    //     end
    // endgenerate

    mux2to1 m21_1(overflow, add_overflow, sub_overflow, cntrl[2]);
    mux2to1 m21_2(carry_out, add_carry_out, sub_carry_out, cntrl[2]);

    set_zero z(zero, result); // set zero flag
    assign negative = result[63]; // set negative flag

endmodule

module mux8to1 (out, in, sel);
    output logic out;
    input logic [7:0] in;
    input logic [2:0] sel;

    logic [3:0] l0out;
    logic [1:0] l1out;

    genvar i;
    generate
        for (i=0; i < 4; i++) begin : l0
            mux2to1 m(l0out[i], in[2*i], in[2*i + 1], sel[0]);
        end
        for (i=0; i < 2; i++) begin : l1
            mux2to1 m(l1out[i], l0out[2*i], l0out[2*i + 1], sel[1]);
        end
    endgenerate
    
    mux2to1 final_m(out, l1out[0], l1out[1], sel[2]);
endmodule

module and64 (out, zero, negative, A, B);
    output logic [63:0] out;
    output logic zero, negative;
    input logic [63:0] A, B;

    genvar i;
    generate
        for (i = 0; i < 64; i++) begin : and64_gen
            and #(50) a_i(out[i], A[i], B[i]);
        end
    endgenerate

    assign negative = out[63]; // set negative flag

    // set zero flag (could modularize but i'm too lazy.)
    generate
        logic [15:0] l1_out;
        logic [3:0] l2_out;
        for (i=0; i<16; i++) begin : zero_tree_1
            logic n1, n2, n3, n4;
            not #(50) n_1(n1, out[i*4]);
            not #(50) n_2(n2, out[i*4 + 1]);
            not #(50) n_3(n3, out[i*4 + 2]);
            not #(50) n_4(n4, out[i*4 + 3]);

            and #(50) a1(l1_out[i], n1, n2, n3, n4);
        end
        for (i=0; i<4; i++) begin : zero_tree_2
            and #(50) a2(l2_out[i], l1_out[i*4], l1_out[i*4 + 1], l1_out[i*4 + 2], l1_out[i*4 + 3]);
        end
    
        and #(50) a3(zero, l2_out[0], l2_out[1], l2_out[2], l2_out[3]);
    endgenerate
endmodule

module and64_testbench();
    logic [63:0] out;
    logic zero, negative;
    logic [63:0] A, B;

    logic clk;

    and64 dut (.*);

    parameter clk_period = 5000;
    initial begin
        clk <= 0;
        forever #(clk_period/2) clk <= ~clk;
    end // initial clock

    integer i; 
	initial begin
        A = 64'd32048757332184;
        B = 64'd18374639302174648;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);

        A = 64'd37465648292192;
        B = 64'd0284748266;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);

        A = 64'hFFFFFFFFFFFFFFFF;
        B = 64'hFFFFFFFFFFFFFFFF; // out should be negative
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);

        A = 64'hF000000000000000;
        B = 64'hFFFFFFFFFFFFFFFF; // out should be negative
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);

        A = 64'b0000000000000000000000000000000000000000000000000000000000000000;
        B = 64'b0000000000000000000000000000000000000000000000000000000000000000; // out should be 0
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);

        $stop;
    end
endmodule

module or64(out, zero, negative, A, B);
    output logic [63:0] out;
    output logic zero, negative;
    input logic [63:0] A, B;

    genvar i;
    generate
        for (i = 0; i < 64; i++) begin : or64_gen
            or #(50) a_i(out[i], A[i], B[i]);
        end
    endgenerate

    assign negative = out[63]; // set negative flag

    // set zero flag
    generate
        logic [15:0] l1_out;
        logic [3:0] l2_out;
        for (i=0; i<16; i++) begin : zero_tree_1
            logic n1, n2, n3, n4;
            not #(50) n_1(n1, out[i*4]);
            not #(50) n_2(n2, out[i*4 + 1]);
            not #(50) n_3(n3, out[i*4 + 2]);
            not #(50) n_4(n4, out[i*4 + 3]);

            and #(50) a1(l1_out[i], n1, n2, n3, n4);
        end
        for (i=0; i<4; i++) begin : zero_tree_2
            and #(50) a2(l2_out[i], l1_out[i*4], l1_out[i*4 + 1], l1_out[i*4 + 2], l1_out[i*4 + 3]);
        end
    
        and #(50) a3(zero, l2_out[0], l2_out[1], l2_out[2], l2_out[3]);
    endgenerate
endmodule

module or64_testbench();
    logic [63:0] out;
    logic zero, negative;
    logic [63:0] A, B;

    logic clk;

    or64 dut (.*);

    parameter clk_period = 5000;
    initial begin
        clk <= 0;
        forever #(clk_period/2) clk <= ~clk;
    end // initial clock

    integer i; 
	initial begin
        A = 64'd32048757332184;
        B = 64'd18374639302174648;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);

        A = 64'd37465648292192;
        B = 64'd0284748266;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        $stop;
    end
endmodule

module xor64(out, zero, negative, A, B);
    output logic [63:0] out;
    output logic zero, negative;
    input logic [63:0] A, B;

    genvar i;
    generate
        for (i = 0; i < 64; i++) begin : xor64_gen
            xor #(50) a_i(out[i], A[i], B[i]);
        end
    endgenerate

    assign negative = out[63]; // set negative flag

    // set zero flag
    generate
        logic [15:0] l1_out;
        logic [3:0] l2_out;
        for (i=0; i<16; i++) begin : zero_tree_1
            logic n1, n2, n3, n4;
            not #(50) n_1(n1, out[i*4]);
            not #(50) n_2(n2, out[i*4 + 1]);
            not #(50) n_3(n3, out[i*4 + 2]);
            not #(50) n_4(n4, out[i*4 + 3]);

            and #(50) a1(l1_out[i], n1, n2, n3, n4);
        end
        for (i=0; i<4; i++) begin : zero_tree_2
            and #(50) a2(l2_out[i], l1_out[i*4], l1_out[i*4 + 1], l1_out[i*4 + 2], l1_out[i*4 + 3]);
        end
    
        and #(50) a3(zero, l2_out[0], l2_out[1], l2_out[2], l2_out[3]);
    endgenerate
endmodule

module xor64_testbench();
    logic [63:0] out;
    logic zero, negative;
    logic [63:0] A, B;

    logic clk;

    xor64 dut (.*);

    parameter clk_period = 5000;
    initial begin
        clk <= 0;
        forever #(clk_period/2) clk <= ~clk;
    end // initial clock

    integer i; 
	initial begin
        A = 64'd32048757332184;
        B = 64'd18374639302174648;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);

        A = 64'd37465648292192;
        B = 64'd0284748266;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        $stop;
    end
endmodule


module adder (sum, zero, overflow, carry_out, negative, A, B, carry_in);
    output logic [63:0] sum;
    output logic zero, overflow, carry_out, negative;
    input logic [63:0] A, B;
    input logic carry_in;

    logic [63:0] c_out;
    logic [64:0] c_in;
    assign c_in[0] = carry_in;

    genvar i;
    generate
        for (i=0; i<64; i++) begin : addition
            logic base_add;
            logic a_b, b_c, a_c;

            // assign sum = a xor b xor c_in, at index i
            xor #(50) s(base_add, A[i], B[i], c_in[i]);
            assign sum[i] = base_add; // set sum

            // assign c_out = ab + ac + bc
            and #(50) ab(a_b, A[i], B[i]);
            and #(50) ac(a_c, A[i], c_in[i]);
            and #(50) bc(b_c, B[i], c_in[i]);
            or #(50) majority(c_out[i], a_b, a_c, b_c);

            assign c_in[i+1] = c_out[i];
        end
    endgenerate

    // xor #(50) v(overflow, c_in[63], c_out[63]); // set overflow flag (for 2C addition)
    assign overflow = c_in[64]; // unsigned addition: if there is overall c_out at all, it's overflow
    // assign negative = sum[63]; // set negative flag
    assign carry_out = c_out[63]; // assign carryout

    // // set zero flag
    // generate
    //     logic [15:0] l1_out;
    //     logic [3:0] l2_out;
    //     for (i=0; i<16; i++) begin : zero_tree_1
    //         logic n1, n2, n3, n4;
    //         not #(50) n_1(n1, sum[i*4]);
    //         not #(50) n_2(n2, sum[i*4 + 1]);
    //         not #(50) n_3(n3, sum[i*4 + 2]);
    //         not #(50) n_4(n4, sum[i*4 + 3]);

    //         and #(50) a1(l1_out[i], n1, n2, n3, n4);
    //     end
    //     for (i=0; i<4; i++) begin : zero_tree_2
    //         and #(50) a2(l2_out[i], l1_out[i*4], l1_out[i*4 + 1], l1_out[i*4 + 2], l1_out[i*4 + 3]);
    //     end
    
    //     and #(50) a3(zero, l2_out[0], l2_out[1], l2_out[2], l2_out[3]);
    // endgenerate
endmodule

module adder_testbench();
    logic [63:0] sum;
    logic zero, overflow, carry_out, negative;
    logic [63:0] A, B;

    logic clk;

    adder dut (.*);

    parameter clk_period = 5000;
    initial begin
        clk <= 0;
        forever #(clk_period/2) clk <= ~clk;
    end // initial clock

    integer i; 
	initial begin
        // for (i = 0; i < 2**10; i++) begin
        //     A = 
        // end

        A = 64'd10;
        B = 64'd21;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);

        A = 64'd233;
        B = 64'd398;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);

        A = 64'd678;
        B = 64'd876;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);

        A = 64'd10287387847289;
        B = 64'd483728405748576869;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);

        A = 64'd1009384572857362;
        B = 64'd22874567803425679;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);

        A = 64'd1;
        B = (2**64)-1;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);

        A = 64'd0;
        B = (2**64)-1;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);

        // overflow test
        A = 64'b0111111111111111111111111111111111111111111111111111111111111111;
        B = 64'd1;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);

        $stop;
    end
endmodule

module set_zero (zero, sum);
    output logic zero;
    input logic [63:0] sum;

    genvar i;
    generate
        logic [15:0] l1_out;
        logic [3:0] l2_out;
        for (i=0; i<16; i++) begin : zero_tree_1
            logic n1, n2, n3, n4;
            not #(50) n_1(n1, sum[i*4]);
            not #(50) n_2(n2, sum[i*4 + 1]);
            not #(50) n_3(n3, sum[i*4 + 2]);
            not #(50) n_4(n4, sum[i*4 + 3]);

            and #(50) a1(l1_out[i], n1, n2, n3, n4);
        end
        for (i=0; i<4; i++) begin : zero_tree_2
            and #(50) a2(l2_out[i], l1_out[i*4], l1_out[i*4 + 1], l1_out[i*4 + 2], l1_out[i*4 + 3]);
        end
    
        and #(50) a3(zero, l2_out[0], l2_out[1], l2_out[2], l2_out[3]);
    endgenerate
endmodule