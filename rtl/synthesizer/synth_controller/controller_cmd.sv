`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/27/2020 12:38:49 PM
// Design Name: 
// Module Name: controller_cmd_inst
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


module controller_cmd_inst(
    input wire          reg_clk,
    input wire          trig_seq_f,
    input wire          is_st_pitch,
    input wire          is_st_prg_change,
    input wire          is_velocity,
    input wire          is_data_byte,
    input wire [7:0]    seq_databyte,
// controller data
    output reg          pitch_cmd,
    output reg          prg_ch_cmd,
    output reg [7:0]    octrl,
    output reg [7:0]    octrl_data,
    output reg [7:0]    prg_ch_data
    );
    
    initial begin
        pitch_cmd = 1'b0;
        prg_ch_cmd =1'b0;
    end

    always @(posedge reg_clk) begin
        if (trig_seq_f) begin
            if(is_st_pitch)begin // Control Change omni
                if(is_data_byte)begin
                    octrl<=seq_databyte;
                    pitch_cmd<=1'b1;
                end
                else if(is_velocity)begin
                    octrl_data<=seq_databyte;
                    pitch_cmd<=1'b0;
                end
            end else pitch_cmd <= 1'b0;
        end
//        else pitch_cmd <= 1'b0;
    end


    always @(posedge reg_clk) begin
        if (trig_seq_f) begin
            if(is_st_prg_change)begin // Control Change omni
                    prg_ch_cmd <= 1'b1;
                if(is_data_byte)begin
                    prg_ch_data<=seq_databyte;
                    prg_ch_cmd <= 1'b0;
                end
            end
            else prg_ch_cmd <=1'b0; 
        end
 //       else prg_ch_cmd <=1'b0;
    end
   
    
    
    
endmodule
