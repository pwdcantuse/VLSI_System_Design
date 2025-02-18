module Reg_D(
input clk,
input rst,
input stall,
input cacheStall,
input jb,
input [31:0]pc_in,
input [31:0]inst_in,
output reg [31:0]pc_out,
output reg [31:0]inst_out
);

reg [31:0]pc;
reg [31:0]inst;

always@(*)begin
	if(stall ||cacheStall)begin    //keep
		pc = pc_out;
		inst = inst_out;
	end
	else if(jb)begin  //nop
		pc = 32'b0;
		inst = 32'b0000_0000_0000_0000_0000_0000_0000_0100;  
	end
	else begin
		pc = pc_in;
		inst = inst_in;
	end
	
end

always@(posedge clk or posedge rst)begin
	if(rst) begin
		pc_out <= 32'b0;
		inst_out <= 32'b0000_0000_0000_0000_0000_0000_0000_0100;
	end
	else begin
		pc_out <= pc;
		inst_out <= inst;
	end
end


endmodule
