`define BYTE 2'd0
`define HALFWORD 2'd1
`define WORD 2'd2

module Comparator(
input [1:0] LoadSelect,
input [5:0] TagP,
input [5:0] Tag1_C,
input [5:0] Tag2_C,
input [5:0] Tag3_C,
input [5:0] Tag4_C,
output reg Match

);

always@(*) begin
	case(LoadSelect)
		`BYTE: Match = (Tag1_C == TagP) ? 1'd1 : 1'd0;
		`HALFWORD: Match = ((Tag1_C == TagP) && (Tag2_C == TagP)) ? 1'd1 : 1'd0;
		`WORD: Match = ((Tag1_C == TagP) && (Tag2_C == TagP) && (Tag3_C == TagP) && (Tag4_C == TagP)) ? 1'd1 : 1'd0;
	endcase
end

endmodule
