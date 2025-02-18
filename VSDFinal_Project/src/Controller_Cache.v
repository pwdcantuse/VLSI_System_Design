`include "./src/WaitStateCTR.v"
`define LOAD_BYTE 3'd0
`define LOAD_HALFWORD 3'd1
`define LOAD_WORD 3'd2
`define LOAD_UBYTE 3'd4
`define LOAD_UHALFWORD 3'd5

`define STATE_IDLE 4'd0
`define STATE_READ 4'd1
`define STATE_READMISS 4'd2
`define STATE_READSYS 4'd3
`define STATE_READDATA 4'd4
`define STATE_WRITE 4'd5
`define STATE_WRITEHIT 4'd6
`define STATE_WRITEMISS 4'd7
`define STATE_WRITESYS 4'd8
`define STATE_WRITEDATA 4'd9
`define READ 1'd1
`define WRITE 1'd0

module Controller_Cache(
input [2:0] FUNC3,
input clk_main,
input clk,
input rst,
input PStrobe,
input [1:0] PRW,		 //CHANGE
input Match, 
input Valid_1,
input Valid_2,
input Valid_3,
input Valid_4,
output PReady,
output Write,
output CacheDataSelect,
output PDataSelect,
output SysDataOE,
output PDataOE,
output SysStrobe,
output SysRW,
output reg [1:0] LoadSelect
);


wire WaitStateCTRLoad;
wire [1:0] WaitStateCTRInput = 2'd2;
wire WaitStateCTRCarry;
reg [3:0] state, next_state;
reg [9:0] OutputVector;
reg Valid;

WaitStateCTR WaitStateCTR(
.clk(clk),
.Load (WaitStateCTRLoad),
.LoadValue (WaitStateCTRInput),
.Carry (WaitStateCTRCarry),
.clk_main (clk_main)
);


always@(posedge clk) begin
	state <= rst? `STATE_IDLE : next_state;
end

always@(*) begin
	if(PRW[1]) begin		 //CHANGE
		LoadSelect = 2'd2;
		Valid = Valid_1 & Valid_2 & Valid_3 & Valid_4;
	end
	else begin
		case(FUNC3)
			`LOAD_BYTE: begin
				LoadSelect = 2'd0;
				Valid = Valid_1;
			end
			`LOAD_HALFWORD: begin
				LoadSelect = 2'd1;
				Valid = Valid_1 & Valid_2;
			end
			`LOAD_WORD: begin
				LoadSelect = 2'd2;
				Valid = Valid_1 & Valid_2 & Valid_3 & Valid_4;
			end
			`LOAD_UBYTE: begin
				LoadSelect = 2'd0;
				Valid = Valid_1;
			end
			`LOAD_UHALFWORD: begin
				LoadSelect = 2'd1;
				Valid = Valid_1 & Valid_2;
			end
			default: begin
				LoadSelect = 2'd0;
				Valid = Valid_1;
			end
		endcase
	end
end
////////////////////////////////////////////////////////////////////////////////
always@(*) begin
	case(state)
		`STATE_IDLE: begin
			if(PStrobe && (PRW[0] == `READ))	 //CHANGE
				next_state = `STATE_READ;
			else if (PStrobe && (PRW[0] == `WRITE)) //CHANGE
				next_state = `STATE_WRITE;
			else next_state = `STATE_IDLE;
		end
		`STATE_READ: begin
			if(Match && Valid)
				next_state = `STATE_IDLE;
			else
				next_state = `STATE_READMISS;
		end		
		`STATE_READMISS: begin
			next_state = `STATE_READSYS;	
		end
		`STATE_READSYS: begin
			if(WaitStateCTRCarry)
				next_state = `STATE_READDATA;
			else 
				next_state = `STATE_READSYS;
		end
		`STATE_READDATA: begin
			next_state = `STATE_IDLE;
		end
		`STATE_WRITE: begin
			if(Match && Valid) 
				next_state = `STATE_WRITEHIT;
			else 
				next_state = `STATE_WRITEMISS;
		end
		`STATE_WRITEHIT: begin
			next_state = `STATE_WRITESYS;
		end
		`STATE_WRITEMISS: begin
			next_state = `STATE_WRITESYS;
		end
		`STATE_WRITESYS: begin
			if(WaitStateCTRCarry)
				next_state = `STATE_WRITEDATA;
			else 
				next_state = `STATE_WRITESYS;
		end
		`STATE_WRITEDATA: begin
			next_state = `STATE_IDLE;
		end
		default: next_state = `STATE_IDLE;
	endcase
end

assign {WaitStateCTRLoad, PReadyEnable, Ready, Write,	SysStrobe, SysRW, CacheDataSelect, PDataSelect, 	PDataOE, SysDataOE} = OutputVector;
assign PReady = (PReadyEnable && Match && Valid) || Ready;
always@(state) begin
	case(state)
		`STATE_IDLE: OutputVector = 10'b0000_0000_00;		//ok
		`STATE_READ: OutputVector = 10'b0100_0000_10;		//ok
		`STATE_READMISS: OutputVector = 10'b1000_1100_10;	//ok
		`STATE_READSYS: OutputVector = 10'b0000_1100_10;	//ok
		`STATE_READDATA: OutputVector = 10'b0011_1111_10;	//ok
		`STATE_WRITE: OutputVector = 10'b0000_0000_00;		//ok
		`STATE_WRITEHIT: OutputVector = 10'b1001_1010_00;	//ok
		`STATE_WRITEMISS: OutputVector = 10'b1000_1000_01;	//ok
		`STATE_WRITESYS: OutputVector = 10'b0000_0000_01;	//ok
		`STATE_WRITEDATA: OutputVector = 10'b0010_0000_01;	//ok
		default: OutputVector = 10'b0000_0000_00;
	endcase
end



endmodule
