//-----------------------------------------------------------------------------
//
// Title       : RAM module
// Author      : vinod sake <vinosake@pdx.edu>
// Company     : Student
//
//-----------------------------------------------------------------------------
//
// File        : ram.sv
// Generated   : 23 Dec 2016
// Last Updated: 24 Dec 2016
//-----------------------------------------------------------------------------
//
// Description : 32,768 x 8 bits Ram module
//		 
//		 	
//-----------------------------------------------------------------------------

parameter data_width = 8;
parameter address_width = 16;
parameter ram_size = 1 << address_width;

// RAM 32,768x8 bits
module ram(
	input reset,				// system reset
	input wr_en,				// write_enable sent from memory controller; when wr_en = 1, data is written into ram  
	input rd_en,				// read_enable sent from memory controller; when rd_en = 1, data is read from ram
	input ram_enable,			// Ram enable sent from memory controller
	inout [data_width-1:0]data_bus,
	input [address_width-1:0]address_bus,
	
	// Used only for Simulation
	input force_ram_write,
	input force_ram_read,
	input force_ram_enable,
	inout [7:0]force_ram_data,
	input [15:0]force_ram_address
	
);

logic [data_width-1:0]temp_data;
logic [data_width-1:0] mem[ram_size-1:0];

always_comb begin
	if(!reset) begin						// Reset 
		for(int i=0; i<ram_size; i=i+1) begin
			mem[i] = 8'b0;
		end
	end
	else if(wr_en && !rd_en && !ram_enable) begin		// Write into RAM
		mem[address_bus] = data_bus;
	end
	else if(force_ram_write && !force_ram_read && force_ram_enable) begin
		mem[force_ram_address] = force_ram_data;
	end
end

assign force_ram_data = (force_ram_read && !force_ram_write && force_ram_enable) ? mem[force_ram_address] : 8'hzz;
assign data_bus = (rd_en && !wr_en && !ram_enable) ? mem[address_bus] : 8'hzz;


endmodule

