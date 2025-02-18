module SRAM(
    input clk,
	input [3:0] w_en,
	input [15:0] address,
	input [31:0] write_data,
	output reg [31:0] read_data
);
    
	reg [7:0] address_mem,address1_mem,address2_mem,address3_mem;
	reg [7:0] mem [0:65535];


	////////////////////////// Combinational /////////////////////////
	always@(*)begin
		case(w_en)
			4'b0000:
			begin
				address_mem = mem[address];        //全不動 
				address1_mem= mem[address+1];
				address2_mem= mem[address+2];
				address3_mem= mem[address+3];
			end
			4'b0001:
			begin
				address_mem = write_data[7:0];     //write byte:只將address_mem改為write_data[7:0]
				address1_mem= mem[address+1];
				address2_mem= mem[address+2];
				address3_mem= mem[address+3];
			end
			4'b0011:
			begin
				address_mem = write_data[7:0];     //write halfword:將address_mem改為write_data[7:0]
				address1_mem= write_data[15:8];    //write halfword:將address1_mem改為write_data[15:8]
				address2_mem= mem[address+2];
				address3_mem= mem[address+3];
			end
			4'b1111:
			begin
				address_mem = write_data[7:0];     //write word:將address_mem改為write_data[7:0]
				address1_mem= write_data[15:8];    //write word:將address1_mem改為write_data[15:8]
				address2_mem= write_data[23:16];   //write word:將address2_mem改為write_data[23:16]
				address3_mem= write_data[31:24];   //write word:將address3_mem改為write_data[31:24]	
			end
			default:
			begin
				address_mem = mem[address];        //全不動 
				address1_mem= mem[address+1];
				address2_mem= mem[address+2];
				address3_mem= mem[address+3];
			end
		endcase	
	end
	
	////////////////////////// Sequential /////////////////////////
	
	always@(posedge clk)begin
	
		mem[address]  <= address_mem;
		mem[address+1]<= address1_mem;
		mem[address+2]<= address2_mem;
		mem[address+3]<= address3_mem;
		
	end
	
	////////////////////////// Combinational /////////////////////////
	// Output logic
	always@(*)begin
		
		read_data[7:0]  = mem[address];     
		read_data[15:8] = mem[address+1];   
		read_data[23:16]= mem[address+2];   
		read_data[31:24]= mem[address+3];   
		
	end	











	
endmodule

