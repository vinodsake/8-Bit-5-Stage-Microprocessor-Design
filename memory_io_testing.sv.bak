//-----------------------------------------------------------------------------
//
// Title       : Memory Input Output testing module
// Author      : vinod sake <vinosake@pdx.edu>
// Company     : Student
//
//-----------------------------------------------------------------------------
//
// File        : memory_io_testing.sv
// Generated   : 20 Dec 2016
// Last Updated: 
//-----------------------------------------------------------------------------
//
// Description : I created this module only for testing purpose. The problem 
//		 i faced is, if there is a inout port in the module then to test
//		 it in the testbench i cannot use logic. If used there is loading
//		 design problem.
//		 solution: http://pufferonmicroisland.blogspot.com/2011/11/handling-bidirectional-pinsports-in.html
//-----------------------------------------------------------------------------


module memory_io(
	input read_memory,
	input write_memory,
	input [15:0]address_in,
	inout [7:0]internal_data_bus,
	inout [7:0]external_data_bus,
	output [15:0]address_out,
	output logic ram_enable,
	output logic rom_enable,
	output write,
	output read,
	input control
);
logic [1:0]concatinate = {read_memory,write_memory};
logic enable;

assign enable = read_memory ^ write_memory;

assign internal_data_bus = (read_memory == 1'b1 && enable == 1'b1) ? external_data_bus : 8'hzz;
assign external_data_bus = (write_memory == 1'b1 && enable == 1'b1) ? internal_data_bus : 8'hzz;

always_comb begin
	case(concatinate)
		00 : begin
			rom_enable = 1;
			ram_enable = 1;
		end
		01 : begin
			rom_enable = !(address_in[15:13] === 3'b000);
			ram_enable = !(address_in[15:13] === 3'b001);
		end
		10 : begin
			rom_enable = !(address_in[15:13] === 3'b000);
			ram_enable = !(address_in[15:13] === 3'b001);
		end
		11 : begin			//Invalid
			rom_enable = 1;
			ram_enable = 1;
		end
	endcase
end	

assign address_out = address_in;
assign write = write_memory;
assign read =  read_memory;

endmodule 
