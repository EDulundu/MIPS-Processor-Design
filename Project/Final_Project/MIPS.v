module MIPS(result);
	output reg [31:0] result;
	reg LOOP;	// Loop degistikce program calisir.

	// NOT !!! : Bu kadar ekstra degisken olmasinin sebebi senkron gitmesi icin yapilmistir. Parametrelerindeki degiskenler
	// aktif olunca her modul calismaya basliyor gibi dusunulmeli.
	// Program Counter Degiskenleri
	reg [31:0] PC;
	reg [31:0] nextPC;
	reg [31:0] tempPC;
	wire [31:0] instruction;
	
	inst_mem instr_mod(nextPC,instruction);

	// Decode instruction
	wire [4:0] rs, rt, rd, shamt;
	wire [5:0] opCode, func;
	reg [31:0] tempInstruction;
	
	decode instr_decode(tempInstruction, rs, rt, rd, shamt, opCode, func);
	
	// Sign extend
	wire signed [15:0] imm16;
	wire signed [31:0] immediate;
	wire signed [31:0] zeroExtend;
	wire [31:0] branchAddr;
	wire [31:0] jumpAddr;
	
	assign imm16 = instruction[15:0];
	assign immediate = { {16 {imm16[15]} }, imm16 };
	assign zeroExtend = { { 16{1'b0} }, imm16 };

	// Control Unit sinyaller uretilir
	wire Regdest, Regwrite, Alusrc, Jump, Memwrite, Memtoreg, Memread, Branch;
	
	control ctrl(tempInstruction[31:26], Regdest, Regwrite, Alusrc, Jump, Memwrite, Memtoreg, Memread, Branch);

	// hedef yazilacak register secilir
	reg dest;
	reg [4:0] select_1, select_2;
	wire [4:0] writeRegister;
	
	selectDest destination(dest, select_1, select_2, writeRegister);

	// Register File registerlar okunur
	reg [4:0] input_1, input_2, input_3;
	reg writeEnable;
	reg [31:0] writeData = 32'bx;
	wire [31:0] readPort_1, readPort_2;
	
	registerFile registerFileModul(readPort_1, readPort_2, input_1, input_2, input_3, writeEnable, writeData);

	// ALU degiskenleri
	reg [31:0] Alu_input_2; 
	reg [31:0] Alu_input_1 = 32'bx;
	reg [31:0] temp = 32'bx;

	wire [31:0] alu_result;
	wire zero;
	reg [5:0] f = 6'bx,op = 6'bx;
	reg [4:0] sha = 5'bx;
	
	ALU  operation(Alu_input_1, temp, f, op, sha, alu_result, zero);
	
	// Data Memory degiskenleri
	wire [31:0] data_out;
	reg [31:0] data_in;
	reg [31:0] adress;
	reg MemWriteEnable;
	reg MemReadEnable;
	reg [5:0] byteCode;
	
	data_memory dataModul(data_out, adress, data_in, MemWriteEnable, MemReadEnable, byteCode);

	initial PC = 0;	// t = 0 aninda 0 atandi.

	always @(LOOP) begin 		// LOOP degisince aktif oldu block
		// Start PC
		nextPC = PC;  
	#5; 
		tempInstruction = instruction;
	#5; 
		// Register destination select
		select_1 = rt;
		select_2 = rd;
		dest = Regdest;
	#10; 
		// Register File Baslangic
		writeEnable = Regwrite;
		input_1 = rs;
		input_2 = rt;
		input_3 = writeRegister;
		// Register File sonu
	#5;	
		// immediate or rt select
		if( Alusrc == 1'b1 ) begin
			if( opCode == 6'b001110 || opCode == 6'b001100 || opCode == 6'b001101 )
				Alu_input_2 = zeroExtend;	// andi, ori ,xori ise zero extendi secer.
			else
				Alu_input_2 = immediate;	// Bu ucu disinda ise immediate type alir.
	    end else
			Alu_input_2 = readPort_2;		// r-tpe ise rt degeri alir.
		//  Herseyi Ekrana Basar...
		$display("------------------------- Instruction Fetch ------------------------");
		$display("PC : %d instruction : %b", PC[10:0], instruction);
		$display("------------------------- Control Signals --------------------------");
		$display("PC : %d , Regdest : %b , Regwrite : %b , Alusrc : %b , Memwrite : %b , Memread : %b , Memtoreg : %b , Branch : %b , Jump : %b", PC[10:0],Regdest,Regwrite,Alusrc,Memwrite,Memread,Memtoreg,Branch,Jump);
		$display("------------------------- Write Register ---------------------------");
		$display("write Register : %d", writeRegister);
		$display("------------------------- Registers Content ------------------------");
		$display("rs_content : %b , rt_content : %b", readPort_1,readPort_2);
		$display("--------------------------- ALU Input ------------------------------");
		$display("Alu_input_1: %b , Alu_input_2: %b", readPort_1,Alu_input_2);
	
	#5;
		// Degisiklik yok ise alwayse girmez kendi icerisinde.
		temp = 32'bx;
		Alu_input_1 = 32'bx;
		f = 6'bx;					// function code atildi.
		op = 6'bx;					// op code atildi.
		sha = 5'bx;	
		if( opCode != 6'b000010 && opCode != 6'b000011 ) begin   // j instructioni olup olmadigina bakar.
			// ALU baslangic
			temp = Alu_input_2;			// Alunun input2 si atildi.
			Alu_input_1 = readPort_1;	// Alunun input1 girisi atildi.
			f = func;					// function code atildi.
			op = opCode;				// op code atildi.
			sha = shamt;				// shamt miktari atildi.
			#1 $display("--------------------------------------------------------------------\nResult : %b", alu_result);
			result = alu_result;		// outputa ALU sonucu baglandi.
			// ALU Bitti
		end else begin 
			if( opCode == 6'b000010 ) begin
				$display("\nJump instruction");
			end else begin
				registerFileModul.registers[31] = PC[10:0] + 4;
				$display("\nJump and Link instruction");
			end
		end
	#5;
		// Data Memory ve memtoreg baslangic.
		data_in = readPort_2; // data_in rt nin degeri atildi.
		adress = alu_result;  // alu nun sonucu adrese atildi.
		MemWriteEnable = Memwrite; 	  // memory yazma sinyali atildi. 
		MemReadEnable = Memread;	  // memory okuma sinyali atildi.
	#5;
		writeData = 32'bx; #1      // Dogru sonucu yaziyor boyle olunca 
		// hedef registera yazilmasi için yaptim.
		if( Memtoreg == 1'b1 )
			writeData = data_out;	// memtoreg 1 ise registera memoryden alinan yazilacak.
		else 
			writeData = alu_result; // memtoreg 0 ise registera aludan alinan sonuc yazilacak.
		// data memory ve memto reg son.
	#5;
		if( (Branch && zero) == 1 ) begin
			tempPC = PC + 4 + 4 * immediate;
			$display("Branch instruction: %d + 4 + 4 * %d = PC\n", PC,immediate);
		end else begin
			tempPC = PC + 4;
		end
		// Update Program Counter
		#50 if( opCode == 6'b000000 && func == 6'b001000 ) begin // JR instruction
				PC = readPort_1;
				$display("JR instruction PC = Rs Pc : %b",PC);
			end else if( Jump == 1 ) begin 	// Jump ve jumpAndLink
				PC = { tempInstruction[31:28], (tempInstruction[25:0] << 2)};
				$display("PC = { %b , %b << 2 } = %d\n", tempInstruction[31:28],tempInstruction[25:0],PC);
			end else begin // PC + 4 yada Branch adresine gider.
				PC = tempPC;
			end 
	end

endmodule

module inst_mem(input [31:0] PC, output reg[31:0] instruction);
	reg [7:0] instructions [0:1023];

	always @(PC) begin
		if( PC == 1024 ) begin
			$display("1024 tane instruction alindi ve bitti\n");
			$stop(0);
		end
		instruction = { instructions[PC], instructions [PC + 1], instructions[PC + 2], instructions[PC + 3] };		
	end
	
endmodule

module decode(instruction, rs, rt, rd, shamt, opCode, func);
	input [31:0] instruction;
	output [4:0] rs, rt, rd, shamt;
	output [5:0] opCode, func;

	assign opCode = instruction[31:26];
	assign rs 	  = instruction[25:21];
	assign rt     = instruction[20:16];
	assign rd     = instruction[15:11];
	assign shamt  = instruction[10:6];
	assign func   = instruction[5:0];

endmodule	

module control(opCode, Regdest, Regwrite, Alusrc, Jump, Memwrite, Memtoreg, Memread, Branch);
	output Regdest, Regwrite, Alusrc, Jump, Memwrite, Memtoreg, Memread, Branch;
	input [5:0] opCode;
	
	assign Jump = (opCode == 6'b000010 || opCode == 6'b000011 ) ? 1'b1 : 1'b0;
	assign Regdest = (opCode == 6'b000000 ) ? 1'b1 : 1'b0;
	
	assign Regwrite = (opCode != 6'b000010 && opCode != 6'b000011 && opCode != 6'b101011 &&
	 		opCode != 6'b101000 && opCode != 6'b000100 && opCode != 6'b000101 ) ? 1'b1 : 1'b0 ;
	
	assign Alusrc = (opCode == 6'b000010 || opCode == 6'b000011 || opCode == 6'b000101 ||
			opCode == 6'b000100 || opCode == 6'b000000 ) ? 1'b0 : 1'b1;
	
	assign Memwrite = (opCode == 6'b101011 || opCode == 6'b101000) ? 1'b1: 1'b0;
	
	assign Memtoreg = (opCode == 6'b100011 || opCode == 6'b100000 || opCode == 6'b101011 || 
		    opCode == 6'b101000 || opCode == 6'b000100 || opCode == 6'b000101) ? 1'b1 : 1'b0;
	
	assign Memread = (opCode == 6'b100011 || opCode == 6'b100000) ? 1'b1: 1'b0;
	assign Branch = (opCode == 6'b000100 || opCode == 6'b000101) ? 1'b1 : 1'b0;

endmodule

module selectDest(dest, select_1, select_2, writeRegister);
	input dest;
	input [4:0] select_1, select_2;
	output [4:0] writeRegister;

	// olmadı always dene.
	assign writeRegister = (dest == 1'b1) ? select_2 : select_1;

endmodule

module registerFile(readPort_1, readPort_2, reg_1, reg_2, writeRegister, Regwrite, writeData);
	output [31:0] readPort_1;
	output [31:0] readPort_2;
	input [4:0] reg_1, reg_2, writeRegister;
	input [31:0] writeData;
	input Regwrite;

	reg [31:0] registers [0:31];

	assign readPort_1 = registers[reg_1];
	assign readPort_2 = registers[reg_2];

	always @(writeData) begin
		if( Regwrite == 1'b1 ) begin
			registers[writeRegister] = writeData;
		end
	end

endmodule

module ALU (reg1, reg2, func, op, shamt ,result, zero);
	input [31:0] reg1;
	input [31:0] reg2;
	input [5:0] func;
	input [5:0] op;
	input [4:0] shamt;
	output reg [31:0] result;
	output reg zero;

	always @(func or op) begin
		$display("--------------------------------------------------------------------");
		if( op == 6'b000000 ) begin
			if( func == 6'b100000 ) begin // add
				result = $signed(reg1) + $signed(reg2); 
				zero = 0;
				$display("**** ADD ****\nrs : %b + rt : %b", reg1, reg2);
				
			end else if( func == 6'b100100 ) begin // and
				result = $signed(reg1) & $signed(reg2); 
				zero = 0;
				$display("**** AND ****\nrs : %b & rt : %b", reg1, reg2);
			
			end else if( func == 6'b100101 ) begin // or
				result = $signed(reg1) | $signed(reg2); 
				zero = 0;
				$display("**** OR ****\nrs : %b | rt : %b", reg1, reg2);
			
			end else if( func == 6'b100010 ) begin // sub
				result = $signed(reg1) - $signed(reg2); 
				zero = 0;
				$display("**** SUB ****\nrs : %b - rt : %b", reg1, reg2);
			
			end else if( func == 6'b000011 ) begin // sra
				result = $signed(reg2 >>> shamt); 
				zero = 0;
				$display("**** SRA ****\nrt : %b >>> shamt : %b", reg2, shamt);
		
			end else if( func == 6'b000010 ) begin // srl
				result = reg2 >> shamt; 
				zero = 0;
				$display("**** SRL ****\nrt : %b >> shamt : %b", reg2, shamt);
			
			end else if( func == 6'b000000 ) begin // sll
				result = reg2 << shamt; 
				zero = 0;
				$display("**** SLL **** \nrt : %b << shamt : %b", reg2, shamt);
				
			end else if( func == 6'b101001 ) begin // sltu
				result = (reg1 < reg2); 
				zero = 0;
				$display("**** SLTU ****\nrs : %b < rt : %b", reg1, reg2);
			
			end else if( func == 6'b011010 ) begin // xor
				result = $signed(reg1) ^ $signed(reg2);
				zero = 0;
				$display("**** XOR ****\nrs : %b ^ rt : %b", reg1, reg2);
				
			end else if( func == 6'b101010 ) begin	// slt
				result = $signed(reg1) < $signed(reg2);
				zero = 0;
				$display("**** SLT ****\nrs : %b < rt : %b", reg1, reg2);
				
			end else if( func == 6'b001000 ) begin // jr yapılacak
				result = reg1;
				zero = 0;
				$display("**** JR ****\n%b", reg1);
			end
		end else begin 
			if( op == 6'b001000 ) begin // addi
				result = $signed(reg1) + $signed(reg2); 
				zero = 0; 
				$display("**** ADDI ****\nrs : %b + immediate :%b", reg1, reg2);
			
			end else if( op == 6'b001001 ) begin // addiu
				result = reg1 + reg2; 
				zero = 0;
				$display("**** ADDIU ****\nrs : %b + immediate : %b", reg1, reg2);
		
			end else if( op == 6'b001100 ) begin // andi
				result = $signed(reg1) & $signed(reg2); 	// zero extend immediate olacak
				zero = 0;
				$display("**** ANDI ****\nrs : %b & zeroExtend : %b", reg1, reg2);
			
			end else if( op == 6'b001101 ) begin // ori
				result = $signed(reg1) | $signed(reg2); 	// zero extend immediate olacak
				zero = 0;
				$display("**** ORI ****\nrs : %b | zeroExtend : %b", reg1, reg2);
			
			end else if( op == 6'b001010  ) begin // slti
				result = ($signed(reg1) < $signed(reg2)); 
				zero = 0;
				$display("**** SLTI ****\nrs : %b < immediate : %b", reg1, reg2);
			
			end else if( op == 6'b001111 ) begin // lui
				result = (reg2 << 16'b0000000000000000);
				zero = 0;
				$display("**** LUI ****\n immediate : %b << %b", reg2, 16);
			
			end else if( op == 6'b001110 ) begin // xori
				result = ($signed(reg1) ^ $signed(reg2));	// zero extend immediate olacak
				zero = 0;
				$display("**** XORI ****\nrs : %b ^ zeroExtend : %b", reg1,reg2);
			
			end else if( op == 6'b001011 ) begin // sltiu
				result = (reg1 < reg2);
				zero = 0;
				$display("**** SLTIU ****\nrs : %b < immediate : %b", reg1,reg2);
				
			end else if( op == 6'b100011 ) begin // lw
				result = (reg1 + reg2);
				zero = 0;
				$display("**** LW ****\nrs : %b immediate : %d", reg1,reg2);
				
			end else if( op == 6'b100000 ) begin // lb
				result = (reg1 + reg2);
				zero = 0;
				$display("**** LB ****\nrs : %b immediate : %d", reg1,reg2);
				
			end else if( op == 6'b101011 ) begin // sw
				result = (reg1 + reg2);
				zero = 0;
				$display("**** SW ****\nrs : %b immediate : %d", reg1,reg2);
				
			end else if( op == 6'b101000 ) begin // sb
				result = (reg1 + reg2);
				zero = 0;
				$display("**** SB ****\nrs : %b immediate : %d",reg1,reg2);
				
			end else if( op == 6'b000100 ) begin // beq
				zero = ($signed(reg1) == $signed(reg2)) ? 1'b1 : 1'b0;
				result = zero;
				$display("**** BEQ ****\nrs : %b == rt : %b", reg1,reg2);
				
			end else if( op == 6'b000101 ) begin // bne
				zero = ($signed(reg1) != $signed(reg2)) ? 1'b1 : 0'b0;
				result = zero;
				$display("**** BNE ****\nrs : %b != rt : %b", reg1,reg2);
			end 
		end
	end
	
endmodule

module data_memory(readData, adress, writeData, Memwrite, Memread, byteCode);
	output reg [31:0] readData;
	input [31:0] adress;
	input [31:0] writeData;
	input Memwrite;
	input Memread;
	input [5:0] byteCode;
	reg [7:0] memories [0:2047];

	always @(Memwrite or Memread or readData or adress) begin
		if( Memwrite == 1'b1 && Memread == 1'b0 ) begin
			if( byteCode == 6'b101000 ) begin
				memories[adress[10:0] + 3] = writeData[7:0];	
			end else begin
				memories[adress[10:0]] = writeData[31:24];
				memories[adress[10:0] + 1] = writeData[23:16];
				memories[adress[10:0] + 2] = writeData[15:8];
				memories[adress[10:0] + 3] = writeData[7:0];	
			end
		end else if( Memread == 1'b1 && Memwrite == 1'b0 ) begin
			if( byteCode == 6'b100000 ) begin
				readData = memories[adress[10:0] + 3];
			end else begin
				readData = { memories[adress[10:0]], memories[adress[10:0] + 1], memories[adress[10:0] + 2], memories[adress[10:0] + 3] };
			end
		end 
	end

endmodule