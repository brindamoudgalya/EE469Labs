
`timescale 1ns/10ps
module adder (sum, zero, overflow, carry_out, negative, A, B);
    output logic [63:0] sum;
    output logic zero, overflow, carry_out, negative;
    input logic [63:0] A, B;

    logic [63:0] c_out;
    logic [64:0] c_in;
    assign c_in[0] = 1'b0;

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

    xor #(50) v(overflow, c_in[63], c_out[63]); // set overflow flag (for 2C addition)
    // assign overflow = c_in[64]; // unsigned addition: if there is overall c_out at all, it's overflow
    assign negative = sum[63]; // set negative flag
    assign carry_out = c_out[63]; // assign carryout

    // set zero flag
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