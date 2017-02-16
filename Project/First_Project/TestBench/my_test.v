module my_test;

  // SAFA EMRE DULUNDU 
  // 131044044
  // PROJECT 3 TEST 
	// Dosya okuma parametreleri.
	parameter bit_size = 32;
	parameter reg_size = 32;
	reg [bit_size-1:0] reg_array [0:reg_size-1];

	// Input instruction test icin.
	reg [31:0] input_instruction = 32'b00110100010000100001100001100010;

	// Control sinyalleri parametreleri.
	wire Regdest, Regwrite, ALUsrc;

	// testbench sonucu.
	wire [31:0] testbench_result;

	// Rs, Rt, Rd, writeReg adress.
	reg [31:0] rs;
	reg [31:0] rt;
	reg [31:0] rd;

	// Dosya okundu.
	initial begin
		$readmemh("registers.h", reg_array);
	end

	// Register contentleri ekrana basildi.
	integer i;
	initial begin
		$display("Registerlar");
		for(i = 0; i < reg_size; i=i+1)
			$display("%d : %b", i, reg_array[i]);
	end

	// Control sinyalleri belirlenir.
	control ctrl(input_instruction[31:26], Regdest, Regwrite, ALUsrc);

	// R-type ise rs ve rt nin contentlerini aldik. 
	// I-type ise sadece rs in contentlerini aldik.
	always @(Regdest or ALUsrc) begin
		if( Regdest == 1 && ALUsrc == 0 ) begin
			rs = reg_array[input_instruction[25:21]];
			rt = reg_array[input_instruction[20:16]];
		end else begin
			rs = reg_array[input_instruction[25:21]];
		end
	end

	// mips_core_testbench cagirilir ve ALU yapilir.
	mips_core_testbench bench(testbench_result, input_instruction, rs, rt);
	
	// Hedef register zero olamaz. Engellenir yaz?lmas?.
	// Hedef registera yazilir.
	always @(Regwrite or Regdest or testbench_result) begin
		if(Regdest == 1 && Regwrite == 1) begin
			if( input_instruction[15:11] == 0 ) begin
				 $display("!!!! Destionation $zero olamaz !!!!\n\n");
				 $stop;
			end else if( input_instruction[15:11] == 26 | input_instruction[15:11] == 27 ) begin
			   $display("!!!! $k0 $k1 olamaz OS kullanir !!!!\n\n");
				 $stop;
			end else begin
			   rd = testbench_result;
			   reg_array[input_instruction[15:11]] = testbench_result;
			   $writememh("registers.h", reg_array);
			end
		end else begin
		   if( input_instruction[20:16] == 0 ) begin
				 $display("!!!! Destionation $zero olamaz !!!!\n\n");
			   $stop;
			 end else if( input_instruction[20:16] == 26 | input_instruction[20:16] == 27 ) begin
			   $display("!!!! $k0 $k1 olamaz OS kullanir !!!!\n\n");
				 $stop;
			 end else begin
			   reg_array[input_instruction[20:16]] = testbench_result;
			   $writememh("registers.h", reg_array);
			 end
		end
	end	
	
endmodule
