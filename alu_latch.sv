//-----------------------------------------------------------------------------
//
// Title       : ALU Latch
// Author      : vinod sake <vinosake@pdx.edu>
// Company     : Student
//
//-----------------------------------------------------------------------------
//
// File        : alu_latch.sv
// Generated   : 20 Nov 2016
// Last Updated: 
//-----------------------------------------------------------------------------
//
// Description : Takes the ALU output result and put in data bus 
//		 	
//-----------------------------------------------------------------------------

module alu_latch(
	input clock,			// System clock
	input reset,			// Syetem reset
	input store_high,		// Load top 8 bits on data bus
	input store_low,		// Load low 8 bits on data bus
	input grab,			// latch ALU result 
	input [15:0]alu_result,		// alu result from ALU module
	input [2:0]flags_in,		// flags result from ALU module
	output logic[7:0]data_out,	// 8 bits data is loaded into data bus
	output logic[2:0]flags_out	// 3 bits flag result
);
logic [15:0]alu_value;

always@(posedge clock) begin
	if(reset == 1'b0) begin		
		alu_value = 16'd0;
		flags_out = 3'd0;
	end
	else if(grab == 1'b1) begin		// latch alu result when grab signal is high
		alu_value <= alu_result;	 
		flags_out <= flags_in;		
	end
end

always_comb begin
	if(store_high == 1'b1) begin		// Load top 8 bits of alu result on data bus
		data_out <= alu_value[15:8];
	end
	else if(store_low == 1'b1) begin	// Load low 8 bits of alu result on data bus
		data_out <= alu_value[7:0];
	end
	else begin
		data_out <= 8'hzz;		// Else maintain high impedance on data bus
	end
end
endmodule




