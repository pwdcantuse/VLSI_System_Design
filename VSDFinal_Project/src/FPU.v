`timescale 1ns/100ps
`define EXP_1 operand1 [30:23]
`define EXP_2 operand2 [30:23]
`define MAN_1 operand1 [22:0]
`define MAN_2 operand2 [22:0]
`define ABS_1 operand1 [30:0]
`define ABS_2 operand2 [30:0]
`define ADD 5'b00000
`define SUB 5'b00001
`define MUL 5'b00010
`define FCVTW2S 5'b11000
`define FCVTS2W 5'b11010
`define FMVW2X 5'b11110
`define FMVX2W 5'b11100
module FPU(
   input [4:0] func5,
   input func1,
   input [31:0] operand1,
   input [31:0] operand2,
   output reg [31:0] out
);
   reg [7:0] exp_shift;
   reg [36:0] add_man1, add_man2, temp_result_add, shift_1, shift_2;
   reg lar , true_sign; // 0===> 1 is larger, sign bit is stick to 1 , 1　===> 2 is larger, sign bit is stick to 1
   ////////////////////// MUL var ///////////////////////////
   reg [23:0] mul_man1, mul_man2;
   reg [8:0] exp_mul_res;
   reg [47:0] temp_result_mul;
   ///////////////////// universe var  //////////////////////
   reg overflow, mul_sign;
/////////////////////////// ADD or SUB ///////////////////////
   wire sign_add;
   always@(*) begin
      if(`ABS_1 > `ABS_2) begin
         exp_shift = `EXP_1-`EXP_2;
         lar= 1'b0;
      end
      else begin
         exp_shift = `EXP_2-`EXP_1;
         lar= 1'b1;
      end
   end
   always@(*) begin
      true_sign=func5[0]^operand1[31]^operand2[31];
      add_man1={2'd1,`MAN_1,{12'd0}};
      add_man2={2'd1,`MAN_2,{12'd0}};
   end
//////1000倍會導致精度太差
   always@(*) begin
            if(~lar) begin
               shift_2=add_man2>>exp_shift;
               shift_1=add_man1;
            end
            else begin
               shift_1=add_man1>>exp_shift;
               shift_2=add_man2;
            end
      if(true_sign) begin
         if(shift_1>shift_2) temp_result_add=shift_1-shift_2;
         else temp_result_add=shift_2-shift_1;
      end
         else temp_result_add=shift_1+shift_2;
   end
   assign sign_add=(~true_sign)? operand1[31]: (shift_1<shift_2)?(operand2[31]^func5[0]):operand1[31];
//////////////////////////////////////  MUL  ////////////////////////////////  
   always@(*) begin
      exp_mul_res={{1'b0,`EXP_1}+{1'b0,`EXP_2}-9'd127};
      mul_sign=operand1[31]^operand2[31];
      mul_man1={1'b1,`MAN_1};
      mul_man2={1'b1,`MAN_2};
   end
   always@(*) begin
      temp_result_mul=mul_man1*mul_man2;
   end
///////////////////////////////////   normalize ////////////////////////////
   wire [22:0] man_result_add;
   wire [36:0] temp_result_add_s;
   reg [8:0]  exp_result_add ;
   wire [8:0]  normal_add;
   wire [5:0]  normal_add_shift;
   assign normal_add =   (temp_result_add[36]&&(~true_sign)) ? 9'b111111111  : temp_result_add[35] ? 9'd0  :
                     temp_result_add[34] ? 9'd1  : temp_result_add[33] ? 9'd2  :
                     temp_result_add[32] ? 9'd3  : temp_result_add[31] ? 9'd4  :
                     temp_result_add[30] ? 9'd5  : temp_result_add[29] ? 9'd6  :
                     temp_result_add[28] ? 9'd7  : temp_result_add[27] ? 9'd8  :
                     temp_result_add[26] ? 9'd9 : temp_result_add[25] ? 9'd10 :
                     temp_result_add[24] ? 9'd11 : temp_result_add[23] ? 9'd12 :
                     temp_result_add[22] ? 9'd13 : temp_result_add[21] ? 9'd14 :
                     temp_result_add[20] ? 9'd15 : temp_result_add[19] ? 9'd16 :
                     temp_result_add[18] ? 9'd17 : temp_result_add[17] ? 9'd18 :
                     temp_result_add[16] ? 9'd19 : temp_result_add[15] ? 9'd20 :
                     temp_result_add[14] ? 9'd21 : temp_result_add[13] ? 9'd22 :
                     temp_result_add[12] ? 9'd23 : temp_result_add[11] ? 9'd24 :
                     temp_result_add[10] ? 9'd25 : temp_result_add[9]  ? 9'd26 :
                     temp_result_add[8]  ? 9'd27 : temp_result_add[7]  ? 9'd28 :
                     temp_result_add[6]  ? 9'd29 : temp_result_add[5]  ? 9'd30 :
                     temp_result_add[4]  ? 9'd31 : temp_result_add[3]  ? 9'd32 :
                     temp_result_add[2]  ? 9'd33 : temp_result_add[1]  ? 9'd34 :
                     temp_result_add[0]  ? 9'd35 : 9'd36;
   assign normal_add_shift =   (temp_result_add[36]&&(~true_sign)) ? 6'd0: temp_result_add[35] ? 6'd1  :
                     temp_result_add[34] ? 5'd2  : temp_result_add[33] ? 6'd3  :
                     temp_result_add[32] ? 6'd4  : temp_result_add[31] ? 6'd5  :
                     temp_result_add[30] ? 6'd6  : temp_result_add[29] ? 6'd7  :
                     temp_result_add[28] ? 6'd8  : temp_result_add[27] ? 6'd9  :
                     temp_result_add[26] ? 6'd10 : temp_result_add[25] ? 6'd11 :
                     temp_result_add[24] ? 6'd12 : temp_result_add[23] ? 6'd13 :
                     temp_result_add[22] ? 6'd14 : temp_result_add[21] ? 6'd15 :
                     temp_result_add[20] ? 6'd16 : temp_result_add[19] ? 6'd17 :
                     temp_result_add[18] ? 6'd18 : temp_result_add[17] ? 6'd19 :
                     temp_result_add[16] ? 6'd20 : temp_result_add[15] ? 6'd21 :
                     temp_result_add[14] ? 6'd22 : temp_result_add[13] ? 6'd23 :
                     temp_result_add[12] ? 6'd24 : temp_result_add[11] ? 6'd25 :
                     temp_result_add[10] ? 6'd26 : temp_result_add[9]  ? 6'd27 :
                     temp_result_add[8]  ? 6'd28 : temp_result_add[7]  ? 6'd29 :
                     temp_result_add[6]  ? 6'd30 : temp_result_add[5]  ? 6'd31 :
                     temp_result_add[4]  ? 6'd32 : temp_result_add[3]  ? 6'd33 :
                     temp_result_add[2]  ? 6'd34 : temp_result_add[1]  ? 6'd35 :
                     temp_result_add[0]  ? 6'd36 : 6'd37;
   assign temp_result_add_s= temp_result_add << normal_add_shift;
   assign man_result_add = temp_result_add_s[35:13];

   always@(*) begin
      if(~lar && normal_add!=9'd36) begin
            exp_result_add={1'b0,`EXP_1}-normal_add;
         end
      else if(lar && normal_add!=9'd36)begin
            exp_result_add={1'b0,`EXP_2}-normal_add;
      end
      else begin
            exp_result_add=9'd0;
      end
   end
//////////////////////////////////MUL normal /////////////////////////////
   wire [22:0] man_result_mul;
   wire [7:0]  exp_result_mul;
   
   assign exp_result_mul=(temp_result_mul[47])? exp_mul_res+8'd1 : exp_mul_res;
   assign man_result_mul= (temp_result_mul[47])? temp_result_mul[46:24]: temp_result_mul[45:23];
   
///////////////////////////////   FCVT .S.W or WU  ////////////////////////////////
   reg [7:0] shift_CVT, temp_operand_1, temp_operand_2;
   reg rl; // right 0, left 1
   reg [31:0] FCVTSW_result;
   reg [54:0] man_after_shift;
   wire FCVT_S_overflow;

   always@(*) begin
         if(`EXP_1<8'd127) begin 
            temp_operand_2=`EXP_1;
            temp_operand_1=8'd127;
            rl=1'b1;
         end
         else begin
            temp_operand_1=`EXP_1;
            temp_operand_2=8'd127;
            rl=1'b0;
         end
         shift_CVT=temp_operand_1-temp_operand_2;
   end
   always@(*) begin
      man_after_shift={32'd1,`MAN_1} << shift_CVT;
   end
   always@(*) begin
      if(rl) begin
         FCVTSW_result=32'd0;
      end
      else if(~func1) begin
         FCVTSW_result= ({32{operand1[31]}}^man_after_shift[54:23])+operand1[31];
      end
      else begin
         FCVTSW_result=man_after_shift[54:23];
      end
   end
   assign FCVT_S_overflow=(`EXP_1>8'd158)?1'b1: 1'b0 ;
///////////////////////////////   FCVT .S.W or S.WU  ////////////////////////////////
   wire [5:0] normal_CVT;
   wire [31:0] temp_normal_result,operand1_abs;
   wire [22:0] man_FCVT;
   wire [7:0] exp_FCVT;
   wire sign_FCVT;
   assign operand1_abs = (func1)? operand1: (({32{operand1[31]}}^operand1)+operand1[31]); 
   assign normal_CVT =   operand1_abs[31] ? 6'd31  : operand1_abs[30] ? 6'd30  :
                     operand1_abs[29] ? 6'd29  : operand1_abs[28] ? 6'd28  :
                     operand1_abs[27] ? 6'd27  : operand1_abs[26] ? 6'd26  :
                     operand1_abs[25] ? 6'd25  : operand1_abs[24] ? 6'd24  :
                     operand1_abs[23] ? 6'd23  : operand1_abs[22] ? 6'd22  :
                     operand1_abs[21] ? 6'd21 : operand1_abs[20] ? 6'd20 :
                     operand1_abs[19] ? 6'd19 : operand1_abs[18] ? 6'd18 :
                     operand1_abs[17] ? 6'd17 : operand1_abs[16] ? 6'd16 :
                     operand1_abs[15] ? 6'd15 : operand1_abs[14] ? 6'd14 :
                     operand1_abs[13] ? 6'd13 : operand1_abs[12] ? 6'd12 :
                     operand1_abs[11] ? 6'd11 : operand1_abs[10] ? 6'd10 :
                     operand1_abs[9]  ? 6'd9 : operand1_abs[8]  ? 6'd8 : 
                     operand1_abs[7]  ? 6'd7 : operand1_abs[6]  ? 6'd6 : 
                     operand1_abs[5]  ? 6'd5 : operand1_abs[4]  ? 6'd4 : 
                     operand1_abs[3]  ? 6'd3 : operand1_abs[2]  ? 6'd2 : 
                     operand1_abs[1]  ? 6'd1 : operand1_abs[0]  ? 6'd0 : 6'd40;
   assign temp_normal_result = (normal_CVT== 6'd40) ? 31'd0 : operand1_abs<<(6'd32-normal_CVT);
   assign sign_FCVT = (func1)? 1'b0 : operand1[31];
   assign man_FCVT = temp_normal_result[31:9];
   assign exp_FCVT = 8'd127+normal_CVT;
/////////////////////////////////////////////  choose result ///////////////////////////////
   always@(*) begin
      case(func5) 
         `ADD: begin
            overflow=exp_result_add[8];
            out=(overflow)? 32'hffffffff: {sign_add,exp_result_add[7:0],man_result_add};
         end
         `SUB: begin
            overflow=exp_result_add[8];
            out=(overflow)? 32'hffffffff: {sign_add,exp_result_add[7:0],man_result_add};
         end
         `MUL: begin
            overflow=exp_mul_res[8];
            out=(overflow)? 32'hffffffff: {mul_sign,exp_result_mul,man_result_mul};
         end
         `FCVTS2W: begin
			overflow=1'b0;
            out={sign_FCVT,exp_FCVT,man_FCVT};
         end
         `FCVTW2S: begin
			overflow=1'b0;
            out=(FCVT_S_overflow)? 32'hffffffff:FCVTSW_result;
         end
         `FMVW2X: begin
			overflow=1'b0;
            out=operand1;
         end
         `FMVX2W: begin
			overflow=1'b0;
            out=operand1;
         end
         default: begin
			overflow=1'b0;
            out=32'd0;
         end
      endcase
   end

endmodule
