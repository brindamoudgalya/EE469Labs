
`timescale 1ns/10ps
module regfile (ReadData1, ReadData2, ReadRegister1, ReadRegister2, WriteRegister, WriteData, RegWrite, clk, reset);
    output [63:0] ReadData1, ReadData2;
    input [4:0] ReadRegister1, ReadRegister2, WriteRegister;
    input [63:0] WriteData;
    input RegWrite, clk, reset;

    assign reset = 1'b0; // bit assignment is allowed 

    logic [31:0] writeEn;
    logic [31:0][63:0] regOut;

    dec5to32 d(writeEn, WriteRegister, RegWrite);

    reg64 r(regOut, WriteData, writeEn, clk, reset);
    
    assign regOut[31] = 64'b0;

    mux64x32to1 m1(ReadData1, reg_out, ReadRegister1);
    mux64x32to1 m2(ReadData2, reg_out, ReadRegister2);

endmodule