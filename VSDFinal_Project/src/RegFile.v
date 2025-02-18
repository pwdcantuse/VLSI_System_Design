module RegFile (
	input clk,
	input wb_en,
	input [31:0] wb_data,
	input [4:0] rd_index,
	input [4:0] rs1_index,
	input [4:0] rs2_index,
	output[31:0] rs1_data_out,
	output[31:0] rs2_data_out,
input [31:0]reg0
);


reg [31:0] registers [0:31];



assign rs1_data_out = registers[rs1_index];
assign rs2_data_out = registers[rs2_index];
	


always@(posedge clk)begin
/*
	if(wb_en)begin
		if(rd_index==5'b0)begin
			//dont write: rd=x0
		end
		else begin
			registers[rd_index] <= wb_data;
		end
	end
	else begin
		//dont write: wb_en=0
	end*/
	registers[0] <= reg0;
	if(wb_en && rd_index!=5'b0)begin
		registers[rd_index] <= wb_data;
	end
	/*else begin
		//dont write: wb_en=0
	end*/

end















endmodule


