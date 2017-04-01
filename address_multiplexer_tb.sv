//-----------------------------------------------------------------------------
//
// Title       : Address Multiplexer Testbench
// Author      : vinod sake <vinosake@pdx.edu>
// Company     : Student
//
//-----------------------------------------------------------------------------
//
// File        : address_multiplexer_tb.sv
// Generated   : 15 Dec 2016
// Last Updated: 
//-----------------------------------------------------------------------------
//
// Description : performing testing on different modes of address multiplexer
//		 
//		 	
//-----------------------------------------------------------------------------
`include "address_multiplexer.sv"
`include "constants.sv"


module address_multiplexer_tb();
	logic [15:0]pc_value;
	logic [15:0]mar_value;
	logic [4:0]state;
	logic [15:0]address_bus;

//clock
logic clock = 1'b0;
always #50 clock = !clock; // 100 time ticks per cycle = 10 MHz clock

address_multiplexer address_multiplexer_dut(
	.pc_value(pc_value),
	.mar_value(mar_value),
	.state(state),
	.address_bus(address_bus)
);

initial begin
	
	@(negedge clock) begin
		state = `S_FETCH_MEMORY;
		pc_value = 16'habcd;
		mar_value = 16'hffff;
	end
	checkCount(16'hffff, `__LINE__);

	@(negedge clock) begin
		state = `S_ALU_OPERATION;
		pc_value = 16'habcd;
		mar_value = 16'h1234;
	end
	checkCount(16'habcd, `__LINE__);

	@(negedge clock) begin
		state = `S_STORE_MEMORY;
		pc_value = 16'habcd;
		mar_value = 16'h1234;
	end
	checkCount(16'h1234, `__LINE__);	

	@(negedge clock) begin
		state = `S_TEMP_FETCH;
		pc_value = 16'habcd;
		mar_value = 16'h4321;
	end
	checkCount(16'h4321, `__LINE__);	
	
	@(negedge clock) begin
		state = `S_TEMP_STORE;
		pc_value = 16'habcd;
		mar_value = 16'hdddd;
	end
	checkCount(16'hdddd, `__LINE__);	

	@(negedge clock) begin
		state = `S_FETCH_ADDRESS_1;
		pc_value = 16'habcd;
		mar_value = 16'hdddd;
	end
	checkCount(16'habcd, `__LINE__);	
	
	$finish;
end


// Waveform log file and monitoring
initial begin
	$dumpfile("address_multiplexer.vcd");
	$dumpvars();
	//$monitor("time: %d, data out: %d, flags out: %d ", $time, data_out, flags_out);
end

task checkCount(input [15:0]address_expected, input integer lineNum);
begin
	@(posedge clock) #5 begin
		if(address_bus == address_expected) begin
			$display("%3d - Test passed!", lineNum);
		end
		else begin
			$display("%3d - Test failed!, expected %d, got %d", lineNum, address_expected, address_bus);
		end
	end
end
endtask

endmodule


