//
// Safa Emre Dulundu
// 131044044
// CSE 331 COMPUTER ORGANIZATION
//
module TestBench;
	wire [31:0] TestBenchResult;

	// Lutfen delayleri degistirmeyin.
	MIPS x86(.result(TestBenchResult));

	// Onemli . dot operatoru ile testbenchten register file , instruction ve data memory deki belleklerimi readmemh ile okuyup doldurabiliyorum.
	// Yeni kesfettim bunu :)
	// t = 0 aninda dosyalar okunur ve ilk halleri dosyaya yazilir.
	initial begin
		$readmemh("instruction_memory.h", x86.instr_mod.instructions);
		$readmemh("registers.h", x86.registerFileModul.registers);
		$readmemh("data_memory.h", x86.dataModul.memories);
	#1;	// Bunu daha okumadan yazmasın diye koydum. ilk degerler yazilir.
		$writememh("startInstruction.txt", x86.instr_mod.instructions);
		$writememh("startRegisters.txt", x86.registerFileModul.registers);
		$writememh("startMemory.txt", x86.dataModul.memories);
	end

	// t = 0 aninda 0 atandi.
	initial begin
		x86.LOOP = 0; 	// Initial value.
	end

	// 50 birim zaman sonra degisince x86 icerisindeki always blogu aktif olur ve calismaya baslar.
	always begin
		if( x86.PC == 84 ) begin	// Buraya calisilacak PC sayisi yazilir ona gore sonlandirilir. eger 1024 olursa yine sonlanir
			$writememh("resultInstruction.txt", x86.instr_mod.instructions);
			$writememh("resultRegisters.txt", x86.registerFileModul.registers);
			$writememh("resultMemory.txt", x86.dataModul.memories);
			$stop(0);
		end
		#50 x86.LOOP = ~x86.LOOP;	// Burası 50 oldugunda tek tek calistiriyor genellikle o yuzden 50 yapildi.
		$writememh("resultInstruction.txt", x86.instr_mod.instructions);
		$writememh("resultRegisters.txt", x86.registerFileModul.registers);
		$writememh("resultMemory.txt", x86.dataModul.memories);
		// Bir instruction calistiktan sonraki deger yazilir.
	end

endmodule