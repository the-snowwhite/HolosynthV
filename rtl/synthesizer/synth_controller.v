module synth_controller(
    input                       reset_reg_N,
    input                       CLOCK_25,
// cpu:
    input [2:0]                 socmidi_addr,
    input [7:0]                 socmidi_data_out,
//    input                       cpu_com_sel,
    input                       socmidi_write,
// uart:
    input                       midi_rxd,
    output                      midi_txd,
// inputs from synth engine
    input [VOICES-1:0]          voice_free,
    input [3:0]                 midi_ch,
// outputs to synth_engine
    output [VOICES-1:0]         keys_on,
// note events
    output                      note_on,
    output  [V_WIDTH-1:0]       cur_key_adr,
    output  [7:0]               cur_key_val,
    output  [7:0]               cur_vel_on,
    output  [7:0]               cur_vel_off,
// controller data
//    output reg                   octrl_cmd,
    output reg                  prg_ch_cmd,
    output reg                  pitch_cmd,
    output reg [7:0]            octrl,
    output reg [7:0]            octrl_data,
    output reg [7:0]            prg_ch_data,
//synth memory controller
    output                      data_ready,
    output                      read_write,
    output                      sysex_data_patch_send,
    output [6:0]                dec_addr,
    inout  [7:0]                synth_data,
    output [6:0]                dec_sel_bus,
// status data
    output [V_WIDTH:0]          active_keys,
    input                       switch4
);

parameter VOICES = 8;
parameter V_WIDTH = 3;


//////////////key1 & key2 Assign///////////
    wire [3:0] cur_midi_ch;
    wire [7:0] midi_bytes;
    wire signed [7:0] seq_databyte;

    wire [5:0] dec_sel;

    assign dec_sel_bus = {write,read,dec_sel[5],dec_sel[3:0]};

    reg [3:0]    midi_cha_num, sysex_type;

    assign  write = (read_write && ~sysex_data_patch_send) ? 1'b1 : 1'b0;
    assign  read = (read_write && sysex_data_patch_send) ? 1'b1 : 1'b0;

//  uart:
    wire       byteready_u;
    wire [7:0] cur_status_u;
    wire [7:0] midibyte_nr_u;
    wire [7:0] midi_in_data_u;
// cpu_port
    wire       byteready_c;
    wire [7:0] cur_status_c;
    wire [7:0] midibyte_nr_c;
    wire [7:0] midi_in_data_c;
    wire       midi_out_ready;
    wire       midi_send_byte;
    wire [7:0] midi_out_data;
    wire [2:0] bank_adr;
//  midi_in_mux:
    wire       byteready;
    wire [7:0] cur_status;
    wire [7:0] midibyte_nr;
    wire [7:0] midi_in_data;
//  address_decoder
    wire    write_dataenable;
// midi_status
    wire is_cur_midi_ch;
    wire is_st_note_on;
    wire is_st_note_off;
    wire is_st_ctrl;
    wire is_st_prg_change;
    wire is_st_pitch;
    wire is_st_sysex;
// seq_trigger
    wire is_data_byte;
    wire is_velocity;  
    wire seq_trigger;  
    
    
MIDI_UART MIDI_UART_inst (
    .reset_reg_N        (reset_reg_N),      // input  reset_sig
    .CLOCK_25           (CLOCK_25),         // input  reset sig
    .midi_rxd           (midi_rxd),         // input  midi serial data in
    .midi_txd           (midi_txd),         // output midi serial data output

    .byteready          (byteready_u),      // output  byteready_sig
    .cur_status         (cur_status_u),     // output [7:0] cur_status_sig
    .midibyte_nr        (midibyte_nr_u),    // output [7:0] midibyte_nr_sig
    .midi_in_data       (midi_in_data_u),   // output [7:0] midi_data_byte_sig
    
    .midi_out_ready     (midi_out_ready),   // output midi out buffer ready
    .midi_send_byte     (midi_send_byte),   // input midi_send_byte_sig
    .midi_out_data      (midi_out_data)     // input midi_out_data_sig
);

cpu_port cpu_port_inst
(
	.reset_reg_N(reset_reg_N) ,	        // input  reset_reg_N_sig
	.CLOCK_25(CLOCK_25) ,	            // input  CLOCK_25_sig
	.socmidi_addr(socmidi_addr) ,	    // input [2:0] cpu_addr_sig
	.socmidi_data_out(socmidi_data_out) ,	// input [7:0] cpu_data_sig
//	.cpu_com_sel(cpu_com_sel) ,	        // input  cpu_com_sel_sig
	.socmidi_write(socmidi_write) ,	    // input  cpu_write_sig

	.byteready(byteready_c) ,	        // output  byteready_sig
	.cur_status(cur_status_c) ,	        // output [7:0] cur_status_sig
	.midibyte_nr(midibyte_nr_c) ,	    // output [7:0] midibyte_nr_sig
	.midi_in_data(midi_in_data_c) 	    // output [7:0] midibyte_sig
);

 
midi_in_mux midi_in_mux_inst
(    .reset_reg_N        (reset_reg_N),      // input  reset_sig
    .CLOCK_25           (CLOCK_25),         // input  reset sig

	.sel(switch4) ,	// input  sel_sig

	.byteready_u(byteready_u) ,	// input  byteready_u_sig
	.cur_status_u(cur_status_u) ,	// input [7:0] cur_status_u_sig
	.midibyte_nr_u(midibyte_nr_u) ,	// input [7:0] midibyte_nr_u_sig
	.midi_in_data_u(midi_in_data_u) ,	// input [7:0] midi_in_data_u_sig

	.byteready_c(byteready_c) ,	// input  byteready_c_sig
	.cur_status_c(cur_status_c) ,	// input [7:0] cur_status_c_sig
	.midibyte_nr_c(midibyte_nr_c) ,	// input [7:0] midibyte_nr_c_sig
	.midi_in_data_c(midi_in_data_c) ,	// input [7:0] midi_in_data_c_sig

	.byteready(byteready) ,	// output  byteready_sig
	.cur_status(cur_status) ,	// output [7:0] cur_status_sig
	.midibyte_nr(midibyte_nr) ,	// output [7:0] midibyte_nr_sig
	.midi_in_data(midi_in_data) 	// output [7:0] midi_in_data_sig
);


address_decoder adr_dec_inst (
    .CLOCK_25 ( CLOCK_25 ),
    .reset_reg_N ( reset_reg_N ),
    .data_ready ( data_ready ),
    .bank_adr ( bank_adr ),
    .out_data ( midi_out_data ),
    .read_write  ( read_write  ),
    .data_out ( synth_data ),
    .dec_sel ( dec_sel ),
    .write_dataenable ( write_dataenable )
);


midi_status midi_statusinst
(
	.cur_status(cur_status) ,	// input [6:0] cur_status_sig
	.cur_midi_ch(cur_midi_ch) ,	// input [7:0] cur_midi_ch_sig
	.is_cur_midi_ch(is_cur_midi_ch) ,	// output  is_cur_midi_ch_sig
	.is_st_note_on(is_st_note_on) ,	// output  is_st_note_on_sig
	.is_st_note_off(is_st_note_off) ,	// output  is_st_note_off_sig
	.is_st_ctrl(is_st_ctrl) ,	// output  is_st_ctrl_sig
	.is_st_prg_change(is_st_prg_change) ,	// output  is_st_prg_change_sig
	.is_st_pitch(is_st_pitch) ,	// output  is_st_pitch_sig
	.is_st_sysex(is_st_sysex) 	// output  is_st_sysex_sig
);


note_stack #(.VOICES(VOICES),.V_WIDTH(V_WIDTH)) note_stack_inst
(
	.CLOCK_25(CLOCK_25) ,	// input  CLOCK_25_sig
	.reset_reg_N(reset_reg_N) ,	// input  reset_reg_N_sig
	.voice_free(voice_free) ,	// input [VOICES-1:0] voice_free_sig
	.is_data_byte(is_data_byte) ,	// input  is_data_byte_sig
	.is_velocity(is_velocity) ,	// input  is_velocity_sig
	.is_st_note_on(is_st_note_on) ,	// input  is_st_note_on_sig
	.is_st_note_off(is_st_note_off) ,	// input  is_st_note_off_sig
	.is_st_ctrl(is_st_ctrl) ,	// input  is_st_ctrl_sig
//	.byteready(byteready) ,	// input  byteready_sig
	.byteready(seq_trigger) ,	// input  byteready_sig
	.databyte(seq_databyte) ,	// input [7:0] databyte_sig

	.active_keys(active_keys) ,	// output [V_WIDTH:0] active_keys_sig
	.note_on(note_on) ,	// output  note_on_sig
	.cur_key_adr(cur_key_adr) ,	// output [V_WIDTH-1:0] cur_key_adr_sig
	.cur_key_val(cur_key_val) ,	// output [7:0] cur_key_val_sig
	.cur_vel_on(cur_vel_on) ,	// output [7:0] cur_vel_on_sig
	.cur_vel_off(cur_vel_off) ,	// output [7:0] cur_vel_off_sig
	.keys_on(keys_on) 	// output [VOICES-1:0] keys_on_sig
);

seq_trigger seq_trigger_inst
(
	.CLOCK_25(CLOCK_25) ,	// input  CLOCK_25_sig
	.reset_reg_N(reset_reg_N) ,	// input  reset_reg_N_sig
	.midi_ch(midi_ch) ,	// input [3:0] midi_ch_sig
	.midibyte_nr(midibyte_nr) ,	// input [7:0] midibyte_nr_sig
	.is_cur_midi_ch(is_cur_midi_ch) ,	// input  is_cur_midi_ch_sig
	.is_st_sysex(is_st_sysex) ,	// input  is_st_sysex_sig
	.midi_in_data(midi_in_data) ,	// input [7:0] midi_in_data_sig
	.syx_cmd(syx_cmd) ,	// input  syx_cmd_sig
	.sysex_data_patch_send(sysex_data_patch_send) ,	// input  sysex_data_patch_send_sig
	.auto_syx_cmd(auto_syx_cmd) ,	// input  auto_syx_cmd_sig
	.byteready(byteready) ,	// input  byteready_sig
	.cur_midi_ch(cur_midi_ch) ,	// output [3:0] cur_midi_ch_sig
	.midi_bytes(midi_bytes) ,	// output [7:0] midi_bytes_sig
	.midi_send_byte(midi_send_byte) ,	// output  midi_send_byte_sig
	.data_ready(data_ready) ,	// output  data_ready_sig
	.seq_databyte(seq_databyte) ,	// output [7:0] seq_databyte_sig
	.is_data_byte(is_data_byte) ,	// output  data_ready_sig
	.is_velocity(is_velocity) ,	// output  data_ready_sig
	.seq_trigger(seq_trigger) 	// output  seq_trigger_sig
);

sysex_func sysex_func_inst
(
	.reset_reg_N(reset_reg_N) ,	// input  reset_reg_N_sig
    .write_dataenable ( write_dataenable ),
	.synth_data(synth_data) ,	// input [7:0] data_sig
	.midi_ch(midi_ch) ,	// input [3:0] midi_ch_sig
	.is_st_sysex(is_st_sysex) ,	// input  is_st_sysex_sig
	.midi_out_ready(midi_out_ready) ,	// input  midi_out_ready_sig
	.midi_bytes(midi_bytes) ,	// input [7:0] midi_bytes_sig
	.databyte(seq_databyte) ,	// input [7:0] databyte_sig
	.seq_trigger(seq_trigger) ,	// input  seq_trigger_sig
	.syx_cmd(syx_cmd) ,	// output  syx_cmd_sig
	.sysex_data_patch_send(sysex_data_patch_send) ,	// output  sysex_data_patch_send_sig
	.auto_syx_cmd(auto_syx_cmd) ,	// output  auto_syx_cmd_sig
	.midi_out_data(midi_out_data) ,	// output [7:0] midi_out_data_sig
	.bank_adr(bank_adr) ,	// output [2:0] bank_adr_sig
	.dec_addr(dec_addr) 	// output [6:0] dec_addr_sig
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
