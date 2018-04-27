module midi_status (
    input   [7:0]   cur_status,
    input   [3:0]   cur_midi_ch,
    output          is_cur_midi_ch,
    output          is_st_note_on,
    output          is_st_note_off,
    output          is_st_ctrl,
    output          is_st_prg_change,
    output          is_st_pitch,
    output          is_st_sysex
);


    assign is_cur_midi_ch   =   ((cur_status[3:0]==cur_midi_ch)?1'b1:1'b0);
    assign is_st_note_off   =   ((cur_status[7:4]==4'h8)?1'b1:1'b0);
    assign is_st_note_on    =   ((cur_status[7:4]==4'h9)?1'b1:1'b0);
    assign is_st_ctrl       =   ((cur_status[7:4]==4'hb)?1'b1:1'b0);
    assign is_st_prg_change =   ((cur_status[7:4]==4'hc)?1'b1:1'b0);
    assign is_st_pitch      =   ((cur_status[7:4]==4'he)?1'b1:1'b0);
    assign is_st_sysex      =   ((cur_status[7:4]==4'hf)?1'b1:1'b0);

endmodule