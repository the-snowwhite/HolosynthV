module midi_status (
    input wire          reg_clk,
    input wire  [7:0]   cur_status,
    input wire  [4:0]   cur_midi_ch,
    output reg          is_cur_midi_ch,
    output reg          is_st_note_on,
    output reg          is_st_note_off,
    output reg          is_st_ctrl,
    output reg          is_st_prg_change,
    output reg          is_st_pitch,
    output reg          is_st_sysex
);

    initial begin
        is_cur_midi_ch = 1'b0;
        is_st_note_on = 1'b0;
        is_st_note_off = 1'b0;
        is_st_ctrl = 1'b0;
        is_st_prg_change = 1'b0;
        is_st_pitch = 1'b0;
        is_st_sysex = 1'b0;
    end
    reg [3:0] cur_midi_ch_r;
    reg [7:0] cur_status_r;
/*
    wire st_cur_midi_ch;
    wire st_note_on;
    wire st_note_off;
    wire st_ctrl;
    wire st_prg_change;
    wire st_pitch;
    wire st_sysex;

    assign st_cur_midi_ch =   ((cur_status[3:0]==cur_midi_ch)?1'b1:1'b0);
    assign st_note_on     =   ((cur_status[7:4]==4'h9)?1'b1:1'b0);
    assign st_note_off    =   ((cur_status[7:4]==4'h8)?1'b1:1'b0);
    assign st_ctrl        =   ((cur_status[7:4]==4'hb)?1'b1:1'b0);
    assign st_prg_change  =   ((cur_status[7:4]==4'hc)?1'b1:1'b0);
    assign st_pitch       =   ((cur_status[7:4]==4'he)?1'b1:1'b0);
    assign st_sysex       =   ((cur_status[7:4]==4'hf)?1'b1:1'b0);
*/
    always @(posedge reg_clk) begin
        cur_midi_ch_r    <= cur_midi_ch[3:0];
        cur_status_r     <= cur_status;
        is_cur_midi_ch   <= ((cur_status_r[3:0]==cur_midi_ch_r)?1'b1:1'b0);
        is_st_note_on    <= ((cur_status_r[7:4]==4'h9)?1'b1:1'b0);
        is_st_note_off   <= ((cur_status_r[7:4]==4'h8)?1'b1:1'b0);
        is_st_ctrl       <= ((cur_status_r[7:4]==4'hb)?1'b1:1'b0);
        is_st_prg_change <= ((cur_status_r[7:4]==4'hc)?1'b1:1'b0);
        is_st_pitch      <= ((cur_status_r[7:4]==4'he)?1'b1:1'b0);
        is_st_sysex      <= ((cur_status_r[7:4]==4'hf)?1'b1:1'b0);
    end

endmodule
