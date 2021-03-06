//-----------------------------------------------------------------------------
//
// Title       : 16 bits Register
// Author      : vinod sake <vinosake@pdx.edu>
// Company     : Student
//
//-----------------------------------------------------------------------------
//
// File        : register_16bit.sv
// Generated   : 14 Dec 2016
// Last Updated: 02 Jan 2017
//-----------------------------------------------------------------------------
//
// Description : Used for Memory Address, Instruction & Jump Register.
//		 
//		 	
//-----------------------------------------------------------------------------

module register_16bit(
	input clock,
	input reset,
	input loadhigh,
	input loadlow,
	input [7:0]halfvaluein,
	output logic[15:0]valueout
);

//always_comb begin
always_ff@(posedge clock) begin
	if(reset == 1'b0) begin
		valueout <= 0;
	end
	else if(loadhigh == 1'b1) begin
		valueout[15:8] <= halfvaluein;
	end
	else if(loadlow == 1'b1) begin
		valueout[7:0] <= halfvaluein;
	end
end

endmodule 