module control (inputInstruction, Regdest, Regwrite, ALUsrc);
	
	input [5:0] inputInstruction;
	output reg Regdest;
	output reg Regwrite;
	output reg ALUsrc;

	always @(inputInstruction) begin
		if( inputInstruction == 6'b000000 ) begin	// add,and,or,sub,sra,sll,srl,sltu 	// R-type
			Regdest = 1'b1;
			Regwrite = 1'b1;
			ALUsrc = 1'b0;
		end else begin		// addi, addiu, andi, ori, slti, lui // I-type
			Regdest = 1'b0;	
			Regwrite = 1'b1;
			ALUsrc = 1'b1;
		end
	end
	
endmodule