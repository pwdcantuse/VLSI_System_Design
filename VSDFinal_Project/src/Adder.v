module Adder(
input [31:0] pc,
output [32:0] pc_add_4//pc+4
);

assign pc_add_4={1'b0,pc}+33'd4;

endmodule
