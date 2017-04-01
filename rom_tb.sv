//-----------------------------------------------------------------------------
//
// Title       : ROM module Testbench
// Author      : vinod sake <vinosake@pdx.edu>
// Company     : Student
//
//-----------------------------------------------------------------------------
//
// File        : rom_tb.sv
// Generated   : 25 Dec 2016
// Last Updated: 26 Dec 2016
//-----------------------------------------------------------------------------
//
// Description : performing read operations in ROM
//		 
//		 	
//-----------------------------------------------------------------------------
`include "rom.sv"
parameter temp_rom_size = 1 << 4; 

module rom_tb();
	logic wr_en = 1'b0;				// Active high				 
	logic rd_en = 1'b0;				// Active high				
	logic rom_enable = 1'b1;			// Active low	
	logic [address_width-1:0]address_bus;		
	wire [data_width-1:0]data_bus;


integer read;
integer write;
integer write_databus;

logic [data_width-1:0]temp_data;
logic data_control = 1'b0;

logic clock = 1'b0;
always #50 clock = ~clock; 

rom rom_dut(
	.wr_en(wr_en),
	.rd_en(rd_en),
	.rom_enable(rom_enable),
	.address_bus(address_bus),
	.data_bus(data_bus)
);

initial begin
	
	//Writing into ROM
	write =  $fopen("write_rom.txt","r");
	while(!$feof(write)) begin
		@(posedge clock) begin
			wr_en = 1;
			rd_en = 0;
			rom_enable = 0;
			data_control = 1;
			write_databus = $fscanf(write, "%h %h\n", address_bus,temp_data);
		end
	end

	//Reading from ROM
	read = $fopen("read_rom.txt","w");
	for(int i=0; i<temp_rom_size; i=i+1) begin
		@(posedge clock) begin
			rd_en = 1;
			wr_en = 0;
			rom_enable = 0;
			address_bus = i;
			data_control = 0;
		end

		@(negedge clock) begin
			$fwrite(read,"address:%h Data:%h\n", address_bus,data_bus);
		end
	end
	$fclose(read);
	$fclose(write);
	$finish;
	
end

assign data_bus = data_control ? temp_data : 8'hzz;

// Waveform log file and monitoring
initial begin
	$dumpfile("ram.vcd");
	$dumpvars();
end

endmodule	