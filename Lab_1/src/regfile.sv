
`timescale 1ns/10ps
module regfile (ReadData1, ReadData2, ReadRegister1, ReadRegister2, WriteRegister, WriteData, RegWrite, clk, reset);
    output [63:0] ReadData1, ReadData2;
    input [4:0] ReadRegister1, ReadRegister2, WriteRegister;
    input [63:0] WriteData;
    input RegWrite, clk, reset;

    // assign reset = 1'b0; // bit assignment is allowed (but also driving reset = 0 but testbench driving it to 1 might conflict...)

    logic [31:0] writeEn;
    logic [30:0][63:0] regOut;

    dec5to32 d(writeEn, WriteRegister, RegWrite);

    reg64 r(regOut, WriteData, writeEn, clk, reset);
    
    // assign regOut[31] = 64'b0; // do this in reg64 itself

    mux64x32to1 m1(ReadData1, regOut, ReadRegister1);
    mux64x32to1 m2(ReadData2, regOut, ReadRegister2);

endmodule