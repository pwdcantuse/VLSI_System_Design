`define BYTE 2'd0
`define HALFWORD 2'd1
`define WORD 2'd2

module ValidRAM(
input [1:0] LoadSelect,
input [9:0] Address,
input Write,
input rst,
input clk,
output reg ValidOUT_1,
output reg ValidOUT_2,
output reg ValidOUT_3,
output reg ValidOUT_4

);

reg [1023:0] ValidRAM;
integer i;

always@(negedge clk or posedge rst) begin
	if(rst) begin
		for(i = 10'd0; i < 10'd1023; i = i+10'd1) begin
			ValidRAM[i] <= 1'd0;
		end
	end
	else if (Write) begin
		case(LoadSelect)
			`BYTE: begin
				ValidRAM[Address] <= 1'd1;
				ValidRAM[Address+10'd1] <= ValidRAM[Address+10'd1];
				ValidRAM[Address+10'd2] <= ValidRAM[Address+10'd2];
				ValidRAM[Address+10'd3] <= ValidRAM[Address+10'd3];
			end
			`HALFWORD: begin
				ValidRAM[Address] <= 1'd1;
				ValidRAM[Address+10'd1] <= 1'd1;
				ValidRAM[Address+10'd2] <= ValidRAM[Address+10'd2];
				ValidRAM[Address+10'd3] <= ValidRAM[Address+10'd3];
			end
			`WORD: begin
				ValidRAM[Address] <= 1'd1;
				ValidRAM[Address+10'd1] <= 1'd1;
				ValidRAM[Address+10'd2] <= ValidRAM[Address+10'd2];
				ValidRAM[Address+10'd3] <= ValidRAM[Address+10'd3];
			end
		endcase
	end

end

always@(posedge clk) begin
	case(LoadSelect)
		`BYTE: begin
			ValidOUT_1 <= ValidRAM[Address];
			ValidOUT_2 <= 1'd0;
			ValidOUT_3 <= 1'd0;
			ValidOUT_4 <= 1'd0;
		end
		`HALFWORD: begin
			ValidOUT_1 <= ValidRAM[Address];
			ValidOUT_2 <= ValidRAM[Address+10'd1];
			ValidOUT_3 <= 1'd0;
			ValidOUT_4 <= 1'd0;
		end
		`WORD: begin
			ValidOUT_1 <= ValidRAM[Address];
			ValidOUT_2 <= ValidRAM[Address+10'd1];
			ValidOUT_3 <= ValidRAM[Address+10'd2];
			ValidOUT_4 <= ValidRAM[Address+10'd3];
		end
	endcase
end

endmodule
