module Imm_Ext (
	input [31:0] inst,
	output reg [31:0] imm_ext_out
);

always@(*)begin
	case(inst[6:2])
	5'b01100:  //R type
	begin
		imm_ext_out=32'b0;  //R type:不會用到imm，dont care
	end
	5'b01000:  //S type
	begin
		imm_ext_out={{20{inst[31]}},inst[31:25],inst[11:7]};  //S type
	end	
	5'b11000:  //B type
	begin
		imm_ext_out={{20{inst[31]}},inst[7],inst[30:25],inst[11:8],1'b0};  //B type
	end	
	5'b11011:  //J type
	begin
		imm_ext_out={{12{inst[31]}},inst[19:12],inst[20],inst[30:21],1'b0};  //J type
	end	
	5'b00000:  //I type
	begin
		imm_ext_out={{20{inst[31]}},inst[31:20]};  //I type
	end	
	5'b11001:  //I type
	begin
		imm_ext_out={{20{inst[31]}},inst[31:20]};  //I type
	end	
	5'b00100:  //I type
	begin
		imm_ext_out={{20{inst[31]}},inst[31:20]};  //I type
	end	
	5'b01101:  //U type
	begin
		imm_ext_out={inst[31:12],12'b0};  //U type
	end	
	5'b00101:  //U type
	begin
		imm_ext_out={inst[31:12],12'b0};  //U type
	end
	5'b00001:  //FLW
	begin
		imm_ext_out={{20{inst[31]}}, inst[31:20]};  //FLW
	end
	5'b01001:  //FSW
	begin
		imm_ext_out={{20{inst[31]}}, inst[31:25], inst[11:7]};  //FSW
	end
	5'b10100:  //FARITH
	begin
		imm_ext_out=32'd0;  //FARITH
	end
	default:  //default
	begin
		imm_ext_out=32'b0;
	end
	
	endcase
end

endmodule
