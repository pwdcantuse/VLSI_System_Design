module Mux_3to1(
input [1:0]Mux_sel,
input [31:0]Mux_in1,
input [31:0]Mux_in2,
input [31:0]Mux_in3,
output reg[31:0]Mux_out
);

always@(*)begin
	if(Mux_sel==2'd0) begin     //Mux_sel==0:選Mux_in1
		Mux_out=Mux_in1;
	end
	else if(Mux_sel==2'd1) begin            //Mux_sel==1:選Mux_in2
		Mux_out=Mux_in2;
	end
	else if(Mux_sel==2'd2) begin            //Mux_sel==2:選Mux_in3
		Mux_out=Mux_in3;
	end
	else begin
		Mux_out=32'b0;
	end
end

endmodule
