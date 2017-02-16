module ALU (reg1, reg2, func, op, shamt ,result);
	
	input signed [31:0] reg1, reg2;
	input [5:0] func, op;
	input [4:0] shamt;
	output reg [31:0] result;
	
	always @(reg2) begin
		if( op == 6'b000000 ) begin
			
			if( func == 6'b100000 ) begin // add
				result = reg1 + reg2; 
				$display("**** ADD ****\n %b + %b", reg1, reg2);
				
			end else if( func == 6'b100100 ) begin // and
				result = reg1 & reg2; 
				$display("**** AND ****\n %b & %b", reg1, reg2);
			
			end else if( func == 6'b100101 ) begin // or
				result = reg1 | reg2; 
				$display("**** OR ****\n %b | %b", reg1, reg2);
			
			end else if( func == 6'b100010 ) begin // sub
				result = reg1 - reg2; 
				$display("**** SUB ****\n %b - %b", reg1, reg2);
			
			end else if( func == 6'b000011 ) begin // sra
				result = reg2 >>> shamt; 
				$display("**** SRA ****\n %b >>> %b", reg2, shamt);
		
			end else if( func == 6'b000010 ) begin // srl
				result = reg2 >> shamt; 
				$display("**** SRL ****\n %b >> %b", reg2, shamt);
			
			end else if( func == 6'b000000 ) begin // sll
				result = reg2 << shamt; 
				$display("**** SLL **** \n%b << %b", reg2, shamt);
				
			end else if( func == 6'b101001 ) begin // sltu
				result = (reg1 < reg2); 
				$display("**** SLTU ****\n %b < %b", reg1, reg2);
			
			end else begin
				$display("No Operation");
			end
		end else begin 
			
			if( op == 6'b001000 ) begin // addi
				result = reg1 + reg2; 
				$display("**** ADDI ****\n %b + %b", reg1, reg2);
			
			end else if( op == 6'b001001 ) begin // addiu
				result = reg1 + reg2; 
				$display("**** ADDIU ****\n %b + %b", reg1, reg2);
			
			end else if( op == 6'b001100 ) begin // andi
				result = reg1 & reg2; 
				$display("**** ANDI ****\n %b & %b", reg1, reg2);
			
			end else if( op == 6'b001101 ) begin // ori
				result = reg1 | reg2; 
				$display("**** ORI ****\n %b | %b", reg1, reg2);
			
			end else if( op == 6'b001010  ) begin // slti
				result = (reg1 < reg2); 
				$display("**** SLTI ****\n %b < %b", reg1, reg2);
			
			end else if( op == 6'b001111 ) begin // lui
				result = (reg2 << 16);
				$display("**** LUI ****\n %b << %b", reg2, 16);
			
			end else begin 
				$display("No operation");
			end end
	end
	
endmodule