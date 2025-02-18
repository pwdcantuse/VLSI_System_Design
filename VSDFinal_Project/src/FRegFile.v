// modified for floating point by AA, 2022/12/22
module FRegFile (
	input clk,
	input wb_en,
	input [31:0] wb_data,
	input [4:0] rd_index,
	input [4:0] rs1_index,
	input [4:0] rs2_index,
	output[31:0] rs1_data_out,
	output[31:0] rs2_data_out
);

reg [31:0] registers [0:31];

assign rs1_data_out = registers[rs1_index];
assign rs2_data_out = registers[rs2_index];

always@(posedge clk)begin
	if(wb_en)begin
		registers[rd_index] <= wb_data;
	end
end
endmodule// endmodify
