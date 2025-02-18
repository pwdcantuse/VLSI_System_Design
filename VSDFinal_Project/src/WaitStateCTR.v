module WaitStateCTR(
input clk,
input Load,
input [1:0] LoadValue,
input clk_main,
output Carry
);

reg [1:0] Count;

always@(posedge clk_main) begin
	Count <= Count -2'd1;
end

always@(posedge clk) begin
	if(Load)
		Count <= LoadValue;
end

assign Carry = (Count == 2'b0) ? 1'd1 : 1'd0;

endmodule
