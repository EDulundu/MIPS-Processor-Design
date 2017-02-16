// SAFA EMRE DULUNDU
//	
//	131044044
//
//	PROJECT 3 DE0
//	
//	COMPUTER ORGANIZATION
module mips_core_de0 (result, input_instruction);
	output [31:0] result;
	input [31:0] input_instruction;
	reg [31:0] registers [0:31];

	reg Regdest,Regwrite,ALUsrc;	// control sinyalleri.
	reg [31:0] data_3;				// ALU ya girecek 2. input
	
	wire [15:0] imm16 = input_instruction[15:0];						// immediate sayi.
	wire signed [31:0] immediate = {{16{imm16[15]}}, imm16}; 	// 16 bitlik immediate sayi 32 bite extend edildi.					
	wire [31:0] sonuc;		// ALUnun sonucu
	
	initial begin
		registers[0] = 0; 	registers[1] = 2;		registers[2] = 3;		registers[3] = 4;
		registers[4] = 0;		registers[5] = 5;		registers[6] = 8;		registers[7] = 11;
		registers[8] = 15;	registers[9] = 3;		registers[10] = 3;	registers[11] = 4;
		registers[12] = 1;	registers[13] = 0;	registers[14] = 0;	registers[15] = 1;
		registers[16] = 2;	registers[17] = 5;	registers[18] = 3;	registers[19] = 5;
		registers[20] = 0;	registers[21] = 4;	registers[22] = 0;	registers[23] = 1;
		registers[24] = 2;	registers[25] = 2; 	registers[26] = 0;	registers[27] = 0;
		registers[28] = 7;	registers[29] = 8;	registers[30] = 1;	registers[31] = 1;
	end
	
	// Control sinyalleri hesaplanir.
	always @(input_instruction) begin
		if( input_instruction[31:26] == 6'b000000 ) begin	// add,and,or,sub,sra,sll,srl,sltu 	// R-type
			Regdest = 1'b1;
			Regwrite = 1'b1;
			ALUsrc = 1'b0;
		end else begin			// addi, addiu, andi, ori, slti, lui // I-type
			Regdest = 1'b0;	
			Regwrite = 1'b1;
			ALUsrc = 1'b1;
		end
	end
	
	// Register destination 0 ise Rt, 1 ise Rd secilir.											
	always @(posedge Regdest) begin // yada sadece Regdest
		case(Regdest)
			0 : begin if( input_instruction[20:16] == 0 ) begin
						$display("!!!! Destionation $zero olamaz !!!!\n\n");
						$stop;
					end else if( input_instruction[20:16] == 26 | input_instruction[20:16] == 27 ) begin
						$display("!!!! $k0 $k1 olamaz OS kullanir !!!!\n\n");
						$stop;
					end
				end
			1 : begin if( input_instruction[15:11] == 0 ) begin
						$display("!!!! Destionation $zero olamaz !!!!\n\n");
						$stop;
					end else if( input_instruction[15:11] == 26 | input_instruction[15:11] == 27 ) begin
						$display("!!!! $k0 $k1 olamaz OS kullanir !!!!\n\n");
						$stop;
					end
				end
		endcase
	end
	
	// immediate yada rt secilir.
	always @(immediate or ALUsrc) begin
		case(ALUsrc)
			0 : data_3 = registers[input_instruction[20:16]];
			1 : data_3 = immediate;
		endcase
	end
	
	// Islem yapilir.
	ALU operation_2(registers[input_instruction[25:21]], data_3, input_instruction[5:0] , input_instruction[31:26] , input_instruction[10:6], sonuc);
	
	// Sonuc basilir.
	initial begin
		$monitor("Result : %b ", sonuc);
	end
	
	// Sonuc atanir.
	assign result = sonuc;
	
endmodule
