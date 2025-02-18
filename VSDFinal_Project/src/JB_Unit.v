module JB_Unit (
input [31:0] operand1,
input [31:0] operand2,
input [31:0] pc,
input predict,
input [4:0]opcode,
output reg [31:0] jb_out
);

always @(*) begin
    if (opcode==5'b11000) begin
        if (predict) begin
            jb_out=pc+32'd4; 
        end
        else  jb_out=(operand1+operand2)&(~32'b1);     
    end
    else jb_out=(operand1+operand2)&(~32'b1);
end


endmodule
