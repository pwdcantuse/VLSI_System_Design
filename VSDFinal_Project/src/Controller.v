module Controller(
	input clk,
	input rst,
	input predict,//predictor
	input [4:0]opcode,
	input [2:0]func3,
	input [4:0] func5,
	input [6:0] func7,
	input [4:0] rd_index,
	input [4:0] rs1_index,
	input [4:0] rs2_index,
	input alu_out_last_bit,     //用來判斷branch jump or not
	output reg btype,
//pipeline 新增	
	output reg stall,
	output reg D_rs1_data_sel,
	output reg D_rs2_data_sel,
	output D_rs1_fp_sel,
	output D_rs2_fp_sel,
	output reg [1:0]E_rs1_data_sel,
	output reg [1:0]E_rs2_data_sel,
//原本就有的
	output reg [3:0]F_im_w_en,         //永遠都是0
	output reg next_pc_sel,            //無條件跳轉和branch成功:1   其他和branch失敗:0
	output reg [4:0]E_opcode_out,
	output reg E_func1_out,
	output reg [2:0]E_func3_out,
	output reg [4:0] E_func5_out,
	output reg [6:0] E_func7_out,
 	output reg E_alu_op1_sel,          //Reg-Reg、Reg-imm、load、store、branch是1，其他都是0(lui:dont care)
	output reg E_alu_op2_sel,          //Reg-Reg、branch是1，其他都是0(jal、jalr:dont care)
	output reg E_alu_fp_sel,      
	output reg E_jb_op1_sel,           //jalr是1，其他都是0(Reg-Reg、Reg-imm、lui、auipc、load、store:dont care)
	output reg [3:0]M_dm_w_en,         //store以外都是0
	output reg [2:0] M_f3,
	output reg W_wb_en,                //branch、store是0，其他都是1
	output reg W_fwb_en,
	output reg [2:0] W_func3_out,
	output reg [4:0] W_rd_index,
	output reg W_wb_data_sel,         //load以外都是0
//-----Cache Extension-----------
	output reg PStrobe,
	input PReady,
	output cacheStall
);
//---------------------------------------------------------
	//for reg_E
	reg [4:0] E_op;	
	reg [2:0] E_f3;
	reg [4:0] E_rd;
	reg [4:0] E_rs1;
	reg [4:0] E_rs2;
	reg [6:0] E_f7;
	//for reg_M
	reg [4:0] M_op;	
	//reg [2:0] M_f3;
	reg [4:0] M_rd;
	//for reg_W
	reg [4:0] W_op;	
	reg [2:0] W_f3;
	reg [4:0] W_rd;
//----------Floating Point-------------------------------
	reg [4:0] E_f5;//, M_f5, W_f5;
	reg E_rd_fp, E_rs1_fp, E_rs2_fp,
		M_rd_fp, M_rs1_fp, M_rs2_fp,
		W_rd_fp, W_rs1_fp, W_rs2_fp;
	wire D_rd_fp,
		is_D_use_rd, is_D_use_rs1, is_D_use_rs2;
	reg is_E_use_rd, is_E_use_rs1, is_E_use_rs2,
		is_M_use_rd, is_M_use_rs1, is_M_use_rs2,
		is_W_use_rd, is_W_use_rs1, is_W_use_rs2;
//---------------------------------------------------------
	//判斷D_rs1_data_sel、D_rs2_data_sel
	//reg is_W_use_rd; watch out!!
	reg is_D_rs1_W_rd_overlap;
	reg is_D_rs2_W_rd_overlap;	
	//判斷E_rs1_data_sel、E_rs2_data_sel
	//reg is_M_use_rd;
	//reg is_E_use_rs1;
	//reg is_E_use_rs2;
	reg is_E_rs1_W_rd_overlap;
	reg is_E_rs1_M_rd_overlap;
	reg is_E_rs2_W_rd_overlap;
	reg is_E_rs2_M_rd_overlap;
	//判斷stall
	//reg is_D_use_rs1;
	//reg is_D_use_rs2;
	reg is_D_rs1_E_rd_overlap;
	reg is_D_rs2_E_rd_overlap;
	reg is_DE_overlap;

//-----Cache Extension-----------
	reg cs;
	assign cacheStall = (PStrobe && (PReady == 0)) ? 1'd1 : 1'd0;
//=========================================================================pass decoded inst=================================================================	
	always@(posedge clk or posedge rst)begin
		if(rst)begin                         //nop
			E_op  <= 5'b00100;						
			E_f3  <= 3'b0;
			E_f7  <= 7'b0;
			E_rs1 <= 5'b0;
			E_rs2 <= 5'b0;
			E_rd  <= 5'b0;
			M_op  <= 5'b00100;
			M_f3  <= 3'b0;
			M_rd  <= 5'b0;
			W_op  <= 5'b00100;
			W_f3  <= 3'b0;
			W_rd  <= 5'b0;
			E_f5     <= 5'b0;
			E_rd_fp  <= 1'b0;
			E_rs1_fp <= 1'b0;
			E_rs2_fp <= 1'b0;
			M_rd_fp  <= 1'b0;
			M_rs1_fp <= 1'b0;
			M_rs2_fp <= 1'b0;
			W_rd_fp  <= 1'b0;
			W_rs1_fp <= 1'b0;
			W_rs2_fp <= 1'b0;
			is_E_use_rd  <= 1'b0;
			is_E_use_rs1 <= 1'b0;
			is_E_use_rs2 <= 1'b0;
			is_M_use_rd  <= 1'b0;
			is_M_use_rs1 <= 1'b0;
			is_M_use_rs2 <= 1'b0;
			is_W_use_rd  <= 1'b0;
			is_W_use_rs1 <= 1'b0;
			is_W_use_rs2 <= 1'b0;
		end
		else if (cacheStall) begin
			E_op  <= E_op ;						
			E_f3  <= E_f3;
			E_f7  <= E_f7;
			E_rs1 <= E_rs1;
			E_rs2 <= E_rs2;
			E_rd  <= E_rd;
			M_op  <= M_op;								
			M_f3  <= M_f3;
			M_rd  <= M_rd;
			W_op  <= W_op;								
			W_f3  <= W_f3;
			W_rd  <= W_rd;
			E_f5     <= E_f5;
			E_rd_fp  <= E_rd_fp;
			E_rs1_fp <= E_rs1_fp;
			E_rs2_fp <= E_rs2_fp;
			M_rd_fp  <= M_rd_fp;
			M_rs1_fp <= M_rs1_fp;
			M_rs2_fp <= M_rs2_fp;
			W_rd_fp  <= W_rd_fp;
			W_rs1_fp <= W_rs1_fp;
			W_rs2_fp <= W_rs2_fp;
			is_E_use_rd  <= is_E_use_rd;
			is_E_use_rs1 <= is_E_use_rs1;
			is_E_use_rs2 <= is_E_use_rs2;
			is_M_use_rd  <= is_M_use_rd;
			is_M_use_rs1 <= is_M_use_rs1;
			is_M_use_rs2 <= is_M_use_rs2;
			is_W_use_rd  <= is_W_use_rd;
			is_W_use_rs1 <= is_W_use_rs1;
			is_W_use_rs2 <= is_W_use_rs2;
		end
		else if(stall||next_pc_sel)begin	  //stall or jb :給E nop
			E_op  <= 5'b00100;						
			E_f3  <= 3'b0;
			E_f7  <= 7'b0;
			E_rs1 <= 5'b0;
			E_rs2 <= 5'b0;
			E_rd  <= 5'b0;
			M_op  <= E_op;								
			M_f3  <= E_f3;
			M_rd  <= E_rd;
			W_op  <= M_op;								
			W_f3  <= M_f3;
			W_rd  <= M_rd;
			E_f5     <= 5'b0;
			E_rd_fp  <= 1'b0;
			E_rs1_fp <= 1'b0;
			E_rs2_fp <= 1'b0;
			M_rd_fp  <= E_rd_fp;
			M_rs1_fp <= E_rs1_fp;
			M_rs2_fp <= E_rs2_fp;
			W_rd_fp  <= M_rd_fp;
			W_rs1_fp <= M_rs1_fp;
			W_rs2_fp <= M_rs2_fp;
			is_E_use_rd  <= 1'b0;
			is_E_use_rs1 <= 1'b0;
			is_E_use_rs2 <= 1'b0;
			is_M_use_rd  <= is_E_use_rd;
			is_M_use_rs1 <= is_E_use_rs1;
			is_M_use_rs2 <= is_E_use_rs2;
			is_W_use_rd  <= is_M_use_rd;
			is_W_use_rs1 <= is_M_use_rs1;
			is_W_use_rs2 <= is_M_use_rs2;
		end
		else begin
			E_op  <= opcode;			
			E_f3  <= func3;
			E_f7  <= func7;
			E_rs1 <= rs1_index;
			E_rs2 <= rs2_index;
			E_rd  <= rd_index;
			M_op  <= E_op;				
			M_f3  <= E_f3;
			M_rd  <= E_rd;
			W_op  <= M_op;				
			W_f3  <= M_f3;
			W_rd  <= M_rd;
			E_f5     <= func5;
			E_rd_fp  <= D_rd_fp;
			E_rs1_fp <= D_rs1_fp_sel;
			E_rs2_fp <= D_rs2_fp_sel;
			M_rd_fp  <= E_rd_fp;
			M_rs1_fp <= E_rs1_fp;
			M_rs2_fp <= E_rs2_fp;
			W_rd_fp  <= M_rd_fp;
			W_rs1_fp <= M_rs1_fp;
			W_rs2_fp <= M_rs2_fp;
			is_E_use_rd  <= is_D_use_rd;
			is_E_use_rs1 <= is_D_use_rs1;
			is_E_use_rs2 <= is_D_use_rs2;
			is_M_use_rd  <= is_E_use_rd;
			is_M_use_rs1 <= is_E_use_rs1;
			is_M_use_rs2 <= is_E_use_rs2;
			is_W_use_rd  <= is_M_use_rd;
			is_W_use_rs1 <= is_M_use_rs1;
			is_W_use_rs2 <= is_M_use_rs2;
		end
	end
//=========================================================================pipeline 新增=================================================================

	
	
//-----------------------------------------------------------------------------------------//判斷D_rs1_data_sel、D_rs2_data_sel
	always@(*)begin
		//is_W_use_rd=?
	/*	if((W_op==5'b01100)||(W_op==5'b00100)||(W_op==5'b00000)||(W_op==5'b11001)||(W_op==5'b01101)||(W_op==5'b00101)||(W_op==5'b11011))begin //R,I,U,J : is_W_use_rd = 1'b1		
			is_W_use_rd = 1'b1;
		end
		else begin
			is_W_use_rd = 1'b0;
		end*/
		//D_rs1_data_sel、D_rs2_data_sel=?
		is_D_rs1_W_rd_overlap = is_D_use_rs1 & is_W_use_rd & (rs1_index == W_rd) & (D_rs1_fp_sel == W_rd_fp) & (W_rd_fp || (W_rd != 5'b0));
		is_D_rs2_W_rd_overlap = is_D_use_rs2 & is_W_use_rd & (rs2_index == W_rd) & (D_rs2_fp_sel == W_rd_fp) & (W_rd_fp || (W_rd != 5'b0));
		D_rs1_data_sel = is_D_rs1_W_rd_overlap ? 1'd1 : 1'd0;
		D_rs2_data_sel = is_D_rs2_W_rd_overlap ? 1'd1 : 1'd0;

	end
	assign is_D_use_rd = (opcode==5'b01100)||(opcode==5'b00100)||(opcode==5'b00000)||(opcode==5'b11001)||(opcode==5'b01101)||(opcode==5'b00101)||(opcode==5'b11011)||(opcode==`FLW)||(opcode==`FARITH);
	assign is_D_use_rs1 = (opcode==5'b01100)||(opcode==5'b00100)||(opcode==5'b00000)||(opcode==5'b11001)||(opcode==5'b01000)||(opcode==5'b11000)||(opcode==`FLW)||(opcode==`FSW)||(opcode==`FARITH);
	assign is_D_use_rs2 = (opcode==5'b01100)||(opcode==5'b01000)||(opcode==5'b11000)||(opcode==`FSW)||(opcode==`FARITH && ~func5[4]);
	
	assign D_rd_fp = ((opcode == `FARITH && (~func5[4] || func5[1])) || opcode == `FLW) ? `SEL_FREG : `SEL_REG;
	assign D_rs1_fp_sel = (opcode == `FARITH && (~func5[4] || ~func5[1])) ? `SEL_FREG : `SEL_REG;
	assign D_rs2_fp_sel = ((opcode == `FARITH && ~func5[4]) || opcode == `FSW) ? `SEL_FREG : `SEL_REG;	
	
//-----------------------------------------------------------------------------------------//判斷E_rs1_data_sel、E_rs2_data_sel
	always@(*)begin
		//is_E_use_rs1、is_E_use_rs2=?
		/*case(E_op)  
		//R
		5'b01100: begin   
			is_E_use_rs1 = 1'b1;
			is_E_use_rs2 = 1'b1;	
		end			
		//I
		5'b00100: begin 
			is_E_use_rs1 = 1'b1;
			is_E_use_rs2 = 1'b0;
		end			
		//I
		5'b00000: begin 
			is_E_use_rs1 = 1'b1;
			is_E_use_rs2 = 1'b0;
		end
		//I
		5'b11001: begin 
			is_E_use_rs1 = 1'b1;
			is_E_use_rs2 = 1'b0;
		end
		//S
		5'b01000: begin 
			is_E_use_rs1 = 1'b1;
			is_E_use_rs2 = 1'b1;
		end 
		//B
		5'b11000: begin 
			is_E_use_rs1 = 1'b1;
			is_E_use_rs2 = 1'b1;
		end
		default: begin
			is_E_use_rs1 = 1'b0;
			is_E_use_rs2 = 1'b0;
		end
		endcase
		//is_M_use_rd=?
		if((M_op==5'b01100)||(M_op==5'b00100)||(M_op==5'b00000)||(M_op==5'b11001)||(M_op==5'b01101)||(M_op==5'b00101)||(M_op==5'b11011))begin	//R,I,U,J : is_M_use_rd = 1'b1	
			is_M_use_rd = 1'b1;
		end
		else begin
			is_M_use_rd = 1'b0;
		end*/
		
		
		//E_rs1_data_sel=?
		is_E_rs1_W_rd_overlap = is_E_use_rs1 & is_W_use_rd & (E_rs1 == W_rd) & (E_rs1_fp == W_rd_fp) & (W_rd_fp || (W_rd != 5'b0));
		is_E_rs1_M_rd_overlap = is_E_use_rs1 & is_M_use_rd & (E_rs1 == M_rd) & (E_rs1_fp == M_rd_fp) & (M_rd_fp || (M_rd != 5'b0));
		E_rs1_data_sel = is_E_rs1_M_rd_overlap ? 2'd1 : is_E_rs1_W_rd_overlap ? 2'd0 : 2'd2;
		//E_rs2_data_sel=?
		is_E_rs2_W_rd_overlap = is_E_use_rs2 & is_W_use_rd & (E_rs2 == W_rd) & (E_rs2_fp == W_rd_fp) & (W_rd_fp || (W_rd != 5'b0));
		is_E_rs2_M_rd_overlap = is_E_use_rs2 & is_M_use_rd & (E_rs2 == M_rd) & (E_rs2_fp == M_rd_fp) & (M_rd_fp || (M_rd != 5'b0));
		E_rs2_data_sel = is_E_rs2_M_rd_overlap ? 2'd1 : is_E_rs2_W_rd_overlap ? 2'd0 : 2'd2;	
	end
	
	
//-----------------------------------------------------------------------------------------//判斷stall	
	always@(*)begin
		//is_D_use_rs1、is_D_use_rs2=?
	    /*case(opcode)  
		//R
		5'b01100: begin   
			is_D_use_rs1 = 1'b1;
			is_D_use_rs2 = 1'b1;	
		end			
		//I
		5'b00100: begin 
			is_D_use_rs1 = 1'b1;
			is_D_use_rs2 = 1'b0;
		end			
		//I
		5'b00000: begin 
			is_D_use_rs1 = 1'b1;
			is_D_use_rs2 = 1'b0;
		end
		//I
		5'b11001: begin 
			is_D_use_rs1 = 1'b1;
			is_D_use_rs2 = 1'b0;
		end
		//S
		5'b01000: begin 
			is_D_use_rs1 = 1'b1;
			is_D_use_rs2 = 1'b1;
		end 
		//B
		5'b11000: begin 
			is_D_use_rs1 = 1'b1;
			is_D_use_rs2 = 1'b1;
		end
		default: begin
			is_D_use_rs1 = 1'b0;
			is_D_use_rs2 = 1'b0;
		end
		endcase*/
		is_D_rs1_E_rd_overlap = is_D_use_rs1 & (rs1_index == E_rd) & (D_rs1_fp_sel == E_rd_fp) & (E_rd_fp || (E_rd != 5'b0));
		is_D_rs2_E_rd_overlap = is_D_use_rs2 & (rs2_index == E_rd) & (D_rs2_fp_sel == E_rd_fp) & (E_rd_fp || (E_rd != 5'b0));
		is_DE_overlap = (is_D_rs1_E_rd_overlap | is_D_rs2_E_rd_overlap);
		stall = (E_op == 5'b00000 || E_op == `FLW) & is_DE_overlap;
	end	

	
	
//===========================================================================原本就有的===============================================================	
	always@(*)begin
	
		F_im_w_en = 4'b0;    //永遠都是0
		
//=========================================================================================		
		//E Stage
		//Control signal : E_opcode_out,E_func3_out,E_func7_out,next_pc_sel,E_alu_op1_sel,E_alu_op2_sel,E_jb_op1_sel 
		E_opcode_out = E_op;
		E_func1_out = E_rs2[0];
		E_func3_out = E_f3;
		E_func5_out = E_f5;
		E_func7_out = E_f7;
		E_alu_fp_sel = (E_op == `FARITH) ? `SEL_FPU : `SEL_ALU;
		case(E_op)
//-----------------------------------------------------------------------------------------		
		//Register - Register*
		5'b01100: begin  
			next_pc_sel   = 1'b0;
			E_alu_op1_sel = 1'b1;
			E_alu_op2_sel = 1'b1;//**
			E_jb_op1_sel  = 1'b0;//dontcare
			btype=0;
		end		
//-----------------------------------------------------------------------------------------			
		//Register - Immediate*
		5'b00100: begin 
			next_pc_sel   = 1'b0;
			E_alu_op1_sel = 1'b1;
			E_alu_op2_sel = 1'b0;
			E_jb_op1_sel  = 1'b0;//dontcare
			btype=0;
		end		
//-----------------------------------------------------------------------------------------
		//LUI*
		5'b01101: begin 
			next_pc_sel   = 1'b0;
			E_alu_op1_sel = 1'b0;//dontcare
			E_alu_op2_sel = 1'b0;
			E_jb_op1_sel  = 1'b0;//dontcare
			btype=0;
		end		
//-----------------------------------------------------------------------------------------
		//AUIPC*
		5'b00101: begin 
			next_pc_sel   = 1'b0;
			E_alu_op1_sel = 1'b0;
			E_alu_op2_sel = 1'b0;
			E_jb_op1_sel  = 1'b0;//dontcare
			btype=0;
		end	
//-----------------------------------------------------------------------------------------	 
		//Load *
		5'b00000: begin 
			next_pc_sel   = 1'b0;
			E_alu_op1_sel = 1'b1;
			E_alu_op2_sel = 1'b0;
			E_jb_op1_sel  = 1'b0;//dontcare
			btype=0;
		end
//-----------------------------------------------------------------------------------------
		//Store *
		5'b01000: begin 
			next_pc_sel   = 1'b0;
			E_alu_op1_sel = 1'b1;
			E_alu_op2_sel = 1'b0;
			E_jb_op1_sel  = 1'b0;//dontcare
			btype=0;
		end 
//-----------------------------------------------------------------------------------------
		//JAL *
		5'b11011: begin 
			next_pc_sel   = 1'b1;
			E_alu_op1_sel = 1'b0;
			E_alu_op2_sel = 1'b0;//dontcare
			E_jb_op1_sel  = 1'b0;
			btype=0;
		end		
//-----------------------------------------------------------------------------------------
		//JALR *
		5'b11001: begin 
			next_pc_sel   = 1'b1;//**
			E_alu_op1_sel = 1'b0;
			E_alu_op2_sel = 1'b0;//dontcare
			E_jb_op1_sel  = 1'b1;//**
			btype=0;
		end
//-----------------------------------------------------------------------------------------
		//Branch*
		5'b11000: begin 
			btype=1;
			if(alu_out_last_bit^predict)begin	//jump
				next_pc_sel = 1'b1;
			end
			else begin				//not jump
				next_pc_sel = 1'b0;
			end
			E_alu_op1_sel = 1'b1;
			E_alu_op2_sel = 1'b1;//**
			E_jb_op1_sel  = 1'b0;
		end
//-----------------------------------------------------------------------------------------
		//FLW *
		`FLW: begin 
			next_pc_sel   = 1'b0;
			E_alu_op1_sel = 1'b1;//rs1
			E_alu_op2_sel = 1'b0;//Imm12
			E_jb_op1_sel  = 1'b0;//dontcare
			btype=1'b0;
		end
//-----------------------------------------------------------------------------------------
		//FSW *
		`FSW: begin 
			next_pc_sel   = 1'b0;
			E_alu_op1_sel = 1'b1;//rs1
			E_alu_op2_sel = 1'b0;//Imm12
			E_jb_op1_sel  = 1'b0;//dontcare
			btype=1'b0;
		end
//-----------------------------------------------------------------------------------------
		//FARITH *
		`FARITH: begin 
			next_pc_sel   = 1'b0;
			E_alu_op1_sel = 1'b1;//rs1
			E_alu_op2_sel = 1'b1;//rs2 or dontcare
			E_jb_op1_sel  = 1'b0;//dontcare
			btype=1'b0;
		end
//-----------------------------------------------------------------------------------------
		default: begin
			btype=0;
			next_pc_sel   = 1'b0;
			E_alu_op1_sel = 1'b0;
			E_alu_op2_sel = 1'b0;
			E_jb_op1_sel  = 1'b0;	
		end
		endcase
		
//=========================================================================================
		//M Stage
		//Control signal : M_dm_w_en
		/*if(M_op==5'b01000)begin 
			if(M_f3==3'b000) begin//sb
				M_dm_w_en = 4'b0001;
			end
			else if(M_f3==3'b001) begin//sh
				M_dm_w_en = 4'b0011;
			end
			else begin//sw
				M_dm_w_en = 4'b1111;
			end
		end*/
		if ((M_op == 5'b00000 || M_op == 5'b01000) && (PReady == 1'd0)) begin
			PStrobe = 1'd1;
			if(M_op==5'b01000)begin 
				M_dm_w_en = 4'b0000;//store
			end 
			else begin
				M_dm_w_en = 4'b0001; //read
			end
		end
		else if(M_op == `FSW) begin
			M_dm_w_en = 4'b1110;
			PStrobe = 1'd1;
		end 
		else begin
			M_dm_w_en = 4'b0001;
			PStrobe = 1'd0;
		end
		
		
//=========================================================================================
		//W Stage
		//Control signal : W_rd_index,W_func3_out,W_wb_en,W_wb_data_sel
		W_rd_index = W_rd;
		W_func3_out = W_f3;
		W_fwb_en = (is_W_use_rd && W_rd_fp);
		W_wb_en = (is_W_use_rd && ~W_rd_fp);
		W_wb_data_sel = (W_op == 5'b00000) || (W_op == `FLW);
		/*case(W_op)  
//-----------------------------------------------------------------------------------------		
		//Register - Register
		5'b01100: begin  
			W_wb_en       = 1'b1; 
			W_wb_data_sel = 1'b0;
			
		end		
//-----------------------------------------------------------------------------------------			
		//Register - Immediate
		5'b00100: begin 
			W_wb_en       = 1'b1; 
			W_wb_data_sel = 1'b0;
		end		
//-----------------------------------------------------------------------------------------
		//LUI
		5'b01101: begin 
			W_wb_en       = 1'b1; 
			W_wb_data_sel = 1'b0;
		end		
//-----------------------------------------------------------------------------------------
		//AUIPC
		5'b00101: begin 
			W_wb_en       = 1'b1; 
			W_wb_data_sel = 1'b0;
		end	
//-----------------------------------------------------------------------------------------	 
		//Load 
		5'b00000: begin 
			W_wb_en       = 1'b1; 
			W_wb_data_sel = 1'b1;
		end
//-----------------------------------------------------------------------------------------
		//Store 
		5'b01000: begin 
			W_wb_en       = 1'b0; 
			W_wb_data_sel = 1'b0;
		end 
//-----------------------------------------------------------------------------------------
		//JAL 
		5'b11011: begin 
			W_wb_en       = 1'b1; 
			W_wb_data_sel = 1'b0;
		end		
//-----------------------------------------------------------------------------------------
		//JALR 
		5'b11001: begin 
			W_wb_en       = 1'b1; 
			W_wb_data_sel = 1'b0;
		end
//-----------------------------------------------------------------------------------------
		//Branch
		5'b11000: begin 
			W_wb_en       = 1'b0; 
			W_wb_data_sel = 1'b0;
		end
//-----------------------------------------------------------------------------------------
		default: begin
			W_wb_en       = 1'b0; 
			W_wb_data_sel = 1'b0;
		end
		endcase*/
			
		
	end
endmodule
