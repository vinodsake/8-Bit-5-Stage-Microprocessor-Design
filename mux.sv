
module mux8x1(
	output logic data_out,
	input logic [0:7]in,
	input logic [2:0]OP,
	input logic clk
	);
logic out;

always_comb
case(OP)
	0 : out <= in[0];
	1 : out <= in[1];
	2 : out <= in[2];
	3 : out <= in[3];
	4 : out <= in[4];
	5 : out <= in[5];
	6 : out <= in[6];
	7 : out <= in[7];
endcase

always_ff@(posedge clk) begin
	data_out <= out;
end
endmodule

module shift(
	output logic [5:0]Data_out,
	input logic [5:0]Data_in,
	input logic [2:0]OP,
	input logic clk
	//output logic [5:0]out
	);

//logic [5:0]out;

mux8x1 mux0(Data_out[0],{Data_out[0],Data_out[1],{1'b0},Data_out[1],Data_out[5],{1'b0},Data_in[0],{1'bx}},OP[2:0],clk);
mux8x1 mux1(Data_out[1],{Data_out[1],Data_out[2],Data_out[0],Data_out[2],Data_out[0],{1'b0},Data_in[1],{1'bx}},OP[2:0],clk);
mux8x1 mux2(Data_out[2],{Data_out[2],Data_out[3],Data_out[1],Data_out[3],Data_out[1],{1'b0},Data_in[2],{1'bx}},OP[2:0],clk);
mux8x1 mux3(Data_out[3],{Data_out[3],Data_out[4],Data_out[2],Data_out[4],Data_out[2],{1'b0},Data_in[3],{1'bx}},OP[2:0],clk);
mux8x1 mux4(Data_out[4],{Data_out[4],Data_out[5],Data_out[3],Data_out[5],Data_out[3],{1'b0},Data_in[4],{1'bx}},OP[2:0],clk);
mux8x1 mux5(Data_out[5],{Data_out[5],Data_out[5],Data_out[4],Data_out[0],Data_out[4],{1'b0},Data_in[5],{1'bx}},OP[2:0],clk);

endmodule 

module shiftreg2_tb();

logic [2:0] OP;
logic [5:0] data_out;
logic [5:0] data_in;
logic clk; 

shift s1(
	.clk(clk), 
	.Data_in(data_in), 
	.Data_out(data_out), 
	.OP(OP));

initial clk = 1'b0;
always #5
clk = ~clk;

initial 
begin
OP = 3'b101;
#10 OP = 3'b110;
#10 OP = 3'b000;
#10 OP = 3'b001;
#10 OP = 3'b010;
#10 OP = 3'b011;
#10 OP = 3'b100;
#10 OP = 3'b001;
#10 OP = 3'b010;
#10 OP = 3'b111;
#10 OP = 3'b011;
#10 OP = 3'b101;
#10 OP = 3'b100;
$stop;
end

always@(negedge clk) begin
	data_in = 6'b101011;
end

always@(posedge clk)
begin
$monitor($time, " op code = %b , register value = %b ", OP, data_out);
end

endmodule


