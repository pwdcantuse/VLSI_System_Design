`define BYTE 2'd0
`define HALFWORD 2'd1
`define WORD 2'd2

module DataRAM(
input [1:0] LoadSelect,
input [9:0] Address,
input [31:0] DataIN,
input Write,
input clk,
output reg [31:0] DataOUT

);

reg [7:0] DataRAM [1023:0];
wire [7:0] DataRAM40 = DataRAM[40];
wire [7:0] DataRAM41 = DataRAM[41];
wire [7:0] DataRAM42 = DataRAM[42];
wire [7:0] DataRAM43 = DataRAM[43];
always@(negedge clk) begin
	if(Write) begin
		case(LoadSelect)
			`BYTE: begin
				DataRAM[Address] <= DataIN[7:0];
				DataRAM[Address+10'd1] <= DataRAM[Address+10'd1];
				DataRAM[Address+10'd2] <= DataRAM[Address+10'd2];
				DataRAM[Address+10'd3] <= DataRAM[Address+10'd3];
			end
			`HALFWORD: begin
				DataRAM[Address] <= DataIN[7:0];
				DataRAM[Address+10'd1] <= DataIN[15:8];
				DataRAM[Address+10'd2] <= DataRAM[Address+10'd2];
				DataRAM[Address+10'd3] <= DataRAM[Address+10'd3];
			end
			`WORD: begin
				DataRAM[Address] <= DataIN[7:0];
				DataRAM[Address+10'd1] <= DataIN[15:8];
				DataRAM[Address+10'd2] <= DataIN[23:16];
				DataRAM[Address+10'd3] <= DataIN[31:24];
			end
		endcase
	end
end

always@(posedge clk) begin
	case(LoadSelect)
			`BYTE: begin
				DataOUT[7:0] <= DataRAM[Address];
				DataOUT[15:8] <= 8'dx;
				DataOUT[23:16] <= 8'dx;
				DataOUT[31:24] <= 8'dx;
			end
			`HALFWORD: begin
				DataOUT[7:0] <= DataRAM[Address];
				DataOUT[15:8] <= DataRAM[Address+10'd1];
				DataOUT[23:16] <= 8'dx;
				DataOUT[31:24] <= 8'dx;
			end
			`WORD: begin
				DataOUT[7:0] <= DataRAM[Address];
				DataOUT[15:8] <= DataRAM[Address+10'd1];
				DataOUT[23:16] <= DataRAM[Address+10'd2];
				DataOUT[31:24] <= DataRAM[Address+10'd3];
			end
	endcase
end

endmodule
