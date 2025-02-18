module Decoder (
	input [31:0] inst,
	output [4:0] dc_out_opcode,
	output [2:0] dc_out_func3,
	output [6:0] dc_out_func7, /*move to 7 bit*/
	output [4:0] dc_out_func5,
	output [4:0] dc_out_rs1_index,
	output [4:0] dc_out_rs2_index,
	output [4:0] dc_out_rd_index
);


	assign dc_out_opcode = inst[6:2];
	assign dc_out_func3 = inst[14:12];
	assign dc_out_func5 = inst[31:27];
	assign dc_out_func7 = inst[31:25]; /*move to 7 bit*/
	assign dc_out_rs1_index = inst[19:15];
	assign dc_out_rs2_index = inst[24:20];
	assign dc_out_rd_index = inst[11:7];


endmodule
