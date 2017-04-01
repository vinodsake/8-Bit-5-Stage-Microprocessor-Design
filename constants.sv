//-----------------------------------------------------------------------------
//
// Title       : constants
// Author      : vinod sake <vinosake@pdx.edu>
// Company     : Student
//
//-----------------------------------------------------------------------------
//
// File        : constants.sv
// Generated   : 15 Nov 2016
// Last Updated: 16 Nov 2016
//-----------------------------------------------------------------------------
//
// Description : Contains Opcodes and other parameters
//		 
//		 	
//-----------------------------------------------------------------------------

`define ZERO_FLAG 2
`define CARRY_FLAG 1
`define NEG_FLAG 0

// ALU Opcodes, four lower bits from opcode (instruction set 14-11)
`define ALU_PASSTHROUGH 4'b1100 
`define ALU_ADD 4'b0001
`define ALU_SUBTRACT 4'b0010
`define ALU_MULTIPLY 4'b0011
`define ALU_AND 4'b0100
`define ALU_OR 4'b0101
`define ALU_LOGICAL_SHIFT_RIGHT 4'b0110
`define ALU_LOGICAL_SHIFT_LEFT 4'b0111
`define ALU_ARITH_SHIFT_RIGHT 4'b1001
`define ALU_ARITH_SHIFT_LEFT 4'b1010
`define ALU_TWOS_COMPLEMENT 4'b1011
`define ALU_COMPLEMENT 4'b1000

`define NOP 5'b00000
`define ADD 5'b00001
`define SUBTRACT 5'b00010
`define MULTIPLY 5'b00011
`define AND 5'b00100
`define OR 5'b00101
`define LOGICAL_SHIFT_RIGHT 5'b00110
`define LOGICAL_SHIFT_LEFT 5'b00111
`define COMPLEMENT 5'b01000
`define ARITH_SHIFT_RIGHT 5'b01001
`define ARITH_SHIFT_LEFT 5'b01010
`define TWOS_COMPLEMENT 5'b01011
`define PASSTHROUGH 5'b01100
`define LOAD 5'b10000
`define STORE 5'b10001
`define MOVE 5'b10010
`define JUMP 5'b01111
`define HALT 5'b11111


`define SOURCE_REGISTER 2'b00
`define SOURCE_IMMEDIATE 2'b10
`define SOURCE_MEMORY 2'b01



`define S_RESET 5'd0
`define S_FETCH_1 5'd1
`define S_FETCH_2 5'd2
`define S_ALU_OPERATION 5'd3
`define S_STORE_RESULT_1 5'd4
`define S_STORE_RESULT_2 5'd5
`define S_FETCH_IMMEDIATE 5'd6
`define S_COPY_REGISTER_1 5'd7
`define S_FETCH_ADDRESS_1 5'd8
`define S_FETCH_ADDRESS_2 5'd9
`define S_FETCH_MEMORY 5'd10
`define S_STORE_MEMORY 5'd11
`define S_TEMP_FETCH 5'd12
`define S_FETCH_ADDRESS_3 5'd13
`define S_FETCH_ADDRESS_4 5'd14
`define S_TEMP_STORE 5'd15
`define S_LOAD_JUMP_1 5'd16
`define S_LOAD_JUMP_2 5'd17
`define S_EXECUTE_JUMP 5'd18
`define S_HALT 5'd19
`define S_ALU_IMMEDIATE 5'd20
`define S_COPY_REGISTER_2 5'd21



