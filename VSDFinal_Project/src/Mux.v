module Mux(
input Mux_sel,
input [31:0]Mux_in1,
input [31:0]Mux_in2,
output reg[31:0]Mux_out
);

always@(*)begin
	if(Mux_sel) begin     //Mux_sel==1:選Mux_in1
		Mux_out=Mux_in1;
	end
	else begin            //Mux_sel==0:選Mux_in2
		Mux_out=Mux_in2;
	end
end

endmodule