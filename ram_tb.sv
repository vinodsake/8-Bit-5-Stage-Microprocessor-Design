//-----------------------------------------------------------------------------
//
// Title       : RAM Testbench
// Author      : vinod sake <vinosake@pdx.edu>
// Company     : Student
//
//-----------------------------------------------------------------------------
//
// File        : ram_tb.sv
// Generated   : 24 Dec 2016
// Last Updated: 25 Dec 2016
//-----------------------------------------------------------------------------
//
// Description : performing write and read operations in RAM
//		 
//		 	
//-----------------------------------------------------------------------------
`include "ram.sv"
parameter temp_ram_size = 1 << 4; 

module ram_tb();
	logic reset = 1'b1;				// system reset
	logic wr_en = 1'b0;				// Active high				 
	logic rd_en = 1'b0;				// Active high				
	logic ram_enable = 1'b1;			// Active low	
	logic [address_width-1:0]address_bus;		
	wire [data_width-1:0]data_bus;

integer in;
integer read;

logic [data_width-1:0]temp_ram[ram_size-1:0];
logic [data_width-1:0]temp_ram_test[ram_size-1:0];
logic [data_width-1:0]temp_data;
logic data_control = 1'b0;

logic clock = 1'b0;
always #50 clock = ~clock; 

ram ram_dut(
	.reset(reset),
	.wr_en(wr_en),
	.rd_en(rd_en),
	.ram_enable(ram_enable),
	.address_bus(address_bus),
	.data_bus(data_bus)
);

initial begin

	for(int i=0; i<temp_ram_size; i=i+1) begin
		temp_ram[i] = i;
	end
	
	// Reset
	@(posedge clock) begin
		reset = 0;
	end	
	@(posedge clock) begin
		reset = 1;
	end
	
	//Writing into RAM
	for(int i=0; i<temp_ram_size; i=i+1) begin
		@(posedge clock) begin
			wr_en = 1;
			rd_en = 0;
			ram_enable = 0;
			temp_data = temp_ram[i];
			address_bus = i;
			data_control = 1;
		end
	end

	//reading from RAM
	read = $fopen("read_ram.txt","w");
	for(int i=0; i<temp_ram_size; i=i+1) begin
		@(posedge clock) begin
			rd_en = 1;
			wr_en = 0;
			ram_enable = 0;
			address_bus = i;
			data_control = 0;
		end
		@(negedge clock) begin
			$fwrite(read,"address:%h Data:%h\n", address_bus,data_bus);
		end
	end
	$fclose(read);
	$finish;
	
end

assign data_bus = data_control ? temp_data : 8'hzz;

// Waveform log file and monitoring
initial begin
	$dumpfile("ram.vcd");
	$dumpvars();
end

endmodule	