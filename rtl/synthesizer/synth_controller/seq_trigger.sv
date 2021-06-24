module seq_trigger (
    input wire                  reg_clk,
    input wire                  byteready,
    input wire  [7:0]           midibyte_nr,
    input wire  [7:0]           midi_in_data,
    input wire                  is_cur_midi_ch,
    input wire                  is_st_sysex,
    input wire                  syx_cmd,
    input wire                  dec_sysex_data_patch_send,
    input wire                  auto_syx_cmd,
    output reg  [7:0]           midi_bytes,
    output wire                 midi_send_byte,
    output reg                  syx_data_ready,
    output reg [7:0]            seq_databyte,
    output reg                  is_data_byte,
    output reg                  is_velocity,
    output reg                  trig_seq_f,
    output reg                  trig__note_stack
);

    reg seq_trigger_r_dly[3:0], syx_cmd_r[1:0];
    reg midi_send_byte_req[3];
    reg trig_seq;
    wire trig_seq_falling;
    wire is_a_data_byte;
    wire is_vel;
    
    initial begin
        trig_seq = 1'b0 ;
        trig_seq_f = 1'b0 ;
        seq_trigger_r_dly = '{default:0};
        midi_bytes = 8'h00;
        seq_databyte = 8'h00;
        midi_send_byte_req = '{default:0};
    end

    assign trig_seq_falling = (!trig_seq && seq_trigger_r_dly[0]) ? 1'b1 : 1'b0;

    assign is_a_data_byte = (midi_bytes[0]==1'b1) ? 1'b1 : 1'b0;

    assign is_vel = ((midi_bytes[0]==1'b0 && midi_bytes != 8'h0)?1'b1:1'b0);

    assign midi_send_byte = (midi_send_byte_req[1] && ~midi_send_byte_req[2]) ? 1'b1 : 1'b0;

//    assign trig__note_stack   = (seq_trigger_r_dly[2] & ~seq_trigger_r_dly[3]) ? 1'b1 : 1'b0;

    always @(posedge reg_clk)begin
        syx_cmd_r[0] <= syx_cmd;
        syx_cmd_r[1] <= syx_cmd_r[0];
        syx_data_ready   <= (syx_cmd_r[0] & ~syx_cmd_r[1]) | ((dec_sysex_data_patch_send | auto_syx_cmd) & (seq_trigger_r_dly[1] & ~seq_trigger_r_dly[2]));
        is_data_byte <= is_a_data_byte;
        is_velocity <= is_vel;
    end

//    always @(negedge reset_reg_N or posedge reg_clk)begin
    always @(posedge reg_clk)begin
        trig_seq_f <= trig_seq_falling;
        trig_seq <= (is_cur_midi_ch | is_st_sysex) ? (byteready | midi_send_byte) : 1'b0 ;
        seq_trigger_r_dly[0] <= trig_seq;
        seq_trigger_r_dly[1] <= seq_trigger_r_dly[0];
        seq_trigger_r_dly[2] <= seq_trigger_r_dly[1];
        seq_trigger_r_dly[3] <= seq_trigger_r_dly[2];
        trig__note_stack   <= (seq_trigger_r_dly[2] & ~seq_trigger_r_dly[3]) ? 1'b1 : 1'b0;
        midi_bytes <= (is_cur_midi_ch | is_st_sysex) ? midibyte_nr : 8'h00;
        seq_databyte <= (is_cur_midi_ch | is_st_sysex) ? midi_in_data : 8'h00;
        midi_send_byte_req[0] <= ( dec_sysex_data_patch_send && trig_seq ) ? 1'b1 : 1'b0;
        midi_send_byte_req[1] <= midi_send_byte_req[0];
        midi_send_byte_req[2] <= midi_send_byte_req[1];
    end


endmodule
