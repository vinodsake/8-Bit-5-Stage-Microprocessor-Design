//-----------------------------------------------------------------------------
//
// Title       : 8-bit microprocessor cpu
// Author      : vinod sake <vinosake@pdx.edu>
// Company     : Student
//
//-----------------------------------------------------------------------------
//
// File        : cpu_tb.sv
// Generated   : 29 Dec 2016
// Last Updated: 02 Jan 2017
//-----------------------------------------------------------------------------
//
// Description : Performing testing on all modules integrated
//		 
//		 	
//-----------------------------------------------------------------------------
`include "constants.sv"

//-----------------------------------------------------------------------------------------------------------//
// Parameters for the module
parameter string_len = 200;
enum {A,B,C,D,E,F,G,H}gp_registers;

parameter data_width = 8;
parameter address_width = 16;
parameter rom_size = 1 << address_width;
parameter temp_rom_size = 1 << 6; 
//-----------------------------------------------------------------------------------------------------------//

module cpu_tb();
//-----------------------------------------------------------------------------------------------------------//
// CPU inputs and outputs
	logic clock;
	logic reset;

	logic force_rom_write = 1'b0;				// Active high				 
	logic force_rom_read = 1'b0;				// Active high				
	logic force_rom_enable = 1'b0;			
	logic [address_width-1:0]force_rom_address;		
	wire [data_width-1:0]force_rom_data;
	
	logic force_ram_write = 1'b0;				// Active high				 
	logic force_ram_read = 1'b0;				// Active high				
	logic force_ram_enable = 1'b0;			
	logic [address_width-1:0]force_ram_address;		
	wire [data_width-1:0]force_ram_data;
//-----------------------------------------------------------------------------------------------------------//

//-----------------------------------------------------------------------------------------------------------//
// Internal strings, wires and regs
	logic [15:0]instruction;

	integer read_rom;
	integer ram_read;
	integer count = 0;
	integer write_databus;
	integer read_instruction;
	integer string_space=0;
	integer string_comma=0;
	integer string_space_count=0;
	integer string_comma_count=0;
	string opcode;
	string instruction_string;
	string first_operand;
	string second_operand;
	string immediate_first_data_string;
	string immediate_second_data_string;
	logic [7:0]immediate_first_data;
	logic [7:0]immediate_second_data;
	logic [15:0]immediate_first_address;
	logic [15:0]immediate_second_address;
	
	logic [data_width-1:0]temp_data;
	logic data_control = 1'b0;
	logic [data_width-1:0]temp_ram_data;
	logic data_ram_control = 1'b0;
//-----------------------------------------------------------------------------------------------------------//

// System Clock
initial clock = 1'b0;
always #50 clock = ~clock; 

cpu cpu_dut(
	.clock(clock),
	.reset(reset),
	.force_rom_write(force_rom_write),
	.force_rom_read(force_rom_read),
	.force_rom_enable(force_rom_enable),
	.force_rom_address(force_rom_address),
	.force_rom_data(force_rom_data),
	.force_ram_write(force_ram_write),
	.force_ram_read(force_ram_read),
	.force_ram_enable(force_ram_enable),
	.force_ram_address(force_ram_address),
	.force_ram_data(force_ram_data)
);

// Waveform log file and monitoring
initial begin
	$dumpfile("cpu.vcd");
	$dumpvars();
end

initial begin
	
#50;

//-----------------------------------------------------------------------------------------------------------//
// Reading Instructions from file and converting it into Hex format and writing into ROM
read_instruction = $fopen("cpu_program.txt","r");									// Open instruction file in read mode
while(!$feof(read_instruction)) begin
	instruction = $fscanf(read_instruction, "%s\n", instruction_string);					// Read instructions from file to be loaded into ROM
	instruction_decode(instruction_string);									// Decodes instruction into Hex code
	force_rom_write = 1;
	force_rom_read = 0;
	force_rom_enable = 1;
	data_control = 1;
	for (int j = 0; j < 2; j = j+1) begin
		if(j == 0) begin 										// Storing high bits of instruction in ROM
			force_rom_address = count;
			temp_data = instruction[15:8];
			count = count+1;
			#50;
		end
		else if(j == 1) begin										// Storing low bits of instruction in ROM
			force_rom_address = count;
			temp_data = instruction[7:0];
			count = count+1;
			#50;
		end
	end 

// Store immediate data and address locations in ROM 
// ALU operations 
	if(instruction[15] == 1'b0 && instruction[15:11] != 5'b01101 && instruction[15:11] != 5'b01110 && instruction[15:11] != `JUMP) begin
		if(second_operand[0] == "#") begin								// ALU operation with immediate data
			force_rom_address = count;
			temp_data = immediate_second_data;
			count = count+1;
			#50;
		end
		else begin
			$display("%3d - Invalid second operand for ALU operations",`__LINE__);
		end
	end
// MOVE operation
	else if(instruction[15:11] === `MOVE) begin
		if(second_operand[0] == "#") begin
			$display("%3d - Invalid second_operand for MOVE operation",`__LINE__);
		end
		else if((second_operand[0] != "#") && opcode == "MOVE") begin					// MOVE operation with source memory address
			for (int j = 0; j < 2; j = j+1) begin
				if(j == 0) begin								// Storing high bits of source memory address in ROM
					force_rom_address = count;
					temp_data = immediate_second_address[15:8];
					count = count+1;
					#50;
				end
				else if(j == 1) begin								// Storing low bits of destination memory address in ROM
					force_rom_address = count;
					temp_data = immediate_second_address[7:0];
					count = count+1;
					#50;
				end
			end
		end
		if(first_operand[0] == "#") begin
			$display("%3d - Invalid first_operand for MOVE operation",`__LINE__);
		end
		else if((first_operand[0] != "#") && opcode == "MOVE") begin					// MOVE operation with destination memory address
			for (int j = 0; j < 2; j = j+1) begin
				if(j == 0) begin								// Storing high bits of destination memory address in ROM
					force_rom_address = count;
					temp_data = immediate_first_address[15:8];
					count = count+1;
					#50;
				end
				else if(j == 1) begin								// Storing low bits of destination memory address in ROM
					force_rom_address = count;
					temp_data = immediate_first_address[7:0];
					count = count+1;
					#50;
				end
			end	
		end
	end
// LOAD operation
	else if(instruction[15:11] === `LOAD) begin
		if(second_operand[0] == "#") begin								// LOAD operation with source immediate data		
			force_rom_address = count;
			temp_data = immediate_second_data;
			count = count+1;
			#50;
		end
		else if(second_operand[0] != "#") begin								// LOAD operation with source memory address
			for (int j = 0; j < 2; j = j+1) begin
				if(j == 0) begin								// Storing high bits of source memory address in ROM
					force_rom_address = count;
					temp_data = immediate_second_address[15:8];
					count = count+1;
					#50;
				end
				else if(j == 1) begin								// Storing low bits of source memory address in ROM
					force_rom_address = count;
					temp_data = immediate_second_address[7:0];
					count = count+1;
					#50;
				end
			end
		end
	end
// STORE operation		
	else if(instruction[15:11] === `STORE) begin								
		if(second_operand[0] == "#") begin								// STORE operation with source immediate data
			$display("%3d - Invalid second operand for STORE operation",`__LINE__);
		end
		else if(second_operand[0] != "#") begin								// STORE operation with source memory address
			for (int j = 0; j < 2; j = j+1) begin
				if(j == 0) begin								// Storing high bits of destination memory address in ROM
					force_rom_address = count;
					temp_data = immediate_second_address[15:8];
					count = count+1;
					#50;
				end
				else if(j == 1) begin								// Storing low bits of destination memory address in ROM
					force_rom_address = count;
					temp_data = immediate_second_address[7:0];
					count = count+1;
					#50;
				end
			end
		end
	end
// JUMP operation
	else if(instruction[15:11] === `JUMP) begin
		$display("load");
		if(first_operand[0] == "#") begin								
			$display("%3d - Invalid first operand for STORE operation",`__LINE__);
		end
		else if(first_operand[0] != "#") begin								// STORE operation with source memory address
			for (int j = 0; j < 2; j = j+1) begin
				if(j == 0) begin								// Storing high bits of jump memory address in ROM
					force_rom_address = count;
					temp_data = immediate_first_address[15:8];
					count = count+1;
					#50;
				end
				else if(j == 1) begin								// Storing low bits of jump memory address in ROM
					force_rom_address = count;
					temp_data = immediate_first_address[7:0];
					count = count+1;
					#50;
				end
			end
		end
	end
         
end
//-----------------------------------------------------------------------------------------------------------//

//-----------------------------------------------------------------------------------------------------------//
// After writing instructions in ROM, print data into afile by reading memory from ROM
read_rom = $fopen("read_cpu_rom.txt","w");										// Open instruction file in write mode
for(int i=0; i<temp_rom_size; i=i+1) begin
	@(posedge clock) begin											
		force_rom_read = 1;
		force_rom_write = 0;
		force_rom_enable = 1;
		force_rom_address = i;
		data_control = 0;
	end
	@(negedge clock) #5 begin
		$fwrite(read_rom,"address:%h Data:%h\n", force_rom_address,force_rom_data);				// Print address and corresponding data from ROM in a file 
	end
end
//-----------------------------------------------------------------------------------------------------------//

force_rom_write = 0;
force_rom_read = 0;
force_rom_enable = 0;
force_ram_enable = 0;

//Reset
@(negedge clock) begin				
	reset = 0;							// System Reset
end
@(negedge clock) begin
	reset = 1;
end

#5000;									// Wait for all the instructions to execute in CPU

//-----------------------------------------------------------------------------------------------------------//
//Make sure the results are stored in RAM. Print address and corresponding data from RAM in a file
ram_read = $fopen("read_cpu_ram.txt","w");									// Open instruction file in write mode
for(int i=0; i<temp_rom_size; i=i+1) begin
	@(posedge clock) begin
		force_ram_read = 1;
		force_ram_write = 0;
		force_ram_enable = 1;
		force_ram_address = i;
		data_ram_control = 0;
	end
	@(negedge clock) #5 begin
		$fwrite(ram_read,"address:%h Data:%h\n", force_ram_address,force_ram_data);			// Print address and corresponding data from RAM in a file
	end
end
//-----------------------------------------------------------------------------------------------------------//

$fclose(read_instruction);
$fclose(read_rom);
$fclose(ram_read);

end

assign force_ram_data = data_ram_control ? temp_ram_data : 8'hzz;
assign force_rom_data = data_control ? temp_data : 8'hzz;

//-----------------------------------------------------------------------------------------------------------//
// Task to decode instructions
task instruction_decode(input string instruction_string);
begin
	string_space = 0;
	string_comma = 0;
	string_space_count = 0;
	string_comma_count = 0;
	for(int i=0; i<instruction_string.len(); i=i+1) begin
		if(instruction_string[i] == "_") begin
			string_space = i;
			string_space_count = string_space_count+1;
		end
		else if(instruction_string[i] == ",") begin
			string_comma = i;
			string_comma_count = string_comma_count+1;
		end
	end
	if(string_space_count == 0 && string_comma_count == 0) begin					// No operands in instruction
		opcode = instruction_string;
		first_operand = "NA";
		second_operand = "NA";
	end
	else if(string_space_count == 1 && string_comma_count == 0) begin				// Single operand in instruction
		opcode = instruction_string.substr(0,string_space-1);
		first_operand = instruction_string.substr(string_space+1,instruction_string.len()-1);
		second_operand = "NA";
		if(first_operand[0] == "#") begin
			immediate_first_data_string = first_operand.substr(1,first_operand.len()-1);
			immediate_first_data = immediate_first_data_string.atohex;
		end
		else if(first_operand[0] != "#") begin
			immediate_first_address = first_operand.atohex;
		end
	end
	else if(string_space_count == 1 && string_comma_count == 1)begin				// Two operands in instruction
		opcode = instruction_string.substr(0,string_space-1);
		first_operand = instruction_string.substr(string_space+1,string_comma-1);
		second_operand =  instruction_string.substr(string_comma+1,instruction_string.len()-1);
		if(first_operand[0] == "#") begin
			immediate_first_data_string = first_operand.substr(1,first_operand.len()-1);
			immediate_first_data = immediate_first_data_string.atohex;
		end
		else if(first_operand[0] != "#") begin
			immediate_first_address = first_operand.atohex;
		end
		if(second_operand[0] == "#") begin
			immediate_second_data_string = second_operand.substr(1,second_operand.len()-1);
			immediate_second_data = immediate_second_data_string.atohex;
		end
		else if(second_operand[0] != "#") begin
			immediate_second_address = second_operand.atohex;
		end
	end

	case(opcode) 
		"NOP":	nop_halt();
		"ADD":	alu_operations();
		"SUB":	alu_operations();
		"MUL":	alu_operations();
		"AND":	alu_operations();
		"OR":	alu_operations();
		"LSR":	alu_operations();
		"LSL":	alu_operations();
		"ASR":	alu_operations();
		"ASL":	alu_operations();
		"NOT":	alu_operations();
		"NEG":	alu_operations();
		"LOAD":	load_operation();
		"STORE":store_operation();
		"MOVE": move_operation();
		"JMP":	jump_operation();				// Always Jump
		"JC":	jump_operation();				// Jump if carry
		"JZ":	jump_operation();				// Jump if Zero
		"JS":	jump_operation();				// Jump if Negitive
		"HALT":	nop_halt();
	endcase
end
endtask		
//-----------------------------------------------------------------------------------------------------------//

//-----------------------------------------------------------------------------------------------------------//
// Task to decode ALU operations instructions
task alu_operations();
begin
	instruction[8] = 0;
	instruction[1:0] = 2'b00;
	case(opcode)
		"ADD":	instruction[15:11] = `ADD;
		"SUB":	instruction[15:11] = `SUBTRACT;
		"MUL":	instruction[15:11] = `MULTIPLY;
		"AND":	instruction[15:11] = `AND;
		"OR":	instruction[15:11] = `OR;
		"LSR":	instruction[15:11] = `LOGICAL_SHIFT_RIGHT;
		"LSL":	instruction[15:11] = `LOGICAL_SHIFT_LEFT;
		"ASR":	instruction[15:11] = `ARITH_SHIFT_RIGHT;
		"ASL":	instruction[15:11] = `ARITH_SHIFT_LEFT;
		"NOT":	instruction[15:11] = `COMPLEMENT;
		"NEG":	instruction[15:11] = `TWOS_COMPLEMENT;
	endcase
	// Single operand ALU operations
	if(opcode == "LSR" || opcode == "LSL" || opcode == "ASR" || opcode == "ASL" || opcode == "NOT" || opcode == "NEG") begin	
		case(first_operand) 
			"A": instruction[4:2] = A;
			"B": instruction[4:2] = B;
 			"C": instruction[4:2] = C;
			"D": instruction[4:2] = D;
			"E": instruction[4:2] = E;
			"F": instruction[4:2] = F;
			"G": instruction[4:2] = G;
			"H": instruction[4:2] = H;
			default : begin
				  	$display("%3d - Invalid first operand for alu_operations, can be only source registers",`__LINE__);
				  end
		endcase
		instruction[7:5] = 0;
	end
	// Two operands ALU operations
	else if(opcode == "ADD" || opcode == "SUB" || opcode == "MUL" || opcode == "AND" || opcode == "OR" ) begin			
		case(first_operand)
			"A": instruction[7:5] = A;
			"B": instruction[7:5] = B;
 			"C": instruction[7:5] = C;
			"D": instruction[7:5] = D;
			"E": instruction[7:5] = E;
			"F": instruction[7:5] = F;
			"G": instruction[7:5] = G;
			"H": instruction[7:5] = H;
			default : begin
				  	$display("%3d - Invalid first operand for alu_operations, can only be source registers",`__LINE__);
				  end
		endcase
		case(second_operand)
			"A": begin 
				instruction[4:2] = A;
				instruction[10:9] = 2'b00;			// Source Register
			     end
			"B": begin 
				instruction[4:2] = B;
				instruction[10:9] = 2'b00;			// Source Register
		     	     end
			"C": begin 
				instruction[4:2] = C;
				instruction[10:9] = 2'b00;			// Source Register
			     end
			"D": begin 
				instruction[4:2] = D;
				instruction[10:9] = 2'b00;			// Source Register
			     end
			"E": begin 
				instruction[4:2] = E;
				instruction[10:9] = 2'b00;			// Source Register
			     end
			"F": begin 
				instruction[4:2] = F;
				instruction[10:9] = 2'b00;			// Source Register
			     end
			"G": begin 
				instruction[4:2] = G;
				instruction[10:9] = 2'b00;			// Source Register
			     end
			"H": begin 
				instruction[4:2] = H;
				instruction[10:9] = 2'b00;			// Source Register
			     end
			default : if(second_operand[0] == "#") begin
					instruction[10:9] = 2'b10;	// Source Immediate	
					instruction[4:2] = 0;			
				  end
				  else begin
					$display("%3d - Invalid second operand for all alu_operations, can be source register or source immediate",`__LINE__);
				  end
		endcase
	end
end
endtask
//-----------------------------------------------------------------------------------------------------------//

//-----------------------------------------------------------------------------------------------------------//
// Task to decode NOP & HALT operations instructions
task nop_halt();
begin
	instruction[8] = 0;
	instruction[1:0] = 2'b00;
	case(opcode)
		"NOP": begin 
				instruction[15:11] = `NOP;
				instruction[10:9] = 0;
				instruction[7:5] = 0;
				instruction[4:2] = 0;
		       end
		"HALT": begin 
				instruction[15:11] = `HALT;
				instruction[10:9] = 0;
				instruction[7:5] = 0;
				instruction[4:2] = 0;
		       end
	endcase
end
endtask
//-----------------------------------------------------------------------------------------------------------//

//-----------------------------------------------------------------------------------------------------------//
// Task to decode LOAD operation instructions
task load_operation();
begin
	instruction[8] = 0;
	instruction[1:0] = 2'b00;
	instruction[15:11] = `LOAD;
	case(first_operand) 
		"A": instruction[4:2] = A;
		"B": instruction[4:2] = B;
 		"C": instruction[4:2] = C;
		"D": instruction[4:2] = D;
		"E": instruction[4:2] = E;
		"F": instruction[4:2] = F;
		"G": instruction[4:2] = G;
		"H": instruction[4:2] = H;
		default : begin
			  	$display("%3d - Invalid first operand for LOAD operation, can be only source registers",`__LINE__);
			  end
	endcase
	case(second_operand)
		"A": begin 
			instruction[7:5] = A;
			instruction[10:9] = 2'b00;			// Source Register
		     end
		"B": begin 
			instruction[7:5] = B;
			instruction[10:9] = 2'b00;			// Source Register
	     	     end
		"C": begin 
			instruction[7:5] = C;
			instruction[10:9] = 2'b00;			// Source Register
		     end
		"D": begin 
			instruction[7:5] = D;
			instruction[10:9] = 2'b00;			// Source Register
		     end
		"E": begin 
			instruction[7:5] = E;
			instruction[10:9] = 2'b00;			// Source Register
		     end
		"F": begin 
			instruction[7:5] = F;
			instruction[10:9] = 2'b00;			// Source Register
		     end
		"G": begin 
			instruction[7:5] = G;
			instruction[10:9] = 2'b00;			// Source Register
		     end
		"H": begin 
			instruction[7:5] = H;
			instruction[10:9] = 2'b00;			// Source Register
		     end
		default : if(second_operand[0] == "#") begin
				instruction[10:9] = 2'b10;	// Source Immediate
				instruction[7:5] = 0;
			  end
			  else if(second_operand != "#") begin
				instruction[10:9] = 2'b01;	// Source Memory
				instruction[7:5] = 0;
			  end
	endcase
end
endtask
//-----------------------------------------------------------------------------------------------------------//

//-----------------------------------------------------------------------------------------------------------//
// Task to decode Store operation instructions
task store_operation();
begin
	instruction[8] = 0;
	instruction[1:0] = 2'b00;
	instruction[15:11] = `STORE;
	case(first_operand)
		"A": begin 
			instruction[7:5] = A;
			instruction[10:9] = 2'b00;			// Source Register
		     end
		"B": begin 
			instruction[7:5] = B;
			instruction[10:9] = 2'b00;			// Source Register
	     	     end
		"C": begin 
			instruction[7:5] = C;
			instruction[10:9] = 2'b00;			// Source Register
		     end
		"D": begin 
			instruction[7:5] = D;
			instruction[10:9] = 2'b00;			// Source Register
		     end
		"E": begin 
			instruction[7:5] = E;
			instruction[10:9] = 2'b00;			// Source Register
		     end
		"F": begin 
			instruction[7:5] = F;
			instruction[10:9] = 2'b00;			// Source Register
		     end
		"G": begin 
			instruction[7:5] = G;
			instruction[10:9] = 2'b00;			// Source Register
		     end
		"H": begin 
			instruction[7:5] = H;
			instruction[10:9] = 2'b00;			// Source Register
		     end
		default : begin
			  	$display("%3d - Invalid first operand for STORE operation, can be only source registers",`__LINE__);
			  end
	endcase
	if(second_operand != "#") begin
		instruction[10:9] = 2'b01;	// Source Memory
		instruction[4:2] = 0;
	end
	else begin
		$display("%3d - Invalid second operand for STORE operation, can be only source memory",`__LINE__);
	end
end
endtask
//-----------------------------------------------------------------------------------------------------------//

//-----------------------------------------------------------------------------------------------------------//
// Task to decode MOVE operation instructions
task move_operation();
begin
	instruction[8] = 0;
	instruction[1:0] = 2'b00;
	instruction[15:11] = `MOVE;
	instruction[7:5] = 0;
	instruction[4:2] = 0;
	if(first_operand != "#") begin
		instruction[10:9] = 2'b01;	// Source Memory
	end
	else begin
		$display("%3d - Invalid first operand for MOVE operation, can be only source memory",`__LINE__);
	end
	if(second_operand != "#") begin
		instruction[10:9] = 2'b01;	// Source Memory
	end
	else begin
		$display("Invalid second operand for MOVE operation, can be only source memory",`__LINE__);
	end
end
endtask
//-----------------------------------------------------------------------------------------------------------//

//-----------------------------------------------------------------------------------------------------------//
// Task to decode JUMP operation instructions
task jump_operation();
begin
	instruction[8] = 0;
	instruction[15:11] = `JUMP;
	instruction[7:5] = 0;
	instruction[4:2] = 0;
	instruction[10:9] = 0;
	case(opcode)
		"JMP": 	instruction[1:0] = 2'b00;	// Always Jump
		"JC":	instruction[1:0] = 2'b01;	// Jump if carry
		"JZ":	instruction[1:0] = 2'b10;	// Jump if Zero
		"JS":	instruction[1:0] = 2'b11;	// Jump if Negitive
		default: $display("%3d - Invalid opcode for JUMP operation",`__LINE__);
	endcase
end
endtask
//-----------------------------------------------------------------------------------------------------------//

endmodule 