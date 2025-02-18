`include "./src/Controller_Cache.v"
`include "./src/Comparator.v"
`include "./src/DataMUX.v"
`include "./src/DataRAM.v"
`include "./src/TagRAM.v"
`include "./src/ValidRAM.v"

`define BYTE 2'd0
`define HALFWORD 2'd1
`define WORD 2'd2

module Cache(
input [2:0] FUNC3,
input rst,
input clk_main,
input clk,
input PStrobe,
input [15:0] PAddress,
input [1:0] PRW,		 //CHANGE
inout [31:0] PData,
inout [31:0] SysData,
output SysRW,
output PReady,
output SysStrobe,
output [15:0] SysAddress,
output [1:0] LoadSelect

);


wire PDataOE;
wire SysDataOE;
wire [31:0] DataRAM_OUT, DataRAM_IN;
wire [31:0] PDataout;
wire Write;
wire CacheDataSelect;
wire PDataSelect;
wire Match;
wire Valid_1, Valid_2, Valid_3, Valid_4;
wire [5:0] TagOUT_1, TagOUT_2, TagOUT_3, TagOUT_4;

assign PData = PDataOE ? PDataout : 32'hz;
reg [31:0] SysData_reg;
always@(*) begin
	if(SysDataOE)begin
		case(LoadSelect) 
			`BYTE: SysData_reg = {24'd0, PData[7:0]};
			`HALFWORD: SysData_reg = {16'd0, PData[15:0]};
			`WORD: SysData_reg = PData;
			default: SysData_reg = 32'dz;
		endcase

	end
	else 
		SysData_reg = 32'hz;
end
assign SysData = SysData_reg;
//assign SysData = SysDataOE ? PData : 32'hz;
assign SysAddress = PAddress;

TagRAM TagRAM1(
.LoadSelect(LoadSelect),
.TagIN(PAddress[15:10]),
.Address(PAddress[9:0]),
.Write(Write),
.clk(clk),
.TagOUT_1(TagOUT_1),
.TagOUT_2(TagOUT_2),
.TagOUT_3(TagOUT_3),
.TagOUT_4(TagOUT_4)
);

ValidRAM ValidRAM1(
.LoadSelect(LoadSelect),
.Address(PAddress[9:0]),
.Write(Write),
.rst(rst),
.clk(clk),
.ValidOUT_1(Valid_1),
.ValidOUT_2(Valid_2),
.ValidOUT_3(Valid_3),
.ValidOUT_4(Valid_4)
);

DataMUX CacheDataInputMUX(
.S(CacheDataSelect),
.A(SysData),
.B(PData),
.Z(DataRAM_IN)
);

DataMUX PDataMUX(
.S(PDataSelect),
.A(SysData),
.B(DataRAM_OUT),
.Z(PDataout)
);

DataRAM DataRAM1(
.LoadSelect(LoadSelect),
.Address(PAddress[9:0]),
.DataIN(DataRAM_IN),
.Write(Write),
.clk(clk),
.DataOUT(DataRAM_OUT)
);

Comparator Comparator1(
.Tag1_C(TagOUT_1),
.Tag2_C(TagOUT_2),
.Tag3_C(TagOUT_3),
.Tag4_C(TagOUT_4),
.TagP(PAddress[15:10]),
.LoadSelect(LoadSelect),
.Match(Match)
);

Controller_Cache Controller(
.FUNC3(FUNC3),
.clk_main(clk_main),
.clk(clk),
.rst(rst),
.PStrobe(PStrobe),
.PRW(PRW),
.Match(Match),
.Valid_1(Valid_1),
.Valid_2(Valid_2),
.Valid_3(Valid_3),
.Valid_4(Valid_4),
.PReady(PReady),
.Write(Write),
.CacheDataSelect(CacheDataSelect),
.PDataSelect(PDataSelect),
.SysDataOE(SysDataOE),
.PDataOE(PDataOE),
.SysStrobe(SysStrobe),
.SysRW(SysRW),
.LoadSelect(LoadSelect)
);




endmodule
