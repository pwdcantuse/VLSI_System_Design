`define BYTE 2'd0
`define HALFWORD 2'd1
`define WORD 2'd2

module TagRAM(
input [1:0] LoadSelect,
input [5:0] TagIN,
input [9:0] Address,
input Write,
input clk,
output reg [5:0] TagOUT_1,
output reg [5:0] TagOUT_2,
output reg [5:0] TagOUT_3,
output reg [5:0] TagOUT_4

);

reg [5:0] TagRAM [1023:0];

always@(negedge clk) begin
	if(Write)
		case(LoadSelect)
			`BYTE: begin
				TagRAM[Address] <= TagIN;;
				TagRAM[Address+10'd1] <= TagRAM[Address+10'd1];
				TagRAM[Address+10'd2] <= TagRAM[Address+10'd2];
				TagRAM[Address+10'd3] <= TagRAM[Address+10'd3];
			end
			`HALFWORD: begin
				TagRAM[Address] <= TagIN;
				TagRAM[Address+10'd1] <= TagIN;
				TagRAM[Address+10'd2] <= TagRAM[Address+10'd2];
				TagRAM[Address+10'd3] <= TagRAM[Address+10'd3];
			end
			`WORD: begin
				TagRAM[Address] <= TagIN;
				TagRAM[Address+10'd1] <= TagIN;
				TagRAM[Address+10'd2] <= TagIN;
				TagRAM[Address+10'd3] <= TagIN;
			end
		endcase
end

always@(posedge clk) begin
	case(LoadSelect)
			`BYTE: begin
				TagOUT_1 <= TagRAM[Address];
				TagOUT_2 <= 6'dx;
				TagOUT_3 <= 6'dx;
				TagOUT_4 <= 6'dx;
			end
			`HALFWORD: begin
				TagOUT_1 <= TagRAM[Address];
				TagOUT_2 <= TagRAM[Address+10'd1];
				TagOUT_3 <= 6'dx;
				TagOUT_4 <= 6'dx;
			end
			`WORD: begin
				TagOUT_1 <= TagRAM[Address];
				TagOUT_2 <= TagRAM[Address+10'd1];
				TagOUT_3 <= TagRAM[Address+10'd2];
				TagOUT_4 <= TagRAM[Address+10'd3];
			end
		endcase
	
end


endmodule
