//-----------------------------------------------------------------------------
//
// Title       : Program Counter
// Author      : vinod sake <vinosake@pdx.edu>
// Company     : Student
//
//-----------------------------------------------------------------------------
//
// File        : program_counter.sv
// Generated   : 11 Nov 2016
// Last Updated: 11 Nov 2016
//-----------------------------------------------------------------------------
//
// Description : Program counter is used to point the next instruction from
//		 ROM & when JUMP instruction executes, PC points directly to
//		 desired location in ROM		
//-----------------------------------------------------------------------------

module program_counter(
	input clock,		//System clock
	input reset,		//synchronous reset, Active Low		
	input increment,	//Increments counter when high
	input jump_set,		//when jum_set is high, PC loads newcount from JUMP module
	input [15:0] jumpcount,	//New address of counter from JUMP module
	output logic [15:0]count	//Output address of counter
);

always_ff @(posedge clock) begin
	if(~reset) begin		//when reset is low, count is set to zero
		count <= 0;
	end
	else if(jump_set) begin		//when jump_set is high, newcount is loaded into counter
		count <= jumpcount;
	end
	else if(increment) begin	//when increment is high, count is incremented by one
		count <= count + 1;
	end
	
end

endmodule
