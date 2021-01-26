`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/22/2021 01:27:38 AM
// Design Name: 
// Module Name: sync
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


module sync(
    input clk,
    input d,
    output reg q
    );
    
reg n1;

 always @(posedge clk)

 begin

 n1 <= d; // nonblocking

 q <= n1; // nonblocking

 end    
endmodule
