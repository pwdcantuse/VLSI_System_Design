`include "./src/ALU.v"     //.v檔要放在src資料夾裡
`include "./src/Decoder.v"
`include "./src/Imm_Ext.v"
`include "./src/JB_Unit.v"
`include "./src/LD_Filter.v"
`include "./src/RegFile.v"
`include "./src/FRegFile.v"
`include "./src/Definition.v"
`include "./src/FPU.v"
`include "./src/Predictor.v"
`include "./src/Reg_PC.v"
`include "./src/Mux.v"
//`include "./src/SRAM.v "
`include "./src/Controller.v"
`include "./src/Reg_D.v"
`include "./src/Reg_E.v"
`include "./src/Reg_M.v"
`include "./src/Reg_W.v"
`include "./src/Mux_3to1.v"


module Top (
input clk,
input rst,
output [3:0]F_im_w_en,
output [31:0]current_pc,
input [31:0]read_data_im,
/*
output [3:0]M_dm_w_en,
output [31:0]alu_out_out_m,
output [31:0]rs2_data_out_m,
input [31:0]read_data_dm,
*/
output overflow,

output [2:0] M_f3,
output PStrobe,
output [1:0] PRW,	 //CHANGE
output [15:0] PAddress,
inout [31:0] PData,
input PReady

);

wire cacheStall;

wire [4:0]dc_out_opcode;//controller inputs
wire [2:0]dc_out_func3;
wire [4:0]dc_out_func5;
wire [6:0] dc_out_func7;
wire [4:0]dc_out_rd_index,dc_out_rs1_index,dc_out_rs2_index;
wire [31:0]alu_out;
wire [31:0]fpu_out;
wire stall;//controller output
wire D_rs1_data_sel,D_rs2_data_sel;
wire D_rs1_fp_sel,D_rs2_fp_sel;
wire [1:0]E_rs1_data_sel,E_rs2_data_sel;
//wire [3:0]F_im_w_en;
wire next_pc_sel;
wire [4:0]E_opcode_out;
wire E_func1_out;
wire [2:0]E_func3_out;
wire [4:0]E_func5_out;
wire [6:0] E_func7_out;
wire E_alu_op1_sel,E_alu_op2_sel;
wire E_alu_fp_sel;
wire E_jb_op1_sel;
wire [3:0]M_dm_w_en;
wire W_wb_en;
wire W_fwb_en;
wire [2:0]W_func3_out;
wire [4:0]W_rd_index;
wire W_wb_data_sel;
//wire [31:0]current_pc;
//wire [31:0]read_data_im;
wire [31:0]read_data_dm;
wire  [31:0]alu_out_out_m;
wire [31:0]rs2_data_out_m;

wire [31:0]mux_alu_op1_Mux_out,mux_alu_op2_Mux_out,mux_jb_op1_Mux_out,mux_wb_sel_Mux_out,mux_next_pc_Mux_out,mux_D_rs1_data_Mux_out,mux_D_rs2_data_Mux_out;
//---Floating Point-----
wire [31:0] mux_D_frs1_data_Mux_out, mux_D_frs2_data_Mux_out, 
			mux_D_rs1_fp_Mux_out, mux_D_rs2_fp_Mux_out, 
			mux_alu_fp_Mux_out;
//----------------------
wire [31:0]reg_d_inst_out;
wire [31:0]imm_ext_imm_ext_out,reg_e_imm_out;
wire [31:0]jb_unit_jb_out,reg_w_ld_data_out,ld_filter_ld_data_f;
wire [31:0]regfile_rs1_data_out,regfile_rs2_data_out,reg_d_pc_out,reg_e_pc_out,reg_e_rs1_data_out,reg_e_rs2_data_out;
wire [31:0]fregfile_rs1_data_out,fregfile_rs2_data_out;
wire [31:0]adder_pc_add_4;
wire [31:0]mux_E_rs2_data_Mux_out,alu_out_out_w,mux_E_rs1_data_Mux_out;
wire [31:0]reg0;
wire predict;
wire btype;

assign PAddress = alu_out_out_m[15:0];
assign PRW = M_dm_w_en[1:0];	 //CHANGE


Controller controller(
	//input
	.clk(clk),
	.rst(rst),
	.predict(predict),
	.opcode(dc_out_opcode),
	.func3(dc_out_func3),
	.func5(dc_out_func5),
	.func7(dc_out_func7),
	.rd_index(dc_out_rd_index),
	.rs1_index(dc_out_rs1_index),
	.rs2_index(dc_out_rs2_index),
	.alu_out_last_bit(alu_out[0]),   
	//output
	.btype(btype),
	.stall(stall),
	.D_rs1_data_sel(D_rs1_data_sel),
	.D_rs2_data_sel(D_rs2_data_sel),
	.D_rs1_fp_sel(D_rs1_fp_sel),
	.D_rs2_fp_sel(D_rs2_fp_sel),
	.E_rs1_data_sel(E_rs1_data_sel),
	.E_rs2_data_sel(E_rs2_data_sel),
	.F_im_w_en(F_im_w_en),         
	.next_pc_sel(next_pc_sel),            
	.E_opcode_out(E_opcode_out),
	.E_func1_out(E_func1_out),
	.E_func3_out(E_func3_out),
	.E_func5_out(E_func5_out),
	.E_func7_out(E_func7_out),
 	.E_alu_op1_sel(E_alu_op1_sel),          
	.E_alu_op2_sel(E_alu_op2_sel),
	.E_alu_fp_sel(E_alu_fp_sel),          
	.E_jb_op1_sel(E_jb_op1_sel),           
	.M_dm_w_en(M_dm_w_en),         
	.W_wb_en(W_wb_en),
	.W_fwb_en(W_fwb_en),                
	.W_func3_out(W_func3_out),
	.W_rd_index(W_rd_index),
	.W_wb_data_sel(W_wb_data_sel),
//-------------Cache--------------------
	.PStrobe(PStrobe),
	.M_f3(M_f3),   
	.PReady(PReady),
	.cacheStall(cacheStall)         
);
/*
SRAM im(
    .clk(clk),
	.w_en(F_im_w_en),
	.address(current_pc[15:0]),
	.write_data(32'b0), //w_en==0:write_data不會用到
	.read_data(read_data_im)
);
SRAM dm(
    .clk(clk),
	.w_en(M_dm_w_en),
	.address(alu_out_out_m[15:0]),
	.write_data(rs2_data_out_m),
	.read_data(read_data_dm)
);*/
ALU alu(
	.opcode(E_opcode_out),
	.func3(E_func3_out),
	.func7(E_func7_out),
	.operand1(mux_alu_op1_Mux_out),
	.operand2(mux_alu_op2_Mux_out),
	.alu_out(alu_out),
	.overflow(overflow)
);
FPU fpu(	
	.func5(E_func5_out),
	.func1(E_func1_out),
	.operand1(mux_alu_op1_Mux_out),
	.operand2(mux_alu_op2_Mux_out),
	.out(fpu_out)
);
Decoder decoder(
	.inst(reg_d_inst_out),
	.dc_out_opcode(dc_out_opcode),
	.dc_out_func3(dc_out_func3),
	.dc_out_func5(dc_out_func5),
	.dc_out_func7(dc_out_func7),
	.dc_out_rs1_index(dc_out_rs1_index),
	.dc_out_rs2_index(dc_out_rs2_index),
	.dc_out_rd_index(dc_out_rd_index)
);
Imm_Ext imm_ext(
	.inst(reg_d_inst_out),
	.imm_ext_out(imm_ext_imm_ext_out)
);
JB_Unit jb_unit(
	.operand1(mux_jb_op1_Mux_out),
	.operand2(reg_e_imm_out),
	.pc(reg_e_pc_out),
	.predict(predict),
	.opcode(E_opcode_out),
	.jb_out(jb_unit_jb_out)   //jb_pc接到mux為1的地方
);
LD_Filter ld_filter(
	.func3(W_func3_out),
	.ld_data(reg_w_ld_data_out),
	.ld_data_f(ld_filter_ld_data_f)
);
RegFile regfile(
	.clk(clk),
	.wb_en(W_wb_en),
	.wb_data(mux_wb_sel_Mux_out),
	.rd_index(W_rd_index),
	.rs1_index(dc_out_rs1_index),
	.rs2_index(dc_out_rs2_index),
	.rs1_data_out(regfile_rs1_data_out),
	.rs2_data_out(regfile_rs2_data_out),
	.reg0(32'd0)
);
FRegFile fregfile (
	.clk(clk),
	.wb_en(W_fwb_en),
	.wb_data(mux_wb_sel_Mux_out),
	.rd_index(W_rd_index),
	.rs1_index(dc_out_rs1_index),
	.rs2_index(dc_out_rs2_index),
	.rs1_data_out(fregfile_rs1_data_out),
	.rs2_data_out(fregfile_rs2_data_out)
);
Predictor predictor(
	.clk(clk),
	.rst(rst),
	.btype(btype),
	.inst(read_data_im),
	.pc(current_pc),
	.pc_add_4(adder_pc_add_4),
	.taken(alu_out[0]), //(=1 taken) (=0 not taken)
	.predict(predict) //(=1 taken) (=0 not taken)
);

Reg_PC reg_pc(
	.clk(clk),
	.rst(rst),
	.cacheStall(cacheStall),
	.stall(stall),
	.next_pc(mux_next_pc_Mux_out),
	.current_pc(current_pc)
);
Reg_D reg_d(
	.clk(clk),
	.rst(rst),
	.cacheStall(cacheStall),
	.stall(stall),
	.jb(next_pc_sel),
	.pc_in(current_pc),
	.inst_in(read_data_im),
	.pc_out(reg_d_pc_out),
	.inst_out(reg_d_inst_out)
);
Reg_E reg_e(
	.clk(clk),
	.rst(rst),
	.cacheStall(cacheStall),
	.stall(stall),
	.jb(next_pc_sel),
	.pc_in(reg_d_pc_out),
	.rs1_data_in(mux_D_rs1_fp_Mux_out), //watch out!!
	.rs2_data_in(mux_D_rs2_fp_Mux_out),
	.imm_in(imm_ext_imm_ext_out),
	.pc_out(reg_e_pc_out),
	.rs1_data_out(reg_e_rs1_data_out),
	.rs2_data_out(reg_e_rs2_data_out),
	.imm_out(reg_e_imm_out)
);

Reg_M reg_m(
	.clk(clk),
	.rst(rst),
	.cacheStall(cacheStall),
	.alu_out_in(mux_alu_fp_Mux_out),
	.rs2_data_in(mux_E_rs2_data_Mux_out),
	.alu_out_out(alu_out_out_m),
	.rs2_data_out(rs2_data_out_m)

);
Reg_W reg_w(
	.clk(clk),
	.rst(rst),
	.cacheStall(cacheStall),
	.alu_out_in(alu_out_out_m),
	.ld_data_in(read_data_dm),
	.alu_out_out(alu_out_out_w),
	.ld_data_out(reg_w_ld_data_out)

);
Mux mux_next_pc(
	.Mux_sel(next_pc_sel),
	.Mux_in1(jb_unit_jb_out),
	.Mux_in2(adder_pc_add_4),
	.Mux_out(mux_next_pc_Mux_out)
);
Mux mux_alu_op1(
	.Mux_sel(E_alu_op1_sel),
	.Mux_in1(mux_E_rs1_data_Mux_out),
	.Mux_in2(reg_e_pc_out),
	.Mux_out(mux_alu_op1_Mux_out)
);
Mux mux_alu_op2(
	.Mux_sel(E_alu_op2_sel),
	.Mux_in1(mux_E_rs2_data_Mux_out),
	.Mux_in2(reg_e_imm_out),
	.Mux_out(mux_alu_op2_Mux_out)
);
Mux mux_alu_fp(
	.Mux_sel(E_alu_fp_sel),
	.Mux_in1(fpu_out),
	.Mux_in2(alu_out),
	.Mux_out(mux_alu_fp_Mux_out)
);
Mux mux_jb_op1(
	.Mux_sel(E_jb_op1_sel),
	.Mux_in1(mux_E_rs1_data_Mux_out),
	.Mux_in2(reg_e_pc_out),
	.Mux_out(mux_jb_op1_Mux_out)
);
Mux mux_wb_sel(
	.Mux_sel(W_wb_data_sel),
	.Mux_in1(ld_filter_ld_data_f),
	.Mux_in2(alu_out_out_w),
	.Mux_out(mux_wb_sel_Mux_out)
);
//新增的mux*4
Mux mux_D_rs1_data(
	.Mux_sel(D_rs1_data_sel),
	.Mux_in1(mux_wb_sel_Mux_out),
	.Mux_in2(regfile_rs1_data_out),
	.Mux_out(mux_D_rs1_data_Mux_out)
);
Mux mux_D_rs2_data(
	.Mux_sel(D_rs2_data_sel),
	.Mux_in1(mux_wb_sel_Mux_out),
	.Mux_in2(regfile_rs2_data_out),
	.Mux_out(mux_D_rs2_data_Mux_out)
);
Mux mux_D_frs1_data(
	.Mux_sel(D_rs1_data_sel),
	.Mux_in1(mux_wb_sel_Mux_out),
	.Mux_in2(fregfile_rs1_data_out),
	.Mux_out(mux_D_frs1_data_Mux_out)
);
Mux mux_D_frs2_data(
	.Mux_sel(D_rs2_data_sel),
	.Mux_in1(mux_wb_sel_Mux_out),
	.Mux_in2(fregfile_rs2_data_out),
	.Mux_out(mux_D_frs2_data_Mux_out)
);

Mux mux_D_rs1_fp(
	.Mux_sel(D_rs1_fp_sel),
	.Mux_in1(mux_D_frs1_data_Mux_out), //from FREG
	.Mux_in2(mux_D_rs1_data_Mux_out),  //from REG 
	.Mux_out(mux_D_rs1_fp_Mux_out)
);
Mux mux_D_rs2_fp(
	.Mux_sel(D_rs2_fp_sel),
	.Mux_in1(mux_D_frs2_data_Mux_out), //from FREG
	.Mux_in2(mux_D_rs2_data_Mux_out),  //from REG 
	.Mux_out(mux_D_rs2_fp_Mux_out)
);
Mux_3to1 mux_E_rs1_data(
	.Mux_sel(E_rs1_data_sel),
	.Mux_in1(mux_wb_sel_Mux_out),
	.Mux_in2(alu_out_out_m),
	.Mux_in3(reg_e_rs1_data_out),
	.Mux_out(mux_E_rs1_data_Mux_out)
);
Mux_3to1 mux_E_rs2_data(
	.Mux_sel(E_rs2_data_sel),
	.Mux_in1(mux_wb_sel_Mux_out),
	.Mux_in2(alu_out_out_m),
	.Mux_in3(reg_e_rs2_data_out),
	.Mux_out(mux_E_rs2_data_Mux_out)
);

assign PData = (M_dm_w_en[0]) ? 32'dz : rs2_data_out_m ;
assign read_data_dm = (M_dm_w_en[0]) ? PData : 32'dz;


endmodule
