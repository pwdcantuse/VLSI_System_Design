module DataMUX(
input S,
input [31:0] A, B,
output [31:0] Z

);

assign Z = S ? A : B;

endmodule
