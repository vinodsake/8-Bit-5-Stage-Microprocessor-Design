//-----------------------------------------------------------------------------
//
// Title       : DataPath Testbench
// Author      : vinod sake <vinosake@pdx.edu>
// Company     : Student
//
//-----------------------------------------------------------------------------
//
// File        : datapath_tb.sv
// Generated   : 21 Dec 2016
// Last Updated: 
//-----------------------------------------------------------------------------
//
// Description : Performing Testing on all modules in DataPath block
//		 		 
//		 	
//-----------------------------------------------------------------------------
`include "datapath.sv"
`include "constants.sv"

parameter name_len = 300;

module datapath_tb();

	logic clock;
	logic reset;

	logic gp_write;
	logic gp_read;
	logic [2:0]gp_input_select;
	logic [2:0]gp_output_select;
	logic [2:0]gp_alu_output_select;

	logic [3:0]alu_operation;

	logic latch_alu;
	logic alu_store_high;
	logic alu_store_low;

	logic mar_load_high;
	logic mar_load_low;

	logic ir_load_high;
	logic ir_load_low;

	logic jr_load_high;
	logic jr_load_low;

	logic pc_increment;
	logic pc_set;

	logic [2:0]flags;
	logic [15:0]pc_count;
	logic [15:0]ir_value;
	logic [15:0]mar_value;
	wire [7:0]data_bus;

datapath datapath_dut(
	.clock(clock),
	.reset(reset),
	.gp_write(gp_write),
	.gp_read(gp_read),
	.gp_input_select(gp_input_select),
	.gp_output_select(gp_output_select),
	.gp_alu_output_select(gp_alu_output_select),
	.alu_operation(alu_operation),
	.latch_alu(latch_alu),
	.alu_store_high(alu_store_high),
	.alu_store_low(alu_store_low),
	.mar_load_high(mar_load_high),
	.mar_load_low(mar_load_low),
	.ir_load_high(ir_load_high),
	.ir_load_low(ir_load_low),
	.jr_load_high(jr_load_high),
	.jr_load_low(jr_load_low),
	.pc_increment(pc_increment),
	.pc_set(pc_set),
	.flags(flags),
	.pc_count(pc_count),
	.ir_value(ir_value),
	.mar_value(mar_value),
	.data_bus(data_bus)
);

logic databus_control;
logic [7:0]temp_data;
logic [name_len - 1:0]register_name;

assign data_bus = databus_control ? temp_data : 8'hzz;


initial clock = 1'b1;
always #50 clock = ~clock;

initial begin
	system_reset_signals();
	
	//Reset
	@(negedge clock) begin
		reset = 1'b0;
	end
	@(posedge clock) #5 begin
		check16bits("Instruction Register", ir_value, 16'd0, `__LINE__);
		check16bits("MAR", mar_value, 16'd0, `__LINE__);
		check16bits("Program counter", pc_count, 16'd0, `__LINE__);
	end	
	
	//Loading Instruction Register
	@(negedge clock) begin
		system_reset_signals();
		temp_data = 8'hab;
		databus_control = 1'b1;
		ir_load_high = 1;
	end
	@(posedge clock) #5 begin
		check16bits("Instruction Register load high", ir_value, 16'hab00, `__LINE__);
	end
	@(negedge clock) begin
		system_reset_signals();
		temp_data = 8'hcd;
		databus_control = 1'b1;
		ir_load_low = 1;
	end
	@(posedge clock) #5 begin
		check16bits("Instruction Register load low", ir_value, 16'habcd, `__LINE__);	
	end		

	//Loading MAR 
	@(negedge clock) begin
		system_reset_signals();
		temp_data = 8'hfe;
		databus_control = 1'b1;
		mar_load_high = 1;
	end
	@(posedge clock) #5 begin
		check16bits("MAR load high", mar_value, 16'hfe00, `__LINE__);
	end
	@(negedge clock) begin
		system_reset_signals();
		temp_data = 8'hef;
		databus_control = 1'b1;
		mar_load_low = 1;
	end
	@(posedge clock) #5 begin
		check16bits("MAR load low", mar_value, 16'hfeef, `__LINE__);	
	end

	//Loading Jump Register 
	@(negedge clock) begin
		system_reset_signals();
		temp_data = 8'h12;
		databus_control = 1'b1;
		jr_load_high = 1;
	end
	@(negedge clock) begin
		system_reset_signals();
		temp_data = 8'h34;
		databus_control = 1'b1;
		jr_load_low = 1;
	end
	@(negedge clock) begin
		system_reset_signals();
		pc_set = 1;
	end
	@(posedge clock) #5 begin
		check16bits("Jump Register", pc_count, 16'h1234, `__LINE__);	
	end

	//Program Counter
	@(negedge clock) begin									// Incrementing operation
		system_reset_signals();
		pc_increment = 1;
	end
	@(posedge clock) #5 begin
		check16bits("Program counter Increment", pc_count, 16'h1235, `__LINE__);	
	end
	@(negedge clock) begin									// Incrementing operation
		system_reset_signals();
		pc_increment = 1;
	end
	@(posedge clock) #5 begin
		check16bits("Program counter Increment", pc_count, 16'h1236, `__LINE__);	
	end
	@(negedge clock) begin									// Loading Program counter from Jump register
		system_reset_signals();
		temp_data = 8'hff;
		databus_control = 1'b1;
		jr_load_high = 1;
	end
	@(negedge clock) begin
		system_reset_signals();
		temp_data = 8'hff;
		databus_control = 1'b1;
		jr_load_low = 1;
	end
	@(negedge clock) begin
		system_reset_signals();
		pc_set = 1;
	end
	@(posedge clock) #5 begin
		check16bits("Program counter Increment", pc_count, 16'hffff, `__LINE__);	
	end

	//General Purpose Registers 
	system_reset_signals();							// Loading data into registers
	for(int i=0; i<=7; i = i+1) begin
		@(negedge clock) begin
			gp_input_select = i;
			temp_data = i;
			databus_control = 1;
			gp_read = 1;
		end
	end
	
	for(int i=0; i<=7; i = i+1) begin					// Loading data from regesters into databus
		@(negedge clock) begin
			system_reset_signals();
			gp_output_select = i;
			gp_write = 1;
		end
		@(posedge clock) #5 begin
			$sformat(register_name,"Register #%1d", i);
			checkdatabus(register_name, i ,`__LINE__);
		end
	end
	
	//ALU - Addition operation
	@(negedge clock) begin
		system_reset_signals();
		gp_alu_output_select = 3'd1;
		gp_output_select = 3'd2;
		gp_write = 1;
		alu_operation = `ALU_ADD;
		latch_alu = 1;
	end
	@(negedge clock) begin
		system_reset_signals();
		alu_store_low = 1;		
	end
	@(posedge clock) #5 begin
		checkdatabus("Addition operation on reg 1&2", 8'd3, `__LINE__);
	end
	
	//ALU - Multiplication operation immediate
	@(negedge clock) begin
		system_reset_signals();
		gp_alu_output_select = 3'd6;
		temp_data = 8'd120;
		databus_control = 1;
		alu_operation = `ALU_MULTIPLY;
		latch_alu = 1;
	end
	@(negedge clock) begin
		system_reset_signals();
		alu_store_low = 1;		
	end
	@(posedge clock) #5 begin
		checkdatabus("Multiply operation, 120x6: low", 8'hd0, `__LINE__);
	end
	@(negedge clock) begin
		system_reset_signals();
		alu_store_high = 1;		
	end
	@(posedge clock) #5 begin
		checkdatabus("Multiply operation, 120x6: high", 8'h02, `__LINE__);
	end

	//ALU - passthrough operation
	@(negedge clock) begin
		system_reset_signals();
		gp_output_select = 3'd5;
		gp_write = 1;
		alu_operation = `ALU_PASSTHROUGH;
		latch_alu = 1;
	end
	@(negedge clock) begin
		system_reset_signals();
		alu_store_low = 1;		
	end
	@(posedge clock) #5 begin
		checkdatabus("Passthrough opertion", 8'd5, `__LINE__);
	end

	//ALU - TWOS complement operation
	@(negedge clock) begin
		system_reset_signals();
		gp_alu_output_select = 3'd7;
		alu_operation = `ALU_TWOS_COMPLEMENT;
		latch_alu = 1;
	end
	@(negedge clock) begin
		system_reset_signals();
		alu_store_low = 1;		
	end
	@(posedge clock) #5 begin
		checkdatabus("Twos complement opertion", -8'd7, `__LINE__);
	end
	
	$finish;
end

// Waveform log file and monitoring
initial begin
	$dumpfile("datapath.vcd");
	$dumpvars();
end

task system_reset_signals();
begin
	
	 reset = 1;

	 gp_write = 0;
	 gp_read = 0;
	 gp_input_select = 0;
	 gp_output_select = 0;
	 gp_alu_output_select = 0;

	 alu_operation = 0;

	 latch_alu = 0;
	 alu_store_high = 0;
	 alu_store_low = 0;

	 mar_load_high = 0;
	 mar_load_low = 0;

	 ir_load_high = 0;
	 ir_load_low = 0;

	 jr_load_high = 0;
	 jr_load_low = 0;

	 pc_increment = 0;
	 pc_set = 0;

	 databus_control = 0; 

end
endtask

task check16bits(input [name_len - 1:0] name, input [15:0] value, input [15:0] value_expected, input integer lineNum);
begin
	if (value == value_expected) begin
		$display("%3d - Test Passed! for %s", lineNum, name);
	end
	else begin
		$display("%3d - Test Failed! for %s, expected %d got %d", lineNum, name, value_expected, value);
	end

end
endtask

task checkdatabus(input [name_len - 1:0]name, input [7:0] data_expected, input integer lineNum);
begin
	if (data_bus == data_expected) begin
		$display("%3d - Test Passed! for %s", lineNum, name);
	end
	else begin
		$display("%3d - Test Failed! for %s, expected %d got %d", lineNum, name, data_expected, data_bus);
	end

end
endtask


endmodule 