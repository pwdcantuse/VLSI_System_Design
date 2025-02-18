module Multiplier(A, B, Result);
	// n period 7.4, 1ns stable. area 104864.760809. power 11.3499 mW.

	input [31:0] A, B; //A is Mcand, B is Mplier
	output [32:0] Result;
	
	wire [31:0] w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15,w16,w17,w18,w19,w20,w21,w22,w23,w24,w25,w26,w27,w28,w29,w30,w31;
	wire [31:0] l0,l1,l2,l3,l4,l5,l6,l7,l8,l9,l10,l11,l12,l13,l14,l15,l16,l17,l18,l19,l20,l21,l22,l23,l24,l25,l26,l27,l28,l29,l30;
	wire [32:0] r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15,r16,r17,r18,r19,r20,r21,r22,r23,r24,r25,r26,r27,r28,r29;
	
	assign w0 = A & {32{B[0]}};
	assign w1 = A & {32{B[1]}};
	assign w2 = A & {32{B[2]}};
	assign w3 = A & {32{B[3]}};
	assign w4 = A & {32{B[4]}};
	assign w5 = A & {32{B[5]}};
	assign w6 = A & {32{B[6]}};
	assign w7 = A & {32{B[7]}};
	assign w8 = A & {32{B[8]}};
	assign w9 = A & {32{B[9]}};
	assign w10 = A & {32{B[10]}};
	assign w11 = A & {32{B[11]}};
	assign w12 = A & {32{B[12]}};
	assign w13 = A & {32{B[13]}};
	assign w14 = A & {32{B[14]}};
	assign w15 = A & {32{B[15]}};
	assign w16 = A & {32{B[16]}};
	assign w17 = A & {32{B[17]}};
	assign w18 = A & {32{B[18]}};
	assign w19 = A & {32{B[19]}};
	assign w20 = A & {32{B[20]}};
	assign w21 = A & {32{B[21]}};
	assign w22 = A & {32{B[22]}};
	assign w23 = A & {32{B[23]}};
	assign w24 = A & {32{B[24]}};
	assign w25 = A & {32{B[25]}};
	assign w26 = A & {32{B[26]}};
	assign w27 = A & {32{B[27]}};
	assign w28 = A & {32{B[28]}};
	assign w29 = A & {32{B[29]}};
	assign w30 = A & {32{B[30]}};
	assign w31 = A & {32{B[31]}};
	assign l0 = {w1[30:0],1'b0};
	assign l1 = {w2[29:0],2'b0};
	assign l2 = {w3[28:0],3'b0};
	assign l3 = {w4[27:0],4'b0};
	assign l4 = {w5[26:0],5'b0};
	assign l5 = {w6[25:0],6'b0};
	assign l6 = {w7[24:0],7'b0};
	assign l7 = {w8[23:0],8'b0};
	assign l8 = {w9[22:0],9'b0};
	assign l9 = {w10[21:0],10'b0};
	assign l10 = {w11[20:0],11'b0};
	assign l11 = {w12[19:0],12'b0};
	assign l12 = {w13[18:0],13'b0};
	assign l13 = {w14[17:0],14'b0};
	assign l14 = {w15[16:0],15'b0};
	assign l15 = {w16[15:0],16'b0};
	assign l16 = {w17[14:0],17'b0};
	assign l17 = {w18[13:0],18'b0};
	assign l18 = {w19[12:0],19'b0};
	assign l19 = {w20[11:0],20'b0};
	assign l20 = {w21[10:0],21'b0};
	assign l21 = {w22[9:0],22'b0};
	assign l22 = {w23[8:0],23'b0};
	assign l23 = {w24[7:0],24'b0};
	assign l24 = {w25[6:0],25'b0};
	assign l25 = {w26[5:0],26'b0};
	assign l26 = {w27[4:0],27'b0};
	assign l27 = {w28[3:0],28'b0};
	assign l28 = {w29[2:0],29'b0};
	assign l29 = {w30[1:0],30'b0};
	assign l30 = {w31[0],31'b0};

	assign r0 = {1'b0,w0} + {1'b0,l0} ;
	assign r1 = {1'b0,l1} + {1'b0,l2} ;
	assign r2 = {1'b0,l3} + {1'b0,l4} ;
	assign r3 = {1'b0,l5} + {1'b0,l6} ;
	assign r4 = {1'b0,l7} + {1'b0,l8} ;
	assign r5 = {1'b0,l9} + {1'b0,l10} ;
	assign r6 = {1'b0,l11} + {1'b0,l12} ;
	assign r7 = {1'b0,l13} + {1'b0,l14} ;
	assign r8 = {1'b0,l15} + {1'b0,l16} ;
	assign r9 = {1'b0,l17} + {1'b0,l18} ;
	assign r10 = {1'b0,l19} + {1'b0,l20} ;
	assign r11 = {1'b0,l21} + {1'b0,l22} ;
	assign r12 = {1'b0,l23} + {1'b0,l24} ;
	assign r13 = {1'b0,l25} + {1'b0,l26} ;
	assign r14 = {1'b0,l27} + {1'b0,l28} ;
	assign r15 = {1'b0,l29} + {1'b0,l30} ;
	
	assign r16 = {1'b0,r0[31:0]} + {1'b0,r1[31:0]} ;
	assign r17 = {1'b0,r2[31:0]} + {1'b0,r3[31:0]} ;
	assign r18 = {1'b0,r4[31:0]} + {1'b0,r5[31:0]} ;
	assign r19 = {1'b0,r6[31:0]} + {1'b0,r7[31:0]} ;
	assign r20 = {1'b0,r8[31:0]} + {1'b0,r9[31:0]} ;
	assign r21 = {1'b0,r10[31:0]} + {1'b0,r11[31:0]} ;
	assign r22 = {1'b0,r12[31:0]} + {1'b0,r13[31:0]} ;
	assign r23 = {1'b0,r14[31:0]} + {1'b0,r15[31:0]} ;

	assign r24 = {1'b0,r16[31:0]} + {1'b0,r17[31:0]} ;
	assign r25 = {1'b0,r18[31:0]} + {1'b0,r19[31:0]} ;
	assign r26 = {1'b0,r20[31:0]} + {1'b0,r21[31:0]} ;
	assign r27 = {1'b0,r22[31:0]} + {1'b0,r23[31:0]} ;

	assign r28 = {1'b0,r24[31:0]} + {1'b0,r25[31:0]} ;
	assign r29 = {1'b0,r26[31:0]} + {1'b0,r27[31:0]} ;
	
	assign 	Result = {1'b0,r28[31:0]} + {1'b0,r29[31:0]};
	

endmodule
