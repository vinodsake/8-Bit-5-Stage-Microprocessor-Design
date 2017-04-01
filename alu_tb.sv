//-----------------------------------------------------------------------------
//
// Title       : Arithmetic & Logic Unit Testbench
// Author      : vinod sake <vinosake@pdx.edu>
// Company     : Student
//
//-----------------------------------------------------------------------------
//
// File        : alu_tb.sv
// Generated   : 15 Dec 2016
// Last Updated: 
//-----------------------------------------------------------------------------
//
// Description : Perform different tesings on operations in ALU 
//		  	
//-----------------------------------------------------------------------------
`include "constants.sv"


module alu_tb();
	logic clock;
	logic reset = 1'b1;			// Asynchronous Rest
	logic [7:0]primary_operand;	// output of GP register (register operand)
	logic [7:0]secondary_operand;	// operand from data bus
	logic [3:0]operation;		// operation code from control signal translator
	logic [15:0]result;		// ALU result
	logic [2:0]flags;		// Zero, carry & Negative flags


alu alu_dut(
	.reset(reset),
	.primary_operand(primary_operand),
	.secondary_operand(secondary_operand),
	.operation(operation),
	.result(result),
	.flags(flags)
);

initial clock = 1'b0;
always #50 clock = ~clock;

initial begin
	system_reset();									// system reset

	//ALU_PASSTHROUGH Test
	test_operation(8'hff,8'h7e,`ALU_PASSTHROUGH,8'h7e,3'b000,`__LINE__);		// Positive secondary operand
	test_operation(8'hff,8'h00,`ALU_PASSTHROUGH,8'h00,3'b100,`__LINE__);		// Zero secondary operand	
	test_operation(8'hff,-8'h7e,`ALU_PASSTHROUGH,-8'h7e,3'b001,`__LINE__);		// 

	//ALU_ADD Test
	test_operation(8'd20,8'd25,`ALU_ADD,8'd45,3'b000,`__LINE__);			// result is positive and with in the unsigned range
	test_operation(8'd0,8'd0,`ALU_ADD,8'd0,3'b100,`__LINE__);			// result is zero
	test_operation(8'd246,8'd10,`ALU_ADD,8'd0,3'b110,`__LINE__);			// result is zero with carry with out of unsigned range
	test_operation(-8'd10,8'd10,`ALU_ADD,8'd0,3'b110,`__LINE__);			// result is zero
	test_operation(8'd125,8'd10,`ALU_ADD,8'd135,3'b001,`__LINE__);			// result is negitive and out of signed range
	

	//ALU_SUBTRACT Test
	test_operation(8'd20,8'd5,`ALU_SUBTRACT,8'd15,3'b000,`__LINE__);		// result is positive
	test_operation(8'd33,8'd33,`ALU_SUBTRACT,8'd0,3'b100,`__LINE__);		// result is zero
	test_operation(8'hff,8'h03,`ALU_SUBTRACT,8'hfc,3'b001,`__LINE__);		// result is negative
	test_operation(8'h4f,8'h80,`ALU_SUBTRACT,8'hcf,3'b011,`__LINE__);		// result is negative and borrow (decimal: 79-128 = -49(1cfh))
	test_operation(8'd0,-8'd127,`ALU_SUBTRACT,8'd127,3'b010,`__LINE__);		// result is negative and borrow

	//ALU_MULTIPLY Test
	test_operation16(8'd12,8'd5,`ALU_MULTIPLY,16'd60,3'b000,`__LINE__);		// small number multiplication
	test_operation16(8'd255,8'd255,`ALU_MULTIPLY,16'd65025,3'b001,`__LINE__);	// large number multiplication & negitive flag is set
	test_operation16(8'd0,8'd0,`ALU_MULTIPLY,16'd0,3'b100,`__LINE__);		// zero flag is set
	test_operation16(-8'd100,8'd5,`ALU_MULTIPLY,-16'd500,3'b001,`__LINE__);		// negitive flag is set		(-100 <==> 2's 156 therefore system is multiplying 156x5 = 780) ??? not sure how to perform negitive multiplication
	test_operation16(-8'd25,-8'd4,`ALU_MULTIPLY,16'd100,3'b000,`__LINE__);		// 				(-25 <==> 2's 231 & -4 <==> 2's 252 therefore system is multiplying 231x252 = 58,212) ??? not sure how to perform negitive multiplication)

	//ALU_AND Test
	test_operation(8'b1111_1111,8'b1111_1111,`ALU_AND,8'b1111_1111,3'b001,`__LINE__);// negitive flag is set
	test_operation(8'b1010_1010,8'b0101_0101,`ALU_AND,8'b0000_0000,3'b100,`__LINE__);// Zero flag is set
	test_operation(8'b0110_1011,8'b0101_0011,`ALU_AND,8'b0100_0011,3'b000,`__LINE__);// Normal AND operation 

	//ALU_OR Test
	test_operation(8'b1111_1111,8'b1111_1111,`ALU_OR,8'b1111_1111,3'b001,`__LINE__);// negitive flag is set
	test_operation(8'b0000_0000,8'b0000_0000,`ALU_OR,8'b0000_0000,3'b100,`__LINE__);// Zero flag is set
	test_operation(8'b0110_1011,8'b0101_0011,`ALU_OR,8'b0111_1011,3'b000,`__LINE__);// Normal OR operation 

	//ALU_LOGICAL_SHIFT_RIGHT Test
	test_operation(8'b1111_1111,8'b1111_1111,`ALU_LOGICAL_SHIFT_RIGHT,8'b0111_1111,3'b010,`__LINE__);// carry flag is set as 1 is shifted out 		
	test_operation(8'b0000_0000,8'b0000_0000,`ALU_LOGICAL_SHIFT_RIGHT,8'b0000_0000,3'b100,`__LINE__);// Zero flag is set
	test_operation(8'b0110_1010,8'b0101_0011,`ALU_LOGICAL_SHIFT_RIGHT,8'b0011_0101,3'b000,`__LINE__);// carry flag is not set as 0 is shifted out 

	//ALU_LOGICAL_SHIFT_LEFT Test
	test_operation(8'b1111_1111,8'b1111_1111,`ALU_LOGICAL_SHIFT_LEFT,8'b1111_1110,3'b011,`__LINE__);// carry flag is set as 1 is shifted out & negitive flag is set
	test_operation(8'b0000_0000,8'b0000_0000,`ALU_LOGICAL_SHIFT_LEFT,8'b0000_0000,3'b100,`__LINE__);// Zero flag is set
	test_operation(8'b0010_1010,8'b0101_0011,`ALU_LOGICAL_SHIFT_LEFT,8'b0101_0100,3'b000,`__LINE__);// carry flag is not set as 0 is shifted out

	//ALU_ARITH_SHIFT_RIGHT Test
	test_operation(8'b1111_0000,8'b1111_1111,`ALU_ARITH_SHIFT_RIGHT,8'b1111_1000,3'b001,`__LINE__);// carry flag is not set as 0 is shifted out & negitive flag is set		TEST FAILED! as it is performing logical shift i.e inserting zero in MSB
	test_operation(8'b0000_0000,8'b0000_0000,`ALU_ARITH_SHIFT_RIGHT,8'b0000_0000,3'b100,`__LINE__);// Zero flag is set
	test_operation(8'b0110_1010,8'b0101_0011,`ALU_ARITH_SHIFT_RIGHT,8'b0011_0101,3'b000,`__LINE__);// carry flag is not set as 0 is shifted out 

	//ALU_ARITH_SHIFT_LEFT Test
	test_operation(8'b1111_1111,8'b1111_1111,`ALU_ARITH_SHIFT_LEFT,8'b1111_1110,3'b011,`__LINE__);// carry flag is set as 1 is shifted out & negitive flag is set
	test_operation(8'b1000_0000,8'b0000_0000,`ALU_ARITH_SHIFT_LEFT,8'b0000_0000,3'b110,`__LINE__);// Zero flag is set & carry flag is set as 1 is shifted out
	test_operation(8'b0110_1011,8'b0101_0011,`ALU_ARITH_SHIFT_LEFT,8'b1101_0111,3'b001,`__LINE__);// carry flag is not set as 0 is shifted out & negitive flag is set		TEST FAILED! as it is performing logical shift i.e inserting zeron in LSB

	//ALU_TWOS_COMPLEMENT Test
	test_operation(8'd1,8'b1111_1111,`ALU_TWOS_COMPLEMENT,-8'd1,3'b001,`__LINE__);		// negitive flag is set
	test_operation(8'd0,8'b1111_1111,`ALU_TWOS_COMPLEMENT,8'd0,3'b100,`__LINE__);		// Zero flag is set & carry flag is set
	test_operation(8'd128,8'b1111_1111,`ALU_TWOS_COMPLEMENT,-8'd128,3'b001,`__LINE__);	// negitive flag is set
	test_operation(-8'd45,8'b1111_1111,`ALU_TWOS_COMPLEMENT,8'd45,3'b000,`__LINE__);	

	//ALU_COMPLEMENT Test
	test_operation(8'b0000_0000,8'b1111_1111,`ALU_COMPLEMENT,8'b1111_1111,3'b001,`__LINE__);// negitive flag is set
	test_operation(8'b1111_1111,8'b1111_1111,`ALU_COMPLEMENT,8'b0000_0000,3'b100,`__LINE__);// Zero flag is set & carry flag is set
	test_operation(8'b1010_1010,8'b1111_1111,`ALU_COMPLEMENT,8'b0101_0101,3'b000,`__LINE__);// negitive flag is set
	
	
	$finish;
end




task test_operation(input [7:0]tprimary, input [7:0]tsecondary, input [3:0]toperation, input [7:0]texpected_value, input [2:0]texpected_flags, input integer lineNum );
begin
	@(negedge clock) begin
		primary_operand = tprimary;
		secondary_operand = tsecondary;
		operation = toperation;
	end
	@(posedge clock) begin 
		#5;
		if(result[7:0] != texpected_value) begin
			$display("%3d - Test failed! for ALU, expected result %d, got %d", lineNum, texpected_value, result[7:0]);
		end
		else begin
			$display("%3d - Test passed! for ALU result", lineNum);
		end
		if(flags[2:0] != texpected_flags) begin
			$display("%3d - Test failed! for flags, expected flags %d, got %d", lineNum, texpected_flags, flags);
		end
		else begin
			$display("%3d - Test passed! for flags result", lineNum);
		end
	end

end
endtask

// Waveform log file and monitoring
initial begin
	$dumpfile("alu.vcd");
	$dumpvars();
	//$monitor("time: %d, result: %d flags: %d", $time, result, flags);
end

task test_operation16(input [7:0]tprimary, input [7:0]tsecondary, input [3:0]toperation, input [15:0]texpected_value, input [2:0]texpected_flags, input integer lineNum );
begin
	@(negedge clock) begin
		primary_operand = tprimary;
		secondary_operand = tsecondary;
		operation = toperation;
	end
	@(posedge clock) begin 
		#5;
		if(result[15:0] != texpected_value) begin
			$display("%3d - Test failed! for ALU, expected result %d, got %d", lineNum, texpected_value, result);
		end
		else begin
			$display("%3d - Test passed! for ALU result", lineNum);
		end
		if(flags[2:0] != texpected_flags) begin
			$display("%3d - Test failed! for flags, expected flags %d, got %d", lineNum, texpected_flags, flags);
		end
		else begin
			$display("%3d - Test passed! for flags result", lineNum);
		end
	end

end
endtask

task system_reset;
begin
	@(negedge clock) begin
		reset = 1'b0;
	end
	@(negedge clock) begin
		reset = 1'b1;
	end
end
endtask





endmodule 