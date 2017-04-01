	//-----------------------------------------------------------------------------
//
// Title       : Control state machine Testbench
// Author      : vinod sake <vinosake@pdx.edu>
// Company     : Student
//
//-----------------------------------------------------------------------------
//
// File        : control_signal_machine_tb.sv
// Generated   : 23 Dec 2016
// Last Updated: 
//-----------------------------------------------------------------------------
//
// Description : Perform testing on control state machine.
//		 	 
//		 	
//-----------------------------------------------------------------------------
`include "constants.sv"

parameter string_len = 200;
enum {A,B,C,D,E,F,G,H}gp_registers;

module control_state_machine_tb();
	logic clock;
	logic reset=1'b1;
	logic [15:0]instruction;	//instruction from instruction register
	logic [4:0]state;		//current state

control_state_machine control_state_machine_dut(
	.clock(clock),
	.reset(reset),
	.instruction(instruction),
	.state(state)
);

integer read_instruction;
integer string_space=0;
integer string_comma=0;
string opcode;
string instruction_string;
string destination;
string source;

//initial instruction[8] = 0;
//initial instruction[1:0] = 2'b00;
 
initial clock = 1'b0;	
always #50 clock = ~clock;

initial begin
	//Reset
	@(negedge clock) begin
		reset = 0;
	end
	@(negedge clock) begin
		reset = 1;
	end

	read_instruction = $fopen("control_state_machine_instruction_input.txt","r");
	while(!$feof(read_instruction)) begin
		@(negedge clock) begin
			if(state == `S_FETCH_2) begin
				instruction = $fscanf(read_instruction, "%s\n", instruction_string);
				instruction_decode(instruction_string);
			end
		end
	end
	$fclose(read_instruction);
	$finish();
end

// Waveform log file and monitoring
initial begin
	$dumpfile("control_state_machine.vcd");
	$dumpvars();
end

task instruction_decode(input string instruction_string);
begin
	string_space = 0;
	string_comma = 0;
	instruction[8] = 0;
	instruction[1:0] = 2'b00;
	for(int i=0; i<instruction_string.len(); i=i+1) begin
		if(instruction_string[i] == "_") begin
			string_space = i;
		end
		else if(instruction_string[i] == ",") begin
			string_comma = i;
		end
	end
	
	if(string_space == 0 && string_comma == 0) begin
		opcode = instruction_string;
	end
	else begin
		opcode = instruction_string.substr(0,string_space-1);
		destination = instruction_string.substr(string_space+1,string_comma-1);
		source =  instruction_string.substr(string_comma+1,instruction_string.len()-1);
	end

	case(opcode) 
		"NOP":	instruction[15:11] = `NOP;
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
		"LOAD":	instruction[15:11] = `LOAD;
		"STORE":instruction[15:11] = `STORE;
		"MOVE": instruction[15:11] = `MOVE;
		"JUMP":	instruction[15:11] = `JUMP;
		"HALT":	instruction[15:11] = `HALT;
	endcase
	
	case(source)
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
		default: if(instruction[15:11] == `LOAD) begin
				if(source[0] == "#") begin
					instruction[10:9] = 2'b10;	// Source Immediate
				end
				else begin
					instruction[10:9] = 2'b01;	// Source Memory
				end
			 end
			 else if(instruction[15] == 1'b0 && instruction[15:11] != 5'b01101 && instruction[15:11] != 5'b01110 && instruction[15:11] != `NOP && instruction[15:11] != `HALT) begin
				if(source[0] == "#") begin		// Source Immediate
					instruction[10:9] = 2'b10;
				end
				else begin				// Source Memory
					$display("operand cannot be register or immediate for ALU operations");
				end
			 end
	endcase
	
	case(destination)
		"A": instruction[4:2] = A;
		"B": instruction[4:2] = B;
 		"C": instruction[4:2] = C;
		"D": instruction[4:2] = D;
		"E": instruction[4:2] = E;
		"F": instruction[4:2] = F;
		"G": instruction[4:2] = G;
		"H": instruction[4:2] = H;
		default: if(instruction[15:11] == `MOVE) begin
				if(destination[0] == "#") begin		// Source Immediate
					$display("address must be from RAM or ROM as operation is MOVE");;
				end
				else begin				// Source Memory
					instruction[10:9] = 2'b01;
				end
			 end
	endcase

end
endtask

endmodule
