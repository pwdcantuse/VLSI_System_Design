`include "./src/Multiplier.v" /*include*/
`include "./src/Definition.v"
module ALU (
input [4:0] opcode,
input [2:0] func3,
input [6:0] func7, /*move to 7 bit*/
input [31:0] operand1,
input [31:0] operand2,
output reg [31:0] alu_out,
output reg overflow
);
reg [63:0]shiftTemp;
reg [31:0] operand2_c;
wire [32:0] mul_result;

Multiplier M1(.A(operand1), .B(operand2), .Result(mul_result));/*mul*/
	always@(*)begin
		operand2_c = 32'b0;
		overflow = 1'b0; /*only in add sub*/
		shiftTemp = 64'b0;
		//用opcode來分類指令(開頭)
	    case(opcode)  
//-----------------------------------------------------------------------------------------		
		//Register - Register(開頭)
		5'b01100: begin  
			//用func3來分類指令(開頭)
			case(func3)
			3'b000: begin//add or sub or mul
				if(func7[0]) begin
					{overflow,alu_out} = mul_result;/*mul*/
				end
				else begin/*add or sub*/
					operand2_c = ( {32{func7[5]}} ^ operand2 ) + {31'b0,func7[5]}; /*func7[5]*/
					{overflow,alu_out}= {1'b0,operand1} + {1'b0,operand2_c};
				end
			end
			3'b001: begin//sll
				alu_out= operand1<<operand2[4:0];////////////////原本有signed
			end
			3'b010: begin//slt(sign)//********************
				/*if(operand1[31]==1&&operand2[31]==0)alu_out=32'b1;//operand1是負的、operand2是正的==>operand2 > operand1
				else if(operand1[31]==0&&operand2[31]==1)alu_out=32'b0;//operand1是正的、operand2是負的==>operand2 < operand1
				else alu_out=(operand2>operand1)?32'b1:32'b0;//同號//why (operand2-operand1>0) wrong*/
				//alu_out=($signed(operand1)<$signed(operand2))?32'b1:32'b0;
				if((operand1[31]^operand2[31]))alu_out={31'b0,operand1[31]};//operand1是負的、operand2是正的==>operand2 > operand1
				else alu_out=(operand2>operand1)?32'b1:32'b0;
			end
			3'b011: begin//sltu(op本來就是預設unsigned)
				alu_out=(operand1<operand2)?32'b1:32'b0;
			end
			3'b100: begin//xor
				alu_out=operand1^operand2;
			end
			3'b101: begin//sra or srl
				/*if(func7) begin//sra
					shiftTemp={{32{operand1[31]}},operand1}>>operand2[4:0];//做signed extend to 64 bits，再shift
					alu_out= shiftTemp[31:0];//////////////////原本有signed
				end
				else begin//srl
					alu_out= operand1>>operand2[4:0];////////原本有signed
				end*/
				shiftTemp={{32{func7[5] & operand1[31]}},operand1}>>operand2[4:0];//做signed extend to 64 bits，再shift /*func7[5]*/
				alu_out= shiftTemp[31:0];
			end
			3'b110: begin//or
				alu_out=operand1|operand2;
			end
			3'b111: begin//and
				alu_out=operand1&operand2;
			end
			endcase//用func3來分類指令(結尾)
		end//Register - Register(結尾)
		
//-----------------------------------------------------------------------------------------			
		//Register - Immediate(開頭)
		5'b00100: begin 
			//用func3來分類指令(開頭)
			case(func3)
			3'b000:begin//addi
				{overflow,alu_out}={1'b0,operand1}+{1'b0,operand2};
			end
			3'b010:begin//slti
				/*if(operand1[31]==1&&operand2[31]==0)alu_out=32'b1;//operand1是負的、operand2是正的==>operand2 > operand1
				else if(operand1[31]==0&&operand2[31]==1)alu_out=32'b0;//operand1是正的、operand2是負的==>operand2 < operand1
				else alu_out=(operand2>operand1)?32'b1:32'b0;//同號//why (operand2-operand1>0) wrong
				//alu_out=($signed(operand1)<$signed(operand2))?32'b1:32'b0;*/
				if((operand1[31]^operand2[31]))alu_out={31'b0,operand1[31]};//operand1是負的、operand2是正的==>operand2 > operand1
				else alu_out=(operand2>operand1)?32'b1:32'b0;
			end
			3'b011: begin//sltiu(op本來就是預設unsigned)
				alu_out=(operand1<operand2)?32'b1:32'b0;
			end
			3'b100:begin//xori
				alu_out=operand1^operand2;
			end
			3'b110: begin//ori
				alu_out=operand1|operand2;
			end
			3'b111: begin//andi
				alu_out=operand1&operand2;
			end
			3'b001: begin//slli
				alu_out= operand1<<operand2[4:0];/////////////////原本有signed
			end
			3'b101: begin//srai or srli
				/*if(func7) begin//srai
					shiftTemp={{32{operand1[31]}},operand1}>>operand2[4:0];//做signed extend to 64 bits，再shift
					alu_out= shiftTemp[31:0];//////////////////原本有signed
				end
				else begin//srli
					alu_out= operand1>>operand2[4:0];//////////////原本有signed
				end*/
				shiftTemp={{32{func7[5] & operand1[31]}},operand1}>>operand2[4:0];//做signed extend to 64 bits，再shift /*func7[5]*/
				alu_out= shiftTemp[31:0];
			end
			endcase//用func3來分類指令(結尾)
		end//Register - Immediate(結尾)
		
//-----------------------------------------------------------------------------------------
		//LUI(開頭)
		5'b01101: begin 
			alu_out = operand2;
		end//LUI(結尾)
		
//-----------------------------------------------------------------------------------------
		//AUIPC(開頭)
		5'b00101: begin 
			{overflow,alu_out}={1'b0,operand1}+{1'b0,operand2};
		end//AUIPC(結尾)
	
//-----------------------------------------------------------------------------------------	 
		//Load (開頭)
		5'b00000: begin 
			{overflow,alu_out}={1'b0,operand1}+{1'b0,operand2};
		end//Load (結尾)

//-----------------------------------------------------------------------------------------
		//Store (開頭)
		5'b01000: begin 
			{overflow,alu_out}={1'b0,operand1}+{1'b0,operand2};
		end//Store (結尾)

//-----------------------------------------------------------------------------------------
		//JAL (開頭)
		5'b11011: begin 
			{overflow,alu_out}={1'b0,operand1}+33'd4;
		end//JAL (結尾)
		
//-----------------------------------------------------------------------------------------
		//JALR (開頭)
		5'b11001: begin 
			{overflow,alu_out}={1'b0,operand1}+33'd4;
		end//JALR (結尾)

//-----------------------------------------------------------------------------------------
		//Branch(開頭)
		5'b11000: begin 
			//用func3來分類指令(開頭)
			case(func3)
			3'b000:begin//beq
				alu_out=(operand1==operand2)?32'b1:32'b0;
			end
			3'b001:begin//bne
				alu_out=(operand1!=operand2)?32'b1:32'b0;
			end
			3'b100:begin//blt
				/*if(operand1[31]==1'b1&&operand2[31]==1'b0)alu_out=32'b1;//operand1是負的、operand2是正的==>operand2 > operand1
				else if(operand1[31]==1'b0&&operand2[31]==1'b1)alu_out=32'b0;//operand1是正的、operand2是負的==>operand2 < operand1
				else alu_out=(operand2>operand1)?32'b1:32'b0;//同號//why (operand2-operand1>0) wrong
				//alu_out=($signed(operand1)<$signed(operand2))?32'b1:32'b0;*/
				if((operand1[31]^operand2[31]))alu_out={31'b0,operand1[31]};//operand1是負的、operand2是正的==>operand2 > operand1
				else alu_out=(operand2>operand1)?32'b1:32'b0;				
			end
			3'b101: begin//bge
				/*if(operand1[31]==1'b1&&operand2[31]==1'b0)alu_out=32'b0;//operand1是負的、operand2是正的==>operand2 > operand1
				else if(operand1[31]==1'b0&&operand2[31]==1'b1)alu_out=32'b1;//operand1是正的、operand2是負的==>operand2 < operand1
				else alu_out=(operand1>=operand2)?32'b1:32'b0;//同號//why (operand2-operand1>0) wrong
				//alu_out=($signed(operand1)>=$signed(operand2))?32'b1:32'b0;*/
				if((operand1[31]^operand2[31]))alu_out={31'b0,operand2[31]};//operand1是負的、operand2是正的==>operand2 > operand1
				else alu_out=(operand1>=operand2)?32'b1:32'b0;
			end
			3'b110: begin//bltu
				alu_out=(operand1<operand2)?32'b1:32'b0;
			end
			3'b111: begin//bgeu
				alu_out=(operand1>=operand2)?32'b1:32'b0;
			end
			default: begin
				alu_out=32'b0;
			end
			endcase//用func3來分類指令(結尾)
		end//Branch(結尾)
//-----------------------------------------------------------------------------------------	 
		//FLW (開頭)
		`FLW: begin 
			alu_out=operand1+operand2;
		end//FLW (結尾)

//-----------------------------------------------------------------------------------------
		//FSW (開頭)
		`FSW: begin 
			alu_out=operand1+operand2;
		end//FSW (結尾)
//-----------------------------------------------------------------------------------------
		default: begin
			alu_out=32'b0;
		end
		
		endcase//用opcode來分類指令(結尾)
	end

endmodule
