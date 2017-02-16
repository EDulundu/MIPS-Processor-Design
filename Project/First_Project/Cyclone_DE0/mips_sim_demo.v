// Copyright (C) 1991-2013 Altera Corporation
// Your use of Altera Corporation's design tools, logic functions 
// and other software and tools, and its AMPP partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License 
// Subscription Agreement, Altera MegaCore Function License 
// Agreement, or other applicable license agreement, including, 
// without limitation, that your use is for the sole purpose of 
// programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the 
// applicable agreement for further details.

// SAFA EMRE DULUNDU
//	
//	131044044
//
//	PROJECT 3 DE0
//	
//	COMPUTER ORGANIZATION
module mips_sim_demo
(
// {ALTERA_ARGS_BEGIN} DO NOT REMOVE THIS LINE!

	result_part_selector,
	ssd_part1,
	ssd_part2,
	ssd_part3,
	ssd_part4,
	toggle_sw
// {ALTERA_ARGS_END} DO NOT REMOVE THIS LINE!

);

// {ALTERA_IO_BEGIN} DO NOT REMOVE THIS LINE!
input			result_part_selector;
output	[6:0]	ssd_part1;
output	[6:0]	ssd_part2;
output	[6:0]	ssd_part3;
output	[6:0]	ssd_part4;
input	[3:0]	toggle_sw;

	mips_sim simulator(ssd_part4, ssd_part3, ssd_part2, ssd_part1, toggle_sw, result_part_selector);

// {ALTERA_IO_END} DO NOT REMOVE THIS LINE!
// {ALTERA_MODULE_BEGIN} DO NOT REMOVE THIS LINE!
// {ALTERA_MODULE_END} DO NOT REMOVE THIS LINE!
endmodule
