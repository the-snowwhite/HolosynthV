// Copyright (C) 2017  Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions 
// and other software and tools, and its AMPP partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License 
// Subscription Agreement, the Intel Quartus Prime License Agreement,
// the Intel FPGA IP License Agreement, or other applicable license
// agreement, including, without limitation, that your use is for
// the sole purpose of programming logic devices manufactured by
// Intel and sold by Intel or its authorized distributors.  Please
// refer to the applicable agreement for further details.


// Generated by Quartus Prime Version 17.1 (Build Internal Build 593 12/11/2017)
// Created on Mon Jun 28 15:46:55 2021

audio_mux audio_mux_inst
(
	.clk(clk_sig) ,	// input  clk_sig
	.address(address_sig) ,	// input [2:0] address_sig
	.read(read_sig) ,	// input  read_sig
	.write(write_sig) ,	// input  write_sig
	.datain(datain_sig) ,	// input [31:0] datain_sig
	.lsound_in(lsound_in_sig) ,	// input [AUD_BIT_DEPTH-1:0] lsound_in_sig
	.rsound_in(rsound_in_sig) ,	// input [AUD_BIT_DEPTH-1:0] rsound_in_sig
	.xxxx_top(xxxx_top_sig) ,	// input  xxxx_top_sig
	.lrck(lrck_sig) ,	// input  lrck_sig
	.run(run_sig) ,	// input  run_sig
	.dataout(dataout_sig) ,	// output [31:0] dataout_sig
	.l_read(l_read_sig) ,	// output  l_read_sig
	.r_read(r_read_sig) ,	// output  r_read_sig
	.sample_ready(sample_ready_sig) ,	// output  sample_ready_sig
	.trig(trig_sig) ,	// output  trig_sig
	.i2s_enable(i2s_enable_sig) 	// output  i2s_enable_sig
);

defparam audio_mux_inst.FIFO_WIDTH = 6;
defparam audio_mux_inst.AUD_BIT_DEPTH = 24;
