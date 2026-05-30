// A full memory hierarchy. 
//
// Parameter:
// MODEL_NUMBER: A number used to specify a specific instance of the memory.  Different numbers give different hierarchies and settings.
//   This should be set to your student ID number.
// DMEM_ADDRESS_WIDTH: The number of bits of address for the memory.  Sets the total capacity of main memory.
//
// Accesses: To do an access, set address, data_in, byte_access, and write to a desired value, and set start_access to 1.
//   All these signals must be held constant until access_done, at which point the operation is completed.  On a read,
//   data_out will be set to the correct data for the single cycle when access_done is true.  Note that you can do
//   back-to-back accesses - when access_done is true, if you keep start_access true the memory will start the next access.
// 
//   When start_access = 0, the other input values do not matter.
//   bytemask controls which bytes are actually written (ignored on a read).
//     If bytemask[i] == 1, we do write the byte from data_in[8*i+7 : 8*i] to memory at the corresponding position.  If == 0, that byte not written.
//   To do a read: write = 0,  data_in does not matter.  data_out will have the proper data for the single cycle where access_done==1.
//   On a write, write = 1 and data_in must have the data to write.
//
//   Addresses must be aligned.  Since this is a 64-bit memory (8 bytes), the bottom 3 bits of each address must be 0.
//
//   It is an error to set start_access to 1 and then either set start_access to 0 or change any other input before access_done = 1.
//
//   Accessor tasks (essentially subroutines for testbenches) are provided below to help do most kinds of accesses.

// Line to set up the timing of simulation: says units to use are ns, and smallest resolution is 10ps.
`timescale 1ns/10ps

module lab5 #(parameter [22:0] MODEL_NUMBER = 1350364, parameter DMEM_ADDRESS_WIDTH = 20) (
	// Commands:
	//   (Comes from processor).
	input		logic [DMEM_ADDRESS_WIDTH-1:0]	address,			// The byte address.  Must be word-aligned if byte_access != 1.
	input		logic [63:0]							data_in,			// The data to write.  Ignored on a read.
	input		logic [7:0]								bytemask,		// Only those bytes whose bit is set are written.  Ignored on a read.
	input		logic										write,			// 1 = write, 0 = read.
	input		logic										start_access,	// Starts a memory access.  Once this is true, all command inputs must be stable until access_done becomes 1. 
	output	logic										access_done,	// Set to true on the clock edge that the access is completed.
	output	logic	[63:0]							data_out,		// Valid when access_done == 1 and access is a read.
	// Control signals:
	input		logic										clk,
	input		logic										reset				// A reset will invalidate all cache entries, and return main memory to the default initial values.
); 
	
	DataMemory #(.MODEL_NUMBER(MODEL_NUMBER), .DMEM_ADDRESS_WIDTH(DMEM_ADDRESS_WIDTH)) dmem
		(.address, .data_in, .bytemask, .write, .start_access, .access_done, .data_out, .clk, .reset);
	
	always @(posedge clk)
		assert(reset !== 0 || start_access == 0 || address[2:0] == 0); // All accesses must be aligned.
	
endmodule

// Test the data memory, and figure out the settings.

module lab5_testbench ();
	localparam USERID = 2337294;  // Set to your student ID #
	localparam ADDRESS_WIDTH = 20;
	localparam DATA_WIDTH = 8;
	
	logic [ADDRESS_WIDTH-1:0]			address;		   // The byte address.  Must be word-aligned if byte_access != 1.
	logic [63:0]							data_in;			// The data to write.  Ignored on a read.
	logic [7:0]								bytemask;		// Only those bytes whose bit is set are written.  Ignored on a read.
	logic										write;			// 1 = write, 0 = read.
	logic										start_access;	// Starts a memory access.  Once this is true, all command inputs must be stable until access_done becomes 1. 
	logic										access_done;	// Set to true on the clock edge that the access is completed.
	logic	[63:0]							data_out;		// Valid when access_done == 1 and access is a read.
	// Control signals:
	logic										clk;
	logic										reset;				// A reset will invalidate all cache entries, and return main memory to the default initial values.

	lab5 #(.MODEL_NUMBER(USERID), .DMEM_ADDRESS_WIDTH(ADDRESS_WIDTH)) dut
		(.address, .data_in, .bytemask, .write, .start_access, .access_done, .data_out, .clk, .reset); 

	// Set up the clock.
	parameter CLOCK_PERIOD=10;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end

	// Force %t's to print in a nice format.
	initial $timeformat(-9, 5, " ns", 10);

	// --- Keep track of number of clock cycles, for statistics.
	integer cycles;
	always @(posedge clk) begin
		if (reset)
			cycles <= 0;
		else
			cycles <= cycles + 1;
	end
		
	// --- Tasks are subroutines for doing various operations.  These provide read and write actions.
	
	// Set memory controls to an idle state, no accesses going.
	task mem_idle;
		address			<= 'x;
		data_in			<= 'x;
		bytemask			<= 'x;
		write				<= 'x;
		start_access	<= 0;
		#1;
	endtask
	
	// Perform a read, and return the resulting data in the read_data output.
	// Note: waits for complete cycle of "access_done", so spends 1 cycle more than the access time.
	task readMem;
		input		[ADDRESS_WIDTH-1:0]		read_addr;
		output	[DATA_WIDTH-1:0][7:0]	read_data;
		output	int							delay;		// Access time actually seen.
		
		int startTime, endTime;
		
		startTime = cycles;
		address			<= read_addr;
		data_in			<= 'x;
		bytemask			<= 'x;
		write				<= 0;
		start_access	<= 1;
		@(posedge clk);
		while (~access_done) begin
			@(posedge clk);
		end
		mem_idle(); #1;
		read_data = data_out;
		endTime = cycles;
		delay = endTime - startTime - 1;
	endtask
	
	function int min;
		input int x;
		input int y;
		
		min = ((x<y) ? x : y);
	endfunction
	function int max;
		input int x;
		input int y;
		
		max = ((x>y) ? x : y);
	endfunction
	
	// Perform a series of reads, and returns the min and max access times seen.
	// Accesses are at read_addr, read_addr+stride, read_addr+2*stride, ... read_addr+(num_reads-1)*stride.
	task readStride;
		input		[ADDRESS_WIDTH-1:0]		read_addr;
		input		int							stride;
		input		int							num_reads;
		output	int							min_delay;	// Fastest access time actually seen.
		output	int							max_delay;	// Slowest access time actually seen.
		
		int i, delay;
		logic [DATA_WIDTH-1:0][7:0]		read_data;
		
		//$display("%t readStride(%d, %d, %d)", $time, read_addr, stride, num_reads);
		readMem(read_addr, read_data, delay);
		min_delay = delay;
		max_delay = delay;
		//$display("1  delay: %d", delay);
		
		for(i=1; i<num_reads; i++) begin
			readMem(read_addr+stride*i, read_data, delay);
			min_delay = min(min_delay, delay);
			max_delay = max(max_delay, delay);
			//$display("2  delay: %d", delay);
		end
		//$display("%t min_delay: %d max_delay: %d", $time, min_delay, max_delay);

		mem_idle(); #1;
	endtask
	
	// Perform a write.
	// Note: waits for complete cycle of "access_done", so spends 1 cycle more than the access time.
	task writeMem;
		input [ADDRESS_WIDTH-1:0]			write_address;
		input [DATA_WIDTH-1:0][7:0]		write_data;
		input [DATA_WIDTH-1:0]				write_bytemask;
		output	int							delay;		// Access time actually seen.
		
		int	startTime, endTime;
		
		startTime = cycles;
		address			<= write_address;
		data_in			<= write_data;
		bytemask			<= write_bytemask;
		write				<= 1;
		start_access	<= 1;
		@(posedge clk);
		while (~access_done) begin
			@(posedge clk);
		end
		mem_idle(); #1;
		endTime = cycles;
		delay = endTime - startTime - 1;
	endtask
	
	// Perform a series of writes, and returns the min and max access times seen.
	// Accesses are at write_addr, write_addr+stride, write_addr+2*stride, ... write_addr+(num_writes-1)*stride.
	task writeStride;
		input		[ADDRESS_WIDTH-1:0]		write_addr;
		input		int							stride;
		input		int							num_writes;
		output	int							min_delay;	// Fastest access time actually seen.
		output	int							max_delay;	// Slowest access time actually seen.
		
		int i, delay;
		logic [DATA_WIDTH-1:0][7:0]		write_data;
		
		//$display("%t writeStride(%d, %d, %d)", $time, write_addr, stride, num_writes);
		writeMem(write_addr, write_data, 8'hFF, delay);
		min_delay = delay;
		max_delay = delay;
		//$display("1  delay: %d", delay);
		
		for(i=1; i<num_writes; i++) begin
			writeMem(write_addr+stride*i, write_data, 8'hFF, delay);
			min_delay = min(min_delay, delay);
			max_delay = max(max_delay, delay);
			//$display("2  delay: %d", delay);
		end
		//$display("%t min_delay: %d max_delay: %d", $time, min_delay, max_delay);

		mem_idle(); #1;
	endtask
	
	// Skip doing an access for a cycle.
	task noopMem;
		mem_idle();
		@(posedge clk); #1;
	endtask
	
	// Reset the memory.
	task resetMem;
		mem_idle();
		reset <= 1;
		@(posedge clk);
		reset <= 0;
		#1;
	endtask
	
	logic	[DATA_WIDTH-1:0][7:0]	dummy_data;
	logic [ADDRESS_WIDTH-1:0]		addr;
	int	i, delay, minval, maxval;
	
	initial begin
		dummy_data <= '0;

		resetMem();
        
        $display("-----------------------------------------");
        $display("HIT VS MISS TIMING");
        $display("-----------------------------------------");
        
        // read addr 0 : cache empty -> MISS
        readMem(64'd0, dummy_data, delay);
        $display("First read to Addr 0 (MISS) took: %d cycles", delay);
        
		// read addr 0 again : data in cache -> HIT
        readMem(64'd0, dummy_data, delay);
        $display("Second read to Addr 0 (HIT) took: %d cycles", delay);


        $display("-----------------------------------------");
        $display("BLOCK SIZE");
        $display("-----------------------------------------");
        
        // step by 8B too find block size 
		// (whenever there's a MISS, block size is that length since starting at addr 0)
        readMem(64'd8, dummy_data, delay);
        $display("Read Addr 8  took: %d cycles", delay);
        
        readMem(64'd16, dummy_data, delay);
        $display("Read Addr 16 took: %d cycles", delay);
        
        readMem(64'd24, dummy_data, delay);
        $display("Read Addr 24 took: %d cycles", delay);
        
        readMem(64'd32, dummy_data, delay);
        $display("Read Addr 32 took: %d cycles", delay);
        
        readMem(64'd64, dummy_data, delay);
        $display("Read Addr 64 took: %d cycles", delay);
        
		$display("-----------------------------------------");
        $display("SIZE, ASSOCIATIVITY");
        $display("-----------------------------------------");
        
        // jump 1024 (1 KB)
        resetMem();
        readMem(64'd0, dummy_data, delay);    // Pull Addr 0 into cache
        readMem(64'd1024, dummy_data, delay); // Read 1KB away
        readMem(64'd0, dummy_data, delay);    // Check if Addr 0 survived
        $display("After reading 1024, Addr 0 took: %d cycles", delay);

        // jump by 2048 (2 KB)
        resetMem();
        readMem(64'd0, dummy_data, delay);
        readMem(64'd2048, dummy_data, delay);
        readMem(64'd0, dummy_data, delay);
        $display("After reading 2048, Addr 0 took: %d cycles", delay);

		$display("-----------------------------------------");
        $display("L1 CAPACITY");
        $display("-----------------------------------------");
        
        // L1 block size = 16B
        // read chunk of memory, then check if addr 0 survived.
        
        // Test 128 Bytes
        resetMem();
        for(i = 0; i < 128; i = i + 16) readMem(64'(i), dummy_data, delay);
        readMem(64'd0, dummy_data, delay);
        $display("After reading 128 contiguous bytes, Addr 0 took: %d cycles", delay);

		// Test 129 Bytes
        resetMem();
        for(i = 0; i < 129; i = i + 16) readMem(64'(i), dummy_data, delay);
        readMem(64'd0, dummy_data, delay);
        $display("After reading 129 contiguous bytes, Addr 0 took: %d cycles", delay);
        
        // Test 256 Bytes
        resetMem();
        for(i = 0; i < 256; i = i + 16) readMem(64'(i), dummy_data, delay);
        readMem(64'd0, dummy_data, delay);
        $display("After reading 256 contiguous bytes, Addr 0 took: %d cycles", delay);
        

        $display("-----------------------------------------");
        $display("L1 WRITE POLICY");
        $display("-----------------------------------------");
        
        resetMem();
        // read addr 0 into L1
        readMem(64'd0, dummy_data, delay); 
        
        // write to addr 0
        writeMem(64'd0, dummy_data, 8'hFF, delay);
        $display("Writing to a cached L1 block took: %d cycles", delay);
        


		$display("-----------------------------------------");
        $display("L2 ASSOCIATIVITY");
        $display("-----------------------------------------");
        
        // 2 conflicts
        resetMem();
        readMem(64'd0, dummy_data, delay);     // Pull Addr 0 into L1 and L2
        readMem(64'd4096, dummy_data, delay);  // Conflict 1 (Guaranteed to evict 0 from L1)
        readMem(64'd8192, dummy_data, delay);  // Conflict 2
        readMem(64'd0, dummy_data, delay);     // Check Addr 0 again
        $display("After 2 conflicts, Addr 0 took: %d cycles", delay);
        
        // 4 conflicts
        resetMem();
        readMem(64'd0, dummy_data, delay);
        readMem(64'd4096, dummy_data, delay); 
        readMem(64'd8192, dummy_data, delay);
        readMem(64'd12288, dummy_data, delay);
        readMem(64'd16384, dummy_data, delay); 
        readMem(64'd0, dummy_data, delay);
        $display("After 4 conflicts, Addr 0 took: %d cycles", delay);

		// 8 conflicts
        resetMem();
        readMem(64'd0, dummy_data, delay);
        readMem(64'd4096, dummy_data, delay); 
        readMem(64'd8192, dummy_data, delay);
        readMem(64'd12288, dummy_data, delay);
        readMem(64'd16384, dummy_data, delay); 
		readMem(64'd20480, dummy_data, delay); 
        readMem(64'd24576, dummy_data, delay);
        readMem(64'd28672, dummy_data, delay);
        readMem(64'd32768, dummy_data, delay); 
        readMem(64'd0, dummy_data, delay);
        $display("After 8 conflicts, Addr 0 took: %d cycles", delay);

        $display("-----------------------------------------");
        $display("L2 CAPACITY");
        $display("-----------------------------------------");
        
        // read contiguous memory, jumping by 32 bytes (L2 Block Size).
        // more than 128 bytes : L1 will ALWAYS miss. 
        // seeing if L2 hits (14 cycles) or misses (109 cycles).

		// 256 Bytes (1 KB)
        resetMem();
        for(i = 0; i < 256; i = i + 32) readMem(64'(i), dummy_data, delay);
        readMem(64'd0, dummy_data, delay);
        $display("After reading 256 contiguous bytes, Addr 0 took: %d cycles", delay);

		// 512 Bytes (1 KB)
        resetMem();
        for(i = 0; i < 512; i = i + 32) readMem(64'(i), dummy_data, delay);
        readMem(64'd0, dummy_data, delay);
        $display("After reading 512 contiguous bytes, Addr 0 took: %d cycles", delay);
        
        // 1024 Bytes (1 KB)
        resetMem();
        for(i = 0; i < 1024; i = i + 32) readMem(64'(i), dummy_data, delay);
        readMem(64'd0, dummy_data, delay);
        $display("After reading 1024 contiguous bytes, Addr 0 took: %d cycles", delay);
        
        // 2048 Bytes (2 KB)
        resetMem();
        for(i = 0; i < 2048; i = i + 32) readMem(64'(i), dummy_data, delay);
        readMem(64'd0, dummy_data, delay);
        $display("After reading 2048 contiguous bytes, Addr 0 took: %d cycles", delay);

        // 4096 Bytes (4 KB)
        resetMem();
        for(i = 0; i < 4096; i = i + 32) readMem(64'(i), dummy_data, delay);
        readMem(64'd0, dummy_data, delay);
        $display("After reading 4096 contiguous bytes, Addr 0 took: %d cycles", delay);

        $display("-----------------------------------------");
        $display("L2 WRITE POLICY");
        $display("-----------------------------------------");
        
        // We need to write to a block that is in L2, but NOT in L1.
        resetMem();
        readMem(64'd0, dummy_data, delay);    // Pull Addr 0 into L1 and L2
        readMem(64'd128, dummy_data, delay);  // Read Addr 128 to kick Addr 0 out of L1 ONLY
        writeMem(64'd0, dummy_data, 8'hFF, delay); // Write to Addr 0 (which is now only in L2)
        $display("Writing to a cached L2 block took: %d cycles", delay);

        $display("-----------------------------------------");
        $display("L3 BLOCK SIZE");
        $display("-----------------------------------------");
        
        resetMem();
        // read addr 0 (MISS -- 109cc)
        // pulls block into L1, L2, and L3.
        readMem(64'd0, dummy_data, delay);
        
        // L2 block size = 32 bytes -- addr 32 not in L1 or L2
        // But if the L3 block is 64 bytes long, Addr 32 WILL BE in L3

		readMem(64'd16, dummy_data, delay);
        $display("Read Addr 16 took: %d cycles", delay);

        readMem(64'd32, dummy_data, delay);
        $display("Read Addr 32 took: %d cycles", delay);
        
        readMem(64'd64, dummy_data, delay);
        $display("Read Addr 64 took: %d cycles", delay);

        $display("-----------------------------------------");
        $display("L3 CAPACITY");
        $display("-----------------------------------------");
        
        // overflow L3 (44 cycles) and force MM hit (109 cycles).
        resetMem();
        for(i = 0; i < 4096; i = i + 64) readMem(64'(i), dummy_data, delay);
        readMem(64'd0, dummy_data, delay);
        $display("After 4KB contiguous, Addr 0 took: %d cycles", delay);

        resetMem();
        for(i = 0; i < 8192; i = i + 64) readMem(64'(i), dummy_data, delay);
        readMem(64'd0, dummy_data, delay);
        $display("After 8KB contiguous, Addr 0 took: %d cycles", delay);
        
        // 16 KB
        resetMem();
        for(i = 0; i < 16384; i = i + 32) readMem(64'(i), dummy_data, delay);
        readMem(64'd0, dummy_data, delay);
        $display("After 16KB contiguous, Addr 0 took: %d cycles", delay);

        // 32 KB
        resetMem();
        for(i = 0; i < 32768; i = i + 32) readMem(64'(i), dummy_data, delay);
        readMem(64'd0, dummy_data, delay);
        $display("After 32KB contiguous, Addr 0 took: %d cycles", delay);
        
        // 64 KB
        resetMem();
        for(i = 0; i < 65536; i = i + 32) readMem(64'(i), dummy_data, delay);
        readMem(64'd0, dummy_data, delay);
        $display("After 64KB contiguous, Addr 0 took: %d cycles", delay);

		$display("-----------------------------------------");
        $display("L3 ASSOCIATIVITY");
        $display("-----------------------------------------");
        
        // direct mapped?
        resetMem();
        readMem(64'd0, dummy_data, delay);
        readMem(64'd8192, dummy_data, delay); // Jump by exactly 8KB
        readMem(64'd0, dummy_data, delay);
        $display("After 1 conflict (8KB jump), Addr 0 took:  %d cycles", delay);

        // 2 conflicts
        resetMem();
        readMem(64'd0, dummy_data, delay);
        readMem(64'd8192, dummy_data, delay);
        readMem(64'd16384, dummy_data, delay);
        readMem(64'd0, dummy_data, delay);
        $display("After 2 conflicts, Addr 0 took: %d cycles", delay);

        // 4 conflicts
        resetMem();
        readMem(64'd0, dummy_data, delay);
        readMem(64'd8192, dummy_data, delay);
        readMem(64'd16384, dummy_data, delay);
        readMem(64'd24576, dummy_data, delay);
        readMem(64'd32768, dummy_data, delay);
        readMem(64'd0, dummy_data, delay);
        $display("After 4 conflicts, Addr 0 took: %d cycles", delay);
        
        // 8 conflicts
        resetMem();
        readMem(64'd0, dummy_data, delay);
        readMem(64'd8192, dummy_data, delay);
        readMem(64'd16384, dummy_data, delay);
        readMem(64'd24576, dummy_data, delay);
        readMem(64'd32768, dummy_data, delay);
        readMem(64'd40960, dummy_data, delay);
        readMem(64'd49152, dummy_data, delay);
        readMem(64'd57344, dummy_data, delay);
        readMem(64'd65536, dummy_data, delay);
        readMem(64'd0, dummy_data, delay);
        $display("After 8 conflicts, Addr 0 took: %d cycles", delay);

        // 16 conflicts
        resetMem();
        readMem(64'd0, dummy_data, delay);
        for(i = 1; i <= 16; i = i + 1) readMem(64'(i * 8192), dummy_data, delay);
        readMem(64'd0, dummy_data, delay);
        $display("After 16 conflicts, Addr 0 took:%d cycles", delay);

		// 32 conflicts
        resetMem();
        readMem(64'd0, dummy_data, delay);
        for(i = 1; i <= 32; i = i + 1) readMem(64'(i * 8192), dummy_data, delay);
        readMem(64'd0, dummy_data, delay);
        $display("After 32 conflicts, Addr 0 took:%d cycles", delay);

		// 64 conflicts
        resetMem();
        readMem(64'd0, dummy_data, delay);
        for(i = 1; i <= 64; i = i + 1) readMem(64'(i * 8192), dummy_data, delay);
        readMem(64'd0, dummy_data, delay);
        $display("After 64 conflicts, Addr 0 took:%d cycles", delay);

		// 128 conflicts
        resetMem();
        readMem(64'd0, dummy_data, delay);
        for(i = 1; i <= 128; i = i + 1) readMem(64'(i * 8192), dummy_data, delay);
        readMem(64'd0, dummy_data, delay);
        $display("After 128 conflicts, Addr 0 took:%d cycles", delay);

		// 256 conflicts
        resetMem();
        readMem(64'd0, dummy_data, delay);
        for(i = 1; i <= 256; i = i + 1) readMem(64'(i * 8192), dummy_data, delay);
        readMem(64'd0, dummy_data, delay);
        $display("After 256 conflicts, Addr 0 took:%d cycles", delay);

        $display("-----------------------------------------");
        $display("L3 WRITE POLICY");
        $display("-----------------------------------------");
        
        resetMem();
        readMem(64'd0, dummy_data, delay);     // Pull Addr 0 into L1, L2, L3
        readMem(64'd1024, dummy_data, delay);  // Read Addr 1024 to kick Addr 0 out of L1 and L2
        writeMem(64'd0, dummy_data, 8'hFF, delay); // Write to Addr 0 (which is now ONLY in L3)
        $display("Writing to a cached L3 block took: %d cycles", delay);

		$display("-----------------------------------------");
        $display("L3 REPLACEMENT");
        $display("-----------------------------------------");
        
        resetMem();
        // fill 8-way L2 Set
        readMem(64'd0, dummy_data, delay);
        readMem(64'd4096, dummy_data, delay); 
        readMem(64'd8192, dummy_data, delay);
        readMem(64'd12288, dummy_data, delay);
        readMem(64'd16384, dummy_data, delay); 
        readMem(64'd20480, dummy_data, delay); 
        readMem(64'd24576, dummy_data, delay);
        readMem(64'd28672, dummy_data, delay);
        
        // refresh addr0 (most recently used)
        readMem(64'd0, dummy_data, delay);
        
        // one eviction
        readMem(64'd32768, dummy_data, delay);
        
        // if addr0 survives then LRU replacement
        readMem(64'd0, dummy_data, delay);
        
        if (delay == 14) $display("Address 0 Survived in L2 (14 cycles) -> Strategy is 1 (LRU)!");
        if (delay == 44) $display("Address 0 was Evicted to L3 (44 cycles) -> Strategy is 0 (Random)!");

        $display("-----------------------------------------");

        $stop();

		/*	
		// THIS IS THE GIVEN CODE, BUT I AM COMMENTING 
		// IT OUT BECAUSE I DONT THINK IT ACTUALLY DOES ANYTHING
		resetMem();				// Initialize the memory.
		
		// Do 20 random reads.
		for (i=0; i<20; i++) begin
			addr = $random()*8; // *8 to doubleword-align the access.
			readMem(addr, dummy_data, delay);
			$display("%t Read took %d cycles", $time, delay);
		end
		
		// Do 5 random double-word writes of random data.
		for (i=0; i<5; i++) begin
			addr = $random()*8; // *8 to doubleword-align the access.
			dummy_data = $random();
			writeMem(addr, dummy_data, 8'hFF, delay);
			$display("%t Write took %d cycles", $time, delay);
		end
		
		// Reset the memory.
		resetMem();
		
		// Read all of the first KB
		readStride(0, 8, 1024/8, minval, maxval);
		$display("%t Reading the first KB took between %d and %d cycles each", $time, minval, maxval);

		$stop();
		*/

	end
	
endmodule
