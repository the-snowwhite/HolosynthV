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
parameter FIFO_WIDTH = 6
) (
    input wire clk,
    input wire [1:0] address,
    input wire read,
    input wire write,
    input wire [31:0] datain,
    input wire [23:0] lsound_in,
    input wire [23:0] rsound_in,
//    input wire [6:0] read_cnt,
//    input wire [6:0] write_cnt,
    input wire xxxx_top,
    input wire lrck,
    input wire run,
    output reg [31:0] dataout,
    output wire l_read,
    output wire r_read,
//    output reg [13:0] buffersize,
    output wire sample_ready,
//    output wire jack_cycle_start,
//    output reg jack_read_act,
//    output reg signed [6:0] fifo_diff,
    output wire trig
);
    
//    reg read_dly;
    reg jack_read_act;
    reg jack_read_act_dly;
    reg [FIFO_WIDTH:0] counter;
    reg [FIFO_WIDTH:0] buffersize;
    reg fill_fifo, run_trig;
    wire jack_cycle_end;
 
    assign l_read = (read && (address == 0)) ? 1'b1 : 1'b0;
    assign r_read = (read && (address == 1)) ? 1'b1 : 1'b0;
    
//    assign jack_cycle_start = (!jack_read_act_dly && jack_read_act) ? 1'b1 : 1'b0;
    assign jack_cycle_end = (jack_read_act_dly && !jack_read_act) ? 1'b1 : 1'b0;

    assign trig = (buffersize == 0) ? lrck : run_trig;

    assign sample_ready = 1'b1;
    
    initial dataout = 0;

    always @(posedge clk) begin
//        read_dly <= read;
        if (read) begin
            if (address == 2'b00) dataout[31:8] <= lsound_in;
            else if (address == 2'b01) dataout[31:8] <= rsound_in;
        end    
    end
 
    always @(posedge clk) begin
        jack_read_act_dly <= jack_read_act;
        if (write) begin
            if (address == 2'b10) jack_read_act <= datain[0];
            else if (address == 2'b11) buffersize <= datain[FIFO_WIDTH:0];
        end    
    end
/*    
    always @(posedge clk)begin
        if(jack_cycle_start) fifo_diff <= write_cnt - read_cnt;
    end
*/   
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
endmodule
