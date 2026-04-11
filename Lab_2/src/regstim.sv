// Test bench for Register file
`timescale 1ps/1ps

module regstim(); 		

	parameter ClockDelay = 5000;

	logic	[4:0] 	ReadRegister1, ReadRegister2, WriteRegister;
	logic [63:0]	WriteData;
	logic 			RegWrite, clk, reset; // CHANGED THIS: added "reset"
	logic [63:0]	ReadData1, ReadData2;

	integer i;

	// Your register file MUST be named "regfile".
	// Also you must make sure that the port declarations
	// match up with the module instance in this stimulus file.
	regfile dut (.ReadData1, .ReadData2, .WriteData, 
					 .ReadRegister1, .ReadRegister2, .WriteRegister,
					 .RegWrite, .clk, .reset); // CHANGED THIS: added ".reset"

	// Force %t's to print in a nice format.
	initial $timeformat(-9, 2, " ns", 10);

	initial begin // Set up the clock
		clk <= 0;
		forever #(ClockDelay/2) clk <= ~clk;
	end

	initial begin
		// CHANGED THIS: hold reset for 1 cycle to clear regs
		reset <= 1;
		RegWrite <= 0;
		ReadRegister1 <= 5'd0;
		ReadRegister2 <= 5'd0;
		WriteRegister <= 5'd0;
		WriteData <= 64'h0;
		@(posedge clk);
		reset <= 0;

		// Try to write the value 0xA0 into register 31.
		// Register 31 should always be at the value of 0.
		RegWrite <= 5'd0;
		ReadRegister1 <= 5'd0;
		ReadRegister2 <= 5'd0;
		WriteRegister <= 5'd31;
		WriteData <= 64'h00000000000000A0;
		@(posedge clk);
		
		$display("%t Attempting overwrite of register 31, which should always be 0", $time);
		RegWrite <= 1;
		@(posedge clk);

		// CHANGED THIS: verify reg 31 reads 0 on both ports
		$display("%t Verifying register 31 is hardwired to 0.", $time);
		RegWrite <= 0;
		ReadRegister1 <= 5'd31;
		ReadRegister2 <= 5'd31;
		@(posedge clk);
		$display("%t ReadData1 (R31) = %h (expected 0)", $time, ReadData1);
		$display("%t ReadData2 (R31) = %h (expected 0)", $time, ReadData2);

		// Write a value into each  register.
		$display("%t Writing pattern to all registers.", $time);
		for (i=0; i<31; i=i+1) begin
			RegWrite <= 0;
			ReadRegister1 <= i-1;
			ReadRegister2 <= i;
			WriteRegister <= i;
			WriteData <= i*64'h0000010204080001;
			@(posedge clk);
			
			RegWrite <= 1;
			@(posedge clk);
		end

		// Go back and verify that the registers
		// retained the data.
		$display("%t Checking pattern.", $time);
		for (i=0; i<32; i=i+1) begin
			RegWrite <= 0;
			ReadRegister1 <= i-1;
			ReadRegister2 <= i;
			WriteRegister <= i;
			WriteData <= i*64'h0000000000000100+i;
			@(posedge clk);
		end

		// CHANGED THIS: verify RegWrite=0 doesn't overwrite existing reg
		$display("%t Verifying RegWrite=0 does not overwrite register 0.", $time);
		RegWrite <= 0;
		ReadRegister1 <= 5'd0;
		ReadRegister2 <= 5'd0;
		WriteRegister <= 5'd0;
		WriteData <= 64'hDEADBEEFDEADBEEF;	// should be ignored
		@(posedge clk);
		$display("%t ReadData1 (R0) = %h (should match written pattern, not DEADBEEF)", $time, ReadData1);

		// CHANGED THIS: overwrite reg 5 with new value, confirm value
		$display("%t Overwriting register 5 with 0xCAFEBABECAFEBABE.", $time);
		RegWrite <= 0;
		WriteRegister <= 5'd5;
		WriteData <= 64'hCAFEBABECAFEBABE;
		@(posedge clk);
		RegWrite <= 1;
		@(posedge clk);
		RegWrite <= 0;
		ReadRegister1 <= 5'd5;
		ReadRegister2 <= 5'd5;
		@(posedge clk);
		$display("%t ReadData1 (R5) = %h (expected CAFEBABEcafebabe)", $time, ReadData1);
 
		// CHANGED THIS: verify both read ports return diff regs simultaneously
		$display("%t Checking independent read ports.", $time);
		RegWrite <= 0;
		ReadRegister1 <= 5'd1;
		ReadRegister2 <= 5'd2;
		@(posedge clk);
		$display("%t ReadData1 (R1) = %h", $time, ReadData1);
		$display("%t ReadData2 (R2) = %h", $time, ReadData2);
 
		// CHANGED THIS: apply reset and confirm all writeEn-ed regs clear to 0
		$display("%t Applying reset, all registers should clear to 0.", $time);
		reset <= 1;
		@(posedge clk);
		reset <= 0;
		for (i=0; i<32; i=i+1) begin
			RegWrite <= 0;
			ReadRegister1 <= i;
			ReadRegister2 <= i;
			@(posedge clk);
			$display("%t After reset: R%0d = %h (expected 0)", $time, i, ReadData1);
		end
		$stop;
	end
endmodule
