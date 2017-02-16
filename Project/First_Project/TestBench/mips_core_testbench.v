module mips_core_testbench (result, input_instruction, rs_content, rt_content);
	output reg [31:0] result;
	input [31:0] input_instruction;
	input [31:0] rs_content;
	input [31:0] rt_content;
			
	reg [31:0] data_3;					// R-type ise rt ,I-type ise immediate konulur.		
	wire [31:0] bench_result;			// ALU'nun sonucunu almak icin kullanilir.
	wire Regdest, Regwrite, ALUsrc;	// Control sinyalleri.
	wire [15:0] imm16 = input_instruction[15:0];		// immediate sayi konulur.			
	wire signed [31:0] immediate = {{16{imm16[15]}}, imm16};	// Immediate 16 bitlik 32 bitlige extend edilir. 			
	
	// rs, rt, rd, shamt, opcode, func parcalanir.
	wire [4:0] rs = input_instruction[25:21];
	wire [4:0] rt = input_instruction[20:16];
	wire [4:0] rd = input_instruction[15:11];
	wire [4:0] shamt = input_instruction[10:6];
	wire [5:0] opcode = input_instruction[31:26];
	wire [5:0] func = input_instruction[5:0];	

	// Control sinyalleri belirenir.
	control ctrl_2(opcode, Regdest, Regwrite, ALUsrc);
	
	// I-type ise immediate secilir, R-type ise rt'nin contenti secilir. 
	always @(ALUsrc or rt_content or immediate) begin
		case(ALUsrc)
			0 : data_3 = rt_content;
			1 : data_3 = immediate;
		endcase
	end

	// ALU islemi yapar.
	ALU operation(rs_content, data_3, func, opcode, shamt, bench_result);
	
	// Sonuc resulta koyulur.
	always @(bench_result) begin
		result = bench_result;
		$display("Result : %b", result);
	end
	
endmodule
