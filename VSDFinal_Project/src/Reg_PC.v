module Reg_PC(
input clk,
input rst,
input cacheStall,
input stall,
input [31:0] next_pc,
output reg [31:0] current_pc

);
	always@(posedge clk or posedge rst)begin
	    if(rst)begin
			current_pc <= 32'b0;
		end
		else begin 
			if(stall||cacheStall)begin
				current_pc <= current_pc;
			end
			else begin
				current_pc <= next_pc;
			end
		end
	end
	

endmodule
