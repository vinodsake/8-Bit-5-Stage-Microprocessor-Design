//-----------------------------------------------------------------------------
//
// Title       : Memory Input Output
// Author      : vinod sake <vinosake@pdx.edu>
// Company     : Student
//
//-----------------------------------------------------------------------------
//
// File        : memory_io.sv
// Generated   : 14 Dec 2016
// Last Updated: 
//-----------------------------------------------------------------------------
//
// Description : performs mapping between RAM & ROM memory blocks
//		 ROM : 0000 - 1FFF
//		 RAM : 2000 - 3FFF
//-----------------------------------------------------------------------------


module memory_io(
	input read_memory,
	input write_memory,
	input [15:0]address_in,
	inout [7:0]internal_data_bus,
	inout [7:0]external_data_bus,
	output [15:0]address_out,
	output logic ram_enable,		// Active LOW
	output logic rom_enable,		// Active LOW
	output write,
	output read
);
logic [1:0]read_write;
logic enable;

assign read_write = {read_memory,write_memory};
assign enable = read_memory ^ write_memory;

assign internal_data_bus = (read_memory == 1'b1 && enable == 1'b1) ? external_data_bus : 8'hzz;
assign external_data_bus = (write_memory == 1'b1 && enable == 1'b1) ? internal_data_bus : 8'hzz;

always_comb begin
	case(read_write)
		0 : begin
			rom_enable = 1;
			ram_enable = 1; 
		end
		1 : begin
			rom_enable = !(address_in[15:13] === 3'b000);
			ram_enable = !(address_in[15:13] === 3'b001);
		end
		2 : begin
			rom_enable = !(address_in[15:13] === 3'b000);
			ram_enable = !(address_in[15:13] === 3'b001);
		end
		3 : begin			//Invalid
			rom_enable = 1;
			ram_enable = 1;
		end
		default : begin
			rom_enable = 1;
			ram_enable = 1;
		end
	endcase
end	

assign address_out = (address_in > 16'h1fff) ? (address_in - 16'h2000): address_in; 		// Mapping RAM address 
assign write = write_memory;
assign read =  read_memory;

endmodule 