//-----------------------------------------------------------------------------
//
// Title       : ROM module
// Author      : vinod sake <vinosake@pdx.edu>
// Company     : Student
//
//-----------------------------------------------------------------------------
//
// File        : rom.sv
// Generated   : 25 Dec 2016
// Last Updated: 
//-----------------------------------------------------------------------------
//
// Description : 32,768 x 8 bits Rom module
//		 
//		 	
//-----------------------------------------------------------------------------

parameter data_width = 8;
parameter address_width = 16;
parameter rom_size = 1 << address_width;
parameter action = 1;			// simulation action = 1; synthesis action = 0;

// ROM 32,768x8 bits
module rom(
	input wr_en,				// write_enable sent from memory controller; when wr_en = 1, it is invalid and data bus has zero's
	input rd_en,				// read_enable sent from memory controller; when rd_en = 1, data is read from rom
	input rom_enable,			// Rom enable sent from memory controller
	inout [data_width-1:0]data_bus,
	input [address_width-1:0]address_bus,
	
	// Used only for simulation
	input force_rom_write,
	input force_rom_read,
	input force_rom_enable,
	inout [7:0]force_rom_data,
	input [15:0]force_rom_address
);

logic [data_width-1:0] mem[rom_size-1:0];

always_comb begin
	if(wr_en && !rd_en && !rom_enable && action) begin		// Write into ROM only for simulation
		mem[address_bus] = data_bus;
	end
	else if(force_rom_write && !force_rom_read && force_rom_enable) begin
		mem[force_rom_address] = force_rom_data;
	end
end

assign force_rom_data = (force_rom_read && !force_rom_write && force_rom_enable) ? mem[force_rom_address] : 8'hzz;
assign data_bus = (rd_en && !wr_en && !rom_enable) ? mem[address_bus] : 8'hzz;


endmodule
