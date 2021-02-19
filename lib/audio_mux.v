`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/22/2020 01:11:22 PM
// Design Name: 
// Module Name: audio_mux
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module audio_mux #(
parameter FIFO_WIDTH = 6,
parameter AUD_BIT_DEPTH = 24
) (
    input wire clk,
    input wire [2:0] address,
    input wire read,
    input wire write,
    input wire [31:0] datain,
    input wire [AUD_BIT_DEPTH-1:0] lsound_in,
    input wire [AUD_BIT_DEPTH-1:0] rsound_in,
    input wire xxxx_top,
    input wire lrck,
    input wire run,
    output reg [31:0] dataout,
    output wire l_read,
    output wire r_read,
    output wire sample_ready,
    output wire trig,
    output wire i2s_enable,
    output reg samplerate_is_48
//    output wire byteready_cpu,
//    output wire [7:0] cur_status_cpu,
//    output wire [7:0] midibyte_nr_cpu,
//    output wire [7:0] midi_in_data_cpu
);
    
//    reg read_dly;
    reg jack_read_act;
    reg jack_read_act_dly;
    reg [FIFO_WIDTH:0] counter;
    reg [FIFO_WIDTH:0] buffersize;
    reg fill_fifo, run_trig;
    wire jack_cycle_end;
    wire lrck_synced;

    reg [31:0]  samplerate;
    (* ASYNC_REG = "TRUE" *) reg sig_buffer0_0, sig_buffer1_0;
 
    always @(posedge clk) begin
        sig_buffer0_0 <= lrck;
        sig_buffer1_0 <= sig_buffer0_0;
    end
    assign lrck_synced = sig_buffer1_0;
                 

 
    assign l_read = (read && (address == 0)) ? 1'b1 : 1'b0;
    assign r_read = (read && (address == 1)) ? 1'b1 : 1'b0;
    
//    assign jack_cycle_start = (!jack_read_act_dly && jack_read_act) ? 1'b1 : 1'b0;
    assign jack_cycle_end = (jack_read_act_dly && !jack_read_act) ? 1'b1 : 1'b0;

    assign trig = (buffersize == 0) ? lrck_synced : run_trig;
    assign i2s_enable = (buffersize == 0) ? 1'b1 : 1'b0;

    assign sample_ready = 1'b1;
    
    initial dataout = 0;

    always @(posedge clk) begin
//        read_dly <= read;
        if (read) begin
            if (address == 3'b000) dataout[31:8] <= lsound_in;
            else if (address == 3'b001) dataout[31:32-AUD_BIT_DEPTH] <= rsound_in;
        end    
    end
 
    always @(posedge clk) begin
        jack_read_act_dly <= jack_read_act;
        if (write) begin
            if (address == 3'b010) jack_read_act <= datain[0];
            else if (address == 3'b011) buffersize <= datain[FIFO_WIDTH:0];
            else if (address == 3'b100) samplerate <= datain;
        end    
    end
    
    always @(posedge clk)begin
        if (samplerate == 32'd48000) begin
            samplerate_is_48 <= 1'b1;
        end else begin
            samplerate_is_48 <= 1'b0;
        end
    end
   
    always @(posedge clk) begin
        if(jack_cycle_end) counter <= 0;
        else if (counter < buffersize) begin 
            fill_fifo <= 1'b1; 
            if (run_trig) counter <= counter + 1;
        end
        else fill_fifo <= 1'b0; 
    end
    
    always @(posedge clk)begin
        if(xxxx_top && fill_fifo && !run) run_trig <= 1'b1;
        else run_trig <= 1'b0;
    end
/*
cpu_port #(.addr(5))cpu_midi_port_inst
(
	.reset_reg_N( 1'b1 ) ,
	.reg_clk( clk ) ,
	.socmidi_addr( address ) ,	    // input [2:0] cpu_addr_sig
	.socmidi_data_in( datain[7:0] ) ,	// input [7:0] cpu_data_sig
	.socmidi_write( write ) ,	    // input  cpu_write_sig

	.byteready_c( byteready_cpu ) ,	        // output  byteready_sig
	.cur_status_c( cur_status_cpu ) ,	        // output [7:0] cur_status_sig
	.midibyte_nr_c( midibyte_nr_cpu ) ,	    // output [7:0] midibyte_nr_sig
	.midi_in_data_c( midi_in_data_cpu ) 	    // output [7:0] midibyte_sig
);
*/
endmodule
