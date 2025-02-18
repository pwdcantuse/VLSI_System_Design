module Reg_E(
input clk,
input rst,
input cacheStall,
input stall,
input jb,
input [31:0]pc_in,
input [31:0]rs1_data_in,
input [31:0]rs2_data_in,
input [31:0]imm_in,
output reg [31:0]pc_out,
output reg [31:0]rs1_data_out,
output reg [31:0]rs2_data_out,
output reg [31:0]imm_out
);

reg [31:0]pc;
reg [31:0]rs1_data;
reg [31:0]rs2_data;
reg [31:0]imm;


always@(*)begin
	if(cacheStall)begin
		pc = pc_out;
		rs1_data = rs1_data_out;
		rs2_data = rs2_data_out;
		imm = imm_out;
	end
	else if(stall || jb)begin             //stall or jb : nop
		pc = 32'b0;
		rs1_data = 32'b0;
		rs2_data = 32'b0;
		imm = 32'b0;
	end
	else begin
		pc = pc_in;
		rs1_data = rs1_data_in;
		rs2_data = rs2_data_in;
		imm = imm_in;
	end
	
end

always@(posedge clk or posedge rst)begin
	if(rst) begin
		pc_out <= 32'b0;
		rs1_data_out <= 32'b0;
		rs2_data_out <= 32'b0;
		imm_out <= 32'b0;
	end
	else begin
		pc_out <= pc;
		rs1_data_out <= rs1_data;
		rs2_data_out <= rs2_data;
		imm_out <= imm;
	end
end


endmodule
