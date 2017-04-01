//-----------------------------------------------------------------------------
//
// Title       : Arithmetic & Logic Unit 
// Author      : vinod sake <vinosake@pdx.edu>
// Company     : Student
//
//-----------------------------------------------------------------------------
//
// File        : ALU.sv
// Generated   : 12 Nov 2016
// Last Updated: 15 Dec 2016
//-----------------------------------------------------------------------------
//
// Description : Arithmetic & Logic Unit is used to perform Arthematic & 
//		 logical operations. 	
//-----------------------------------------------------------------------------
`include "constants.sv"

module alu(
	input reset,			// Asynchronous Rest
	input [7:0]primary_operand,	// output of GP register (register operand)
	input [7:0]secondary_operand,	// operand from data bus
	input [3:0]cmnd,		// cmnd code from control signal translator
	output logic [15:0]result,	// ALU result
	output logic [2:0]flags		// Zero, carry & Negative flags
	);

always_comb begin
	if(reset == 1'b0) begin
		result[15:0] = 0;
		flags[2:0] = 0;
	end
	else begin
		//result[15:0] = 0; 	// To avoid latch creation ??????????
		case(cmnd)
			`ALU_PASSTHROUGH: begin						// when opcode is MOVE, data from secondary operand is directly latched.
				result[7:0] = secondary_operand;
				flags[`CARRY_FLAG] = 1'b0;				// There is no carry on PASSTHROUGH cmnd
				flags[`NEG_FLAG] = result[7];				
			end
			`ALU_ADD: begin
				result[8:0] = primary_operand + secondary_operand;
				flags[`CARRY_FLAG] = result[8];				// check if carry is generated
				flags[`NEG_FLAG] = result[7];
			end
			`ALU_SUBTRACT: begin
				result[8:0] = primary_operand - secondary_operand;
				flags[`CARRY_FLAG] = result[8];				// if bit is 1, then borrow is done
				flags[`NEG_FLAG] = result[7];
			end
			`ALU_MULTIPLY: begin
				result[15:0] = primary_operand * secondary_operand;
				flags[`CARRY_FLAG] = 1'b0;
				flags[`NEG_FLAG] = result[15];
			end
			`ALU_AND: begin
				result[7:0] = primary_operand & secondary_operand;
				flags[`CARRY_FLAG] = 1'b0;
				flags[`NEG_FLAG] = result[7];
			end
			`ALU_OR: begin
				result[7:0] = primary_operand | secondary_operand;
				flags[`CARRY_FLAG] = 1'b0;
				flags[`NEG_FLAG] = result[7];
			end
			`ALU_LOGICAL_SHIFT_RIGHT: begin					// zero is added at MSB
				result[7:0] = primary_operand >> 1;
				flags[`CARRY_FLAG] = primary_operand[0];
				flags[`NEG_FLAG] = result[7];
			end
			`ALU_LOGICAL_SHIFT_LEFT: begin					// Zero is added at LSB
				result[7:0] = primary_operand << 1;
				flags[`CARRY_FLAG] = primary_operand[7];		// carry is set to be MSB
				flags[`NEG_FLAG] = result[7];
			end
			`ALU_ARITH_SHIFT_RIGHT: begin					// MSB remains same and all other lower bits shifts right
				result[7:0] = primary_operand >>> 1;
				flags[`CARRY_FLAG] = primary_operand[0];		// carry is set to be LSB
				flags[`NEG_FLAG] = result[7];
			end
			`ALU_ARITH_SHIFT_LEFT: begin					// LSB remains same and all other higher bits shifts left
				result[7:0] = primary_operand <<< 1;
				flags[`CARRY_FLAG] = primary_operand[7];		// carry is set to be MSB
				flags[`NEG_FLAG] = result[7];
			end
			`ALU_TWOS_COMPLEMENT: begin
				result[7:0] = ~primary_operand;				// Complement
				result[7:0] = result[7:0] + 8'd1;			// add one
				flags[`CARRY_FLAG] = 1'b0;
				flags[`NEG_FLAG] = result[7];
			end
			`ALU_COMPLEMENT: begin						// complement
				result[7:0] = ~primary_operand;
				flags[`CARRY_FLAG] = 1'b0;
				flags[`NEG_FLAG] = result[7];
			end
			default: begin
				result[15:0] = 16'd0;
				flags[`CARRY_FLAG] = 1'b0;
				flags[`NEG_FLAG] = 1'b0;
			end
		endcase
	end
	
	if(cmnd == `ALU_MULTIPLY) begin
		flags[`ZERO_FLAG] = (result[15:0] == 16'd0) ? 1'b1 : 1'b0;
	end
	else begin
		flags[`ZERO_FLAG] = (result[7:0] == 8'd0) ? 1'b1 : 1'b0;
	end
end
endmodule 