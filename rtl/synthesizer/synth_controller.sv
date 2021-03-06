module synth_controller #(
parameter VOICES = 32,
parameter V_WIDTH = utils::clogb2(VOICES),
parameter Invert_rxd = 0,
parameter REG_CLK_FREQUENCY = 50_000_000
) (
    input wire                  reg_clk,
// cpu:
    input wire [2:0]            socmidi_addr,
    input wire [7:0]            socmidi_data_in,
    input wire                  socmidi_write,
// uart:
    input wire                  midi_rxd,
    output wire                 midi_txd,
// inputs from synth engine
    input wire [VOICES-1:0]     voice_free,
    input wire [4:0]            cur_midi_ch,
// note events
    output wire                 note_on,
    output wire [V_WIDTH-1:0]   cur_key_adr,
    output wire [7:0]           cur_key_val,
    output wire [7:0]           cur_vel_on,
    output wire [7:0]           cur_vel_off,
// outputs to synth_engine
    output wire [VOICES-1:0]    keys_on,
// controller data
    output wire                 prg_ch_cmd,
    output wire [13:0]          pitch_val,
    output wire [7:0]           prg_ch_data,
//synth memory controller
    output wire                 syx_data_ready,
    output wire                 write_dataenable,
    output wire [6:0]           syx_dec_addr,
    output wire [2:0]           syx_bank_addr,
    output wire                 syx_read,
    output wire                 syx_write,
    output wire [7:0]           sysex_data_out,
    input  wire [7:0]           synth_data_out,
//    output wire [6:0]           dec_sel_bus,
// status data
    output wire [V_WIDTH:0]   active_keys // has to go upto 32
);

//////////////key1 & key2 Assign///////////
    wire [7:0] midi_bytes;
    wire signed [7:0] seq_databyte;

    wire [5:0] dec_sel;

    reg [3:0]    midi_cha_num, sysex_type;

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
//    wire [2:0] syx_bank_addr;
//  midi_in_mux:
    wire       byteready;
    wire [7:0] cur_status;
    wire [7:0] midibyte_nr;
    wire [7:0] midi_in_data;
//  address_decoder
//    wire    write_dataenable;
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
    wire trig_seq_f;
    wire [7:0] midi_regdata_to_synth;
    wire dec_sysex_data_patch_send;

    wire      pitch_cmd;
    wire [7:0] octrl;
    wire [7:0] octrl_data;

    wire      trig__note_stack;

MIDI_UART #(.Invert_rxd(Invert_rxd),.REG_CLK_FREQUENCY(REG_CLK_FREQUENCY)) MIDI_UART_inst
(
    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 reg_clk CLK" *)
    .reg_clk        (reg_clk),
    .midi_rxd       (midi_rxd),         // input  midi serial data in
    .midi_txd       (midi_txd),         // output midi serial data output

    .byteready_u    (byteready_u),      // output  byteready_sig
    .cur_status_u   (cur_status_u),     // output [7:0] cur_status_sig
    .midibyte_nr_u  (midibyte_nr_u),    // output [7:0] midibyte_nr_sig
    .midi_in_data_u (midi_in_data_u),   // output [7:0] midi_data_byte_sig

    .midi_out_ready (midi_out_ready),   // output midi out buffer ready
    .midi_send_byte (midi_send_byte),   // input midi_send_byte_sig
    .midi_out_data  (midi_out_data)     // input midi_out_data_sig
);

cpu_port cpu_port_inst
(
	.reg_clk( reg_clk ) ,
	.socmidi_addr( socmidi_addr ) ,	    // input [2:0] cpu_addr_sig
	.socmidi_data_in( socmidi_data_in ) ,	// input [7:0] cpu_data_sig
	.socmidi_write( socmidi_write ) ,	    // input  cpu_write_sig

	.byteready_c( byteready_c ) ,	        // output  byteready_sig
	.cur_status_c( cur_status_c ) ,	        // output [7:0] cur_status_sig
	.midibyte_nr_c( midibyte_nr_c ) ,	    // output [7:0] midibyte_nr_sig
	.midi_in_data_c( midi_in_data_c ) 	    // output [7:0] midibyte_sig
);


midi_in_mux midi_in_mux_inst
(
    .reg_clk( reg_clk ),

	.cur_midi_ch( cur_midi_ch ) ,	// input  sel_sig

	.byteready_u( byteready_u ) ,	// input  byteready_u_sig
	.cur_status_u( cur_status_u ) ,	// input [7:0] cur_status_u_sig
	.midibyte_nr_u( midibyte_nr_u ) ,	// input [7:0] midibyte_nr_u_sig
	.midi_in_data_u( midi_in_data_u ) ,	// input [7:0] midi_in_data_u_sig

	.byteready_c( byteready_c ) ,	// input  byteready_c_sig
	.cur_status_c( cur_status_c ) ,	// input [7:0] cur_status_c_sig
	.midibyte_nr_c( midibyte_nr_c ) ,	// input [7:0] midibyte_nr_c_sig
	.midi_in_data_c( midi_in_data_c ) ,	// input [7:0] midi_in_data_c_sig

	.byteready( byteready ) ,	// output  byteready_sig
	.cur_status( cur_status ) ,	// output [7:0] cur_status_sig
	.midibyte_nr( midibyte_nr ) ,	// output [7:0] midibyte_nr_sig
	.midi_in_data( midi_in_data ) 	// output [7:0] midi_in_data_sig
);


address_decoder address_decoder_inst (
    .reg_clk ( reg_clk ),
    .dec_sysex_data_patch_send ( dec_sysex_data_patch_send ),
    .syx_data_ready ( syx_data_ready ),   //input
    .syx_read  ( syx_read  ),
    .syx_write  ( syx_write  ),
    .write_dataenable ( write_dataenable )
);


midi_status midi_statusinst
(
    .reg_clk(reg_clk),
    .cur_status(cur_status),            // input [7:0] cur_status_sig
    .cur_midi_ch(cur_midi_ch),          // input [3:0] cur_midi_ch_sig
    .is_cur_midi_ch(is_cur_midi_ch),	// output  is_cur_midi_ch_sig
    .is_st_note_on(is_st_note_on),	    // output  is_st_note_on_sig
    .is_st_note_off(is_st_note_off),	// output  is_st_note_off_sig
    .is_st_ctrl(is_st_ctrl),	        // output  is_st_ctrl_sig
    .is_st_prg_change(is_st_prg_change),// output  is_st_prg_change_sig
    .is_st_pitch(is_st_pitch),          // output  is_st_pitch_sig
    .is_st_sysex(is_st_sysex)           // output  is_st_sysex_sig
);


note_stack #(.VOICES(VOICES),.V_WIDTH(V_WIDTH)) note_stack_inst
(
	.reg_clk(reg_clk) ,
	.voice_free(voice_free) ,	// input [VOICES-1:0] voice_free_sig
	.is_data_byte(is_data_byte) ,	// input  is_data_byte_sig
	.is_velocity(is_velocity) ,	// input  is_velocity_sig
	.is_st_note_on(is_st_note_on) ,	// input  is_st_note_on_sig
	.is_st_note_off(is_st_note_off) ,	// input  is_st_note_off_sig
	.is_st_ctrl(is_st_ctrl) ,	// input  is_st_ctrl_sig
	.trig__note_stack(trig__note_stack) ,	// input  byteready_sig
	.seq_databyte(seq_databyte) ,	// input [7:0] databyte_sig

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
	.reg_clk(reg_clk) ,
	.midibyte_nr(midibyte_nr) ,	// input [7:0] midibyte_nr_sig
	.is_cur_midi_ch(is_cur_midi_ch) ,	// input  is_cur_midi_ch_sig
	.is_st_sysex(is_st_sysex) ,	// input  is_st_sysex_sig
	.midi_in_data(midi_in_data) ,	// input [7:0] midi_in_data_sig
	.syx_cmd(syx_cmd) ,	// input  syx_cmd_sig
	.dec_sysex_data_patch_send(dec_sysex_data_patch_send) ,	// input  sysex_data_patch_send_sig
	.auto_syx_cmd(auto_syx_cmd) ,	// input  auto_syx_cmd_sig
	.byteready(byteready) ,	// input  byteready_sig
	.midi_bytes(midi_bytes) ,	// output [7:0] midi_bytes_sig
	.midi_send_byte(midi_send_byte) ,	// output  midi_send_byte_sig
	.syx_data_ready(syx_data_ready) ,	// output  data_ready_sig
	.seq_databyte(seq_databyte) ,	// output [7:0] seq_databyte_sig
	.is_data_byte(is_data_byte) ,	// output  data_ready_sig
	.is_velocity(is_velocity) ,	// output  data_ready_sig
	.trig_seq_f(trig_seq_f), 	// output  seq_trigger_sig
	.trig__note_stack(trig__note_stack) 	// output  trig__note_stack_sig
);

sysex_func sysex_func_inst
(
	.reg_clk(reg_clk) ,
	.sysex_data_out(sysex_data_out) ,	// output [7:0] data_sig
	.synth_data_out(synth_data_out) ,	// input [7:0] data_sig
	.cur_midi_ch(cur_midi_ch) ,	// input [3:0] midi_ch_sig
	.is_st_sysex(is_st_sysex) ,	// input  is_st_sysex_sig
	.midi_out_ready(midi_out_ready) ,	// input  midi_out_ready_sig
	.midi_bytes(midi_bytes) ,	// input [7:0] midi_bytes_sig
	.seq_databyte(seq_databyte) ,	// input [7:0] databyte_sig
	.trig_seq_f(trig_seq_f) ,	// input  seq_trigger_sig
	.syx_cmd(syx_cmd) ,	// output  syx_cmd_sig
	.dec_sysex_data_patch_send(dec_sysex_data_patch_send) ,	// output  sysex_data_patch_send_sig
	.auto_syx_cmd(auto_syx_cmd) ,	// output  auto_syx_cmd_sig
	.midi_out_data(midi_out_data) ,	// output [7:0] midi_out_data_sig
	.syx_bank_addr(syx_bank_addr) ,	// output [2:0] bank_adr_sig
	.syx_dec_addr(syx_dec_addr) 	// output [6:0] dec_addr_sig
);

controller_cmd_inst controller_cmd_inst_inst (
   // Input Ports - Single Bit
    .reg_clk             (reg_clk) ,
    .trig_seq_f          (trig_seq_f),    
    .is_data_byte        (is_data_byte),   
    .is_st_pitch         (is_st_pitch),    
    .is_st_prg_change    (is_st_prg_change),
    .is_velocity         (is_velocity),    
   // Input Ports - Busses
    .seq_databyte        (seq_databyte),
   // Output Ports - Single Bit
    .pitch_cmd           (pitch_cmd),      
    .prg_ch_cmd          (prg_ch_cmd),     
   // Output Ports - Busses
    .octrl               (octrl),     
    .octrl_data          (octrl_data),
    .prg_ch_data         (prg_ch_data)
);

rt_controllers rt_controllers_inst(
    .reg_clk        ( reg_clk ),
// from synth_controller
    .octrl          ( octrl ),
    .octrl_data     ( octrl_data ),
    .pitch_cmd      ( pitch_cmd ),
// outputs
    .pitch_val      ( pitch_val )
);


endmodule
