module seq_trigger (
    input                       CLOCK_25,
    input                       reset_reg_N,
    input   [3:0]               midi_ch,
    input                       byteready,
    input   [7:0]               midibyte_nr,
    input   [7:0]               midi_in_data,
    input                       is_cur_midi_ch,
    input                       is_st_sysex,
    input                       syx_cmd,
    input                       sysex_data_patch_send,
    input                       auto_syx_cmd,
    output reg  [3:0]           cur_midi_ch,
    output reg  [7:0]           midi_bytes,
    output                      midi_send_byte,
    output reg                  data_ready,
    output reg [7:0]            seq_databyte,
    output                      is_data_byte,
    output                      is_velocity,
    output reg                  seq_trigger
);
    
    assign is_data_byte=(
     (midi_bytes[0]==1'b1)?1'b1:1'b0);

    assign is_velocity=((midi_bytes[0]==1'b0 && midi_bytes != 8'h0)?1'b1:1'b0);
   
    assign midi_send_byte = (midi_send_byte_req[1] && ~midi_send_byte_req[2]) ? 1'b1 : 1'b0;

    reg seq_trigger_r_dly[2:0], syx_cmd_r[1:0];   
    reg midi_send_byte_req[3];

    always @(posedge CLOCK_25)begin
        syx_cmd_r[0] <= syx_cmd;
        syx_cmd_r[1] <= syx_cmd_r[0];
        data_ready   <= (syx_cmd_r[0] & ~syx_cmd_r[1]) | ((sysex_data_patch_send | auto_syx_cmd) & (seq_trigger_r_dly[1] & ~seq_trigger_r_dly[2]));
    end

    always @(negedge reset_reg_N or posedge CLOCK_25)begin
        if (!reset_reg_N) begin
        end
        else begin
            cur_midi_ch <= midi_ch;
            seq_trigger <= (is_cur_midi_ch | is_st_sysex) ? (byteready | midi_send_byte) : 1'b0 ;
            seq_trigger_r_dly[0] <= seq_trigger;
            seq_trigger_r_dly[1] <= seq_trigger_r_dly[0];
            seq_trigger_r_dly[2] <= seq_trigger_r_dly[1];
            midi_bytes <= (is_cur_midi_ch | is_st_sysex) ? midibyte_nr : 8'h00;
            seq_databyte <= (is_cur_midi_ch | is_st_sysex) ? midi_in_data : 8'h00;
            midi_send_byte_req[0] <= ( sysex_data_patch_send && seq_trigger ) ? 1'b1 : 1'b0;
            midi_send_byte_req[1] <= midi_send_byte_req[0];
            midi_send_byte_req[2] <= midi_send_byte_req[1];
       end
    end


endmodule