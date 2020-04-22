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


module audio_mux(
    input wire clk,
    input wire address,
    input wire read,
    input wire [23:0] lsound_in,
    input wire [23:0] rsound_in,
    output reg [31:0] dataout,
    output wire l_read,
    output wire r_read,
    output wire sample_ready
);
    
    reg read_dly;
 
    assign l_read = (read && !address) ? 1'b1 : 1'b0;
    assign r_read = (read && address) ? 1'b1 : 1'b0;

    assign sample_ready = 1'b1;
    
    initial dataout = 0;

    always @(posedge clk) begin
        read_dly <= read;
        if (read_dly) begin
            if (address) dataout[31:8] <= rsound_in;
            else dataout[31:8] <= lsound_in;
        end    
    end
    

endmodule
