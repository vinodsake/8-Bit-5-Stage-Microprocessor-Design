//-----------------------------------------------------------------------------
//
// Title       : Program Counter Testbench
// Author      : vinod sake <vinosake@pdx.edu>
// Company     : Student
//
//-----------------------------------------------------------------------------
//
// File        : program_counter_tb.sv
// Generated   : 15 Dec 2016
// Last Updated: 
//-----------------------------------------------------------------------------
//
// Description : Performing Testing on program counter with diffrerent modes
//		 
//		 	
//-----------------------------------------------------------------------------

`include "program_counter.sv"

`timescale 1 ns / 10 ps

module program_counter_test();
logic clock = 1'b0;			// system clock
logic reset = 1'b1; 			// Active low reset
logic increment = 1'b0;			// set high from external source	
logic jump_set = 1'b0; 			// set high from external source
logic[15:0] jumpcount = 16'hfffe; 	// Input value to the counter
logic[15:0] count; 			// Counter output for accessing memory

// Clock
initial clock = 1'b0;
always #50 clock = !clock; // 100 time ticks per cycle = 10 MHz clock

program_counter pc_dut(
	.clock(clock), 
	.reset(reset), 
	.increment(increment), 
	.jump_set(jump_set), 
	.jumpcount(jumpcount), 
	.count(count)
);

// Test
initial begin
	// Reset
	@(negedge clock) begin
		reset = 1'b0;
	end
	checkCount(16'b0, `__LINE__);

	// Check that counter doesn't increment without the signal being asserted
	@(negedge clock) begin
		reset = 1'b1;
	end
	checkCount(16'b0, `__LINE__);

	// Load a value
	@(negedge clock) begin
		jump_set = 1'b1;
	end
	checkCount(16'hfffe, `__LINE__);

	// Load a value while incrementing, the new value should take precendence i.e count = jumpcount
	@(negedge clock) begin
		jump_set = 1'b1;
		increment = 1'b1;
	end
	checkCount(16'hfffe, `__LINE__);

	// Increment
	@(negedge clock) begin
		jump_set = 1'b0;
		increment = 1'b1;
	end
	checkCount(16'hffff, `__LINE__);

	// Incementing further so that count should be 16'h0000
	@(negedge clock) begin
		increment = 1'b1;
	end
	checkCount(16'h0000, `__LINE__);
	
	// Stop simulation
	$finish;
end

// Waveform log file and monitoring
initial begin
	$dumpfile("program_counter.vcd");
	$dumpvars();
	$monitor("time: %d, value: %h", $time, count);
end

task checkCount(input[15:0] expected, input integer lineNum);
begin
	@(posedge clock) #5 begin
		if(count === expected) begin
			$display("%3d - Test passed", lineNum);
		end
		else begin
			$display("%3d - Test failed, expected %h, got %h", lineNum, expected,count);
		end
	end
end
endtask

endmodule 