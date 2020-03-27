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
    input wire          seq_trigger,
    input wire          reset_reg_N,
    input wire          is_st_pitch,
    input wire          is_st_prg_change,
    input wire          is_velocity,
    input wire          is_data_byte,
    input wire [7:0]    seq_databyte,
// controller data
//    output reg                   octrl_cmd,
    output reg          pitch_cmd,
    output reg          prg_ch_cmd,
    output reg [7:0]    octrl,
    output reg [7:0]    octrl_data,
    output reg [7:0]    prg_ch_data
    );
    

    always @(negedge reset_reg_N or negedge seq_trigger) begin
        if (!reset_reg_N) begin // init values
            pitch_cmd <= 1'b0;
        end
        else begin
            pitch_cmd <= 1'b0;
            if(is_st_pitch)begin // Control Change omni
                if(is_data_byte)begin
                    octrl<=seq_databyte;
                    pitch_cmd<=1'b1;
                end
                else if(is_velocity)begin
                    octrl_data<=seq_databyte;
                    pitch_cmd<=1'b0;
                end
            end
        end
    end


    always @(negedge reset_reg_N or negedge seq_trigger) begin
        if (!reset_reg_N) begin // init values
            prg_ch_cmd <=1'b0;
        end
        else begin
            prg_ch_cmd <=1'b0;
            if(is_st_prg_change)begin // Control Change omni
                    prg_ch_cmd <= 1'b1;
                if(is_data_byte)begin
                    prg_ch_data<=seq_databyte;
                    prg_ch_cmd <= 1'b0;
                end
            end
        end
    end
   
    
    
    
endmodule
