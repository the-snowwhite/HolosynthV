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
    input wire [AUD_BIT_DEPTH-1:0] lsound_fifo,
    input wire [AUD_BIT_DEPTH-1:0] rsound_fifo,
    input wire xxxx_top,
    input wire lrck,
    input wire run,
    output reg  [31:0] dataout,
    output wire l_read,
    output wire r_read,
    output wire sample_ready,
    output wire trig,
    output reg  i2s_enable
);
    
//    reg read_dly;
    reg jack_read_act;
    reg jack_read_act_dly;
    reg [FIFO_WIDTH:0] counter;
    reg [FIFO_WIDTH:0] buffersize;
    reg fill_fifo, run_trig;
    wire jack_cycle_end;
    wire lrck_synced,run_synced;
 
    syncro_2 sync_lrck (
        .clk(clk),
        .sig_in(lrck),
        .sig_out(lrck_synced)
    );
 
    syncro_2 sync_run (
        .clk(clk),
        .sig_in(run),
        .sig_out(run_synced)
    );
 
    assign l_read = (read && (address == 0)) ? 1'b1 : 1'b0;
    assign r_read = (read && (address == 1)) ? 1'b1 : 1'b0;
    
    assign jack_cycle_end = (jack_read_act_dly && !jack_read_act) ? 1'b1 : 1'b0;

    assign trig = (buffersize == 0) ? lrck_synced : run_trig;
 
    assign sample_ready = 1'b1;
    
    initial dataout = 0;

    always @(posedge clk) begin
       i2s_enable <= (buffersize == 0) ? 1'b1 : 1'b0;
    end
    
    always @(posedge clk) begin
        if (read) begin
            if (address == 3'b000) dataout[31:32-AUD_BIT_DEPTH] <= lsound_fifo;
            else if (address == 3'b001) dataout[31:32-AUD_BIT_DEPTH] <= rsound_fifo;
        end    
    end
 
    always @(posedge clk) begin
        jack_read_act_dly <= jack_read_act;
        if (write) begin
            if (address == 3'b010) jack_read_act <= datain[0];
            else if (address == 3'b011) buffersize <= datain[FIFO_WIDTH:0];
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
        if(xxxx_top && fill_fifo && !run_synced) run_trig <= 1'b1;
        else run_trig <= 1'b0;
    end

endmodule
