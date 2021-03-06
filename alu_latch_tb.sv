//-----------------------------------------------------------------------------
//
// Title       : ALU Latch Testbench
// Author      : vinod sake <vinosake@pdx.edu>
// Company     : Student
//
//-----------------------------------------------------------------------------
//
// File        : alu_latch_tb.sv
// Generated   : 18 Dec 2016
// Last Updated: 
//-----------------------------------------------------------------------------
//
// Description : Perform testing on latch operations 
//		  	
//-----------------------------------------------------------------------------
`include "alu_latch.sv"

module alu_latch_tb();
	logic clock = 1'b0;		// System clock
	logic reset = 1'b1;		// Syetem reset
	logic store_high;		// Load top 8 bits on data bus
	logic store_low;		// Load low 8 bits on data bus
	logic grab;			// latch ALU result 
	logic [15:0]alu_result;		// alu result from ALU module
	logic [2:0]flags_in;		// flags result from ALU module
	logic [7:0]data_out;		// 8 bits data is loaded into data bus
	logic [2:0]flags_out;		// 3 bits flag result

//clock
initial clock = 1'b0;
always #50 clock = !clock; // 100 time ticks per cycle = 10 MHz clock

alu_latch alu_latch_dut(
	.clock(clock),
	.reset(reset),
	.store_high(store_high),
	.store_low(store_low),
	.grab(grab),
	.alu_result(alu_result),
	.flags_in(flags_in),
	.data_out(data_out),
	.flags_out(flags_out)
);

initial begin
	// Reset
	@(negedge clock) begin
		reset = 1'b0;
	end
	checkCount(8'hzz,3'd0, `__LINE__);

	@(negedge clock) begin
		reset = 1'b1;
	end
	checkCount(8'hzz,3'd0, `__LINE__);

	@(negedge clock) begin
		grab = 1'b1;				// alu reult should be grabed and stored in internal register
		alu_result = 16'hfeef;
		flags_in = 3'b101;
	end
	checkCount(8'hzz,3'b101, `__LINE__);

	@(negedge clock) begin
		grab = 1'b0;
		alu_result = 16'heffe;
		flags_in = 3'b111;
	end
	checkCount(8'hzz,3'b101, `__LINE__);

	@(negedge clock) begin
		store_high = 1'b1;			// data out should have high 8 bits of internal register
	end
	checkCount(8'hfe,3'b101, `__LINE__);
	
	@(negedge clock) begin
		store_high = 1'b0;
	end
	checkCount(8'hzz,3'b101, `__LINE__);

	@(negedge clock) begin
		store_low = 1'b1;			// data out should have low 8 bits of internal register
	end
	checkCount(8'hef,3'b101, `__LINE__);

	@(negedge clock) begin
		store_low = 1'b0;
	end
	checkCount(8'hzz,3'b101, `__LINE__);
	
	@(negedge clock) begin				// As store_high has higher precedence, data out should have high 8 bits of internal register 
		store_high = 1'b1;
		store_low = 1'b1;
	end
	checkCount(8'hfe,3'b101, `__LINE__);

	$finish;
end

// Waveform log file and monitoring
initial begin
	$dumpfile("alu_latch.vcd");
	$dumpvars();
	//$monitor("time: %d, data out: %d, flags out: %d ", $time, data_out, flags_out);
end

task checkCount(input [7:0]data_expected, input [2:0]flags_expected, input integer lineNum);
begin
	@(posedge clock) #5 begin
		if(data_out === data_expected) begin
			$display("%3d - Test passed! for Data Out", lineNum);
		end
		else begin
			$display("%3d - Test failed! for Data Out, expected %d, got %d", lineNum, data_expected, data_out);
		end
		if(flags_out == flags_expected) begin
			$display("%3d - Test passed! for Flags Out", lineNum);
		end
		else begin
			$display("%3d - Test failed! for Flags Out, expected %d, got %d", lineNum, flags_expected, flags_out);
		end
	end
end
endtask

endmodule
