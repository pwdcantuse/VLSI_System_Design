module Predictor(
input clk,
input rst,
input [31:0] pc,
input [31:0] inst,
input btype,
input taken, //(=1 taken) (=0 not taken)
output reg [31:0] pc_add_4,//pc+4
output reg predict //(=1 taken) (=0 not taken)
); 
parameter ST = 2'b00;
parameter WT = 2'b01;
parameter SNT = 2'b10;
parameter WNT = 2'b11;
reg [1:0]current_state; 
reg [1:0]next_state;
reg [31:0]temp;
always @(posedge clk or posedge rst) begin
    if (rst) begin
        current_state<=WNT;
    end
    else current_state<=next_state;
end
always @(*) begin
    case (current_state) 
    ST:temp=pc+{{20{inst[31]}},inst[7],inst[30:25],inst[11:8],1'b0};
    WT:temp=pc+{{20{inst[31]}},inst[7],inst[30:25],inst[11:8],1'b0};
    SNT:temp=pc+32'd4;
    WNT:temp=pc+32'd4;
    endcase
end
always @(*) begin
    if(inst[6:2]==5'b11000)begin
        pc_add_4=temp;
    end
    else pc_add_4=pc+32'd4;
end
always @(*) begin
    case (current_state) 
    ST:
        begin
            predict=1'b1;
            if (btype) begin
                if (taken) begin
                    next_state=ST;
                end
                else
                    next_state=WT;    
            end
            else next_state=ST;
        end
    WT:
        begin
            predict=1'b1;
             if (btype) begin
                if (taken) begin
                    next_state=ST;
                end
                else
                next_state=WNT;
             end
             else next_state=WT;
        end
    SNT:
        begin
            predict=1'b0;
            if (btype) begin
                if (taken) begin
                    next_state=WNT;
                end
                 else
                    next_state=SNT;
            end
            else next_state=SNT;
        end
    WNT:
        begin
            predict=1'b0;
            if (btype) begin
                if (taken) begin
                    next_state=WT;
                end
                else
                    next_state=SNT;
            end
            else next_state=WNT;
        end
    endcase
end
endmodule
