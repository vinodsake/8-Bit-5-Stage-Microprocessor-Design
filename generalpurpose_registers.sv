//-----------------------------------------------------------------------------
//
// Title       : General Purpose Registers
// Author      : vinod sake <vinosake@pdx.edu>
// Company     : Student
//
//-----------------------------------------------------------------------------
//
// File        : generalpurpose_registers.sv
// Generated   : 18 Nov 2016
// Last Updated: 14 dec 2016
//-----------------------------------------------------------------------------
//
// Description : 8x8 bits general purpose registers
//		| A (000)| B (001)|
//		| C (010)| D (011)|
//		| E (100)| F (101)|	
//		| G (110)| H (111)|
//-----------------------------------------------------------------------------

module generalpurpose_registers(
	input clock,
	input reset,
	input read_data,
	input write_data,
	input [2:0] input_select,
	input [2:0] output_select,
	input [2:0] alu_output_select,
	inout [7:0] data_bus,
	output logic [7:0] alu_primary_value
);
//-----------------------------------------------------------------------------------------------------------//
// Internal regs
logic [7:0] registers[7:0];
logic [7:0] output_value;
integer i;
//-----------------------------------------------------------------------------------------------------------//

always_ff@(posedge clock) begin
	if(reset == 1'b0) begin
		for(i=0;i<8;i++) begin
			registers[i] <= 8'd0;
		end
	end

	else if(read_data == 1'b1) begin
		registers[input_select] <= data_bus;		// Reads from Data bus
	end
end

assign output_value = registers[output_select];			
assign alu_primary_value = registers[alu_output_select];	// Alu primary inputs
assign data_bus = write_data ? output_value : 8'hzz;		// Writes into Data bus
  
endmodule 