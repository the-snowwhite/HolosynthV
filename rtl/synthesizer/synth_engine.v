module synth_engine (
	input						OSC_CLK,
	input						AUDIO_CLK,
//	output					AUDIO_CLK,
	input						reset_reg_N,
	input						reset_data_N,
	output					AUD_DACDAT,
	output					AUD_DACLRCK,
	output					AUD_BCLK,
// from midi_decoder
// note events
	input [VOICES-1:0]	keys_on,
	input						note_on,
	input [V_WIDTH-1:0]	cur_key_adr,
	input [7:0]				cur_key_val,
	input [7:0]				cur_vel_on,
	input [7:0]				cur_vel_off,
// midi data events
	input						write,
	input						read,
	input						sysex_data_patch_send,
	input [6:0]				adr,
	inout [7:0]				data,
	input						env_sel,
	input						osc_sel,
	input						m1_sel,
	input						m2_sel,
	input						com_sel,
// from midi_controller_unit
	input [13:0]			pitch_val,
// from env gen
	output [VOICES-1:0]	voice_free
	);	


parameter VOICES	= 8;
parameter V_OSC		= 4;				// number of oscilators pr. voice.
parameter O_ENVS	= 2;				// number of envelope generators pr. oscilator.
parameter V_ENVS	= O_ENVS * V_OSC;	// number of envelope generators  pr. voice.

parameter V_WIDTH	= 3;
parameter O_WIDTH	= 2;
parameter OE_WIDTH	= 1;
parameter E_WIDTH	= O_WIDTH + OE_WIDTH;

//-----		Wires		-----//
wire		sCLK_XVXENVS;       // ObjectKind=Net|PrimaryId=sCLK_XVXENVS
wire		sCLK_XVXOSC;        // ObjectKind=Net|PrimaryId=sCLK_XVXOSC
wire		n_xxxx_zero;            // ObjectKind=Net|PrimaryId=NetU1_xxxx_max
wire [V_WIDTH+E_WIDTH-1:0]  xxxx;                  // ObjectKind=Net|PrimaryId=NetU1_xxxx[5..0]
wire [7:0]  level_mul;        // ObjectKind=Net|PrimaryId=level_mul
wire [7:0]	level_mul_vel;

wire          byteready;              // ObjectKind=Net|PrimaryId=byteready
wire [7:0]  cur_status;             // ObjectKind=Net|PrimaryId=cur_status
wire [7:0]  octrl;               // ObjectKind=Net|PrimaryId=ictrl
wire [7:0]  octrl_data;          // ObjectKind=Net|PrimaryId=ictrl_data
wire          pitch_cmd;           // ObjectKind=Net|PrimaryId=pitch_cmd
wire [7:0]  midibyte;               // ObjectKind=Net|PrimaryId=midibyte
wire [7:0]  midibyte_nr;            // ObjectKind=Net|PrimaryId=midibyte_nr
wire [10:0] modulation;                 // ObjectKind=Net|PrimaryId=modulation
`ifdef _24BitAudio
wire [23:0] lsound_out;                 // ObjectKind=Net|PrimaryId=NetU1_rsound_out[23..0]
wire [23:0] rsound_out;                 // ObjectKind=Net|PrimaryId=NetU1_rsound_out[23..0]
`else
wire [15:0] lsound_out;                 // ObjectKind=Net|PrimaryId=NetU1_rsound_out[23..0]
wire [15:0] rsound_out;                 // ObjectKind=Net|PrimaryId=NetU1_rsound_out[23..0]
`endif
wire [16:0] sine_lut_out;                 // ObjectKind=Net|PrimaryId=sine_lut_out
wire [23:0] osc_pitch_val;      // ObjectKind=Net|PrimaryId=osc_pitch_val

wire [V_ENVS-1:0] osc_accum_zero;
wire						reg_note_on;
wire [V_WIDTH-1:0]	reg_cur_key_adr;
wire [7:0]				reg_cur_key_val;
wire [7:0]				reg_cur_vel_on;	
wire [VOICES-1:0]		reg_keys_on;

note_key_vel_sync #(.VOICES(VOICES),.V_WIDTH(V_WIDTH)) key_sync_inst
(
	.n_xxxx_zero 	(n_xxxx_zero),
	.OSC_CLK			( OSC_CLK ),  			// input
	.note_on 		(note_on),
	.cur_key_adr	(cur_key_adr),
	.cur_key_val	(cur_key_val),
	.cur_vel_on		(cur_vel_on),
	.keys_on			(keys_on),
	.reg_note_on 		(reg_note_on),
	.reg_cur_key_adr	(reg_cur_key_adr),
	.reg_cur_key_val	(reg_cur_key_val),
	.reg_cur_vel_on	(reg_cur_vel_on),
	.reg_keys_on		(reg_keys_on)
);


synth_clk_gen #(.VOICES(VOICES),.V_OSC(V_OSC),.V_ENVS(V_ENVS))synth_clk_gen_inst  // ObjectKind=Sheet Symbol|PrimaryId=U_synth_clk_gen
 (
	.reset_reg_N( reset_reg_N ),	// input
	.OSC_CLK( OSC_CLK ),  			// input
	.AUDIO_CLK( AUDIO_CLK ),      // input
	.sCLK_XVXENVS( sCLK_XVXENVS ),// output
	.sCLK_XVXOSC( sCLK_XVXOSC ),	// output
	.AUD_DACLRCK( AUD_DACLRCK ) ,			// output  AUD_DACLRCK_sig
	.oAUD_BCLK( AUD_BCLK ) 			// output  oAUD_BCLK_sig
);

audio_i2s_driver U_audio_i2s_driver                         // ObjectKind=Sheet Symbol|PrimaryId=U_audio_i2s_driver
(
	.reset_reg_N( reset_reg_N ),	// ObjectKind=Sheet Entry|PrimaryId=audio_i2s_driver.v-reset_reg_N
	.iAUD_BCLK( AUD_BCLK ),			// ObjectKind=Sheet Entry|PrimaryId=audio_i2s_driver.v-oAUD_BCLK
	.iAUD_DACLRCK( AUD_DACLRCK ),                         // ObjectKind=Sheet Entry|PrimaryId=audio_i2s_driver.v-oAUD_DACLRCK
	.i_lsound_out( lsound_out ),           // ObjectKind=Sheet Entry|PrimaryId=audio_i2s_driver.v-rsound_out[23..0]
	.i_rsound_out( rsound_out ),           // ObjectKind=Sheet Entry|PrimaryId=audio_i2s_driver.v-rsound_out[23..0]
	.oAUD_DACDAT( AUD_DACDAT ) // ObjectKind=Sheet Entry|PrimaryId=audio_i2s_driver.v-oAUD_DACDAT
);

timing_gen #(.VOICES(VOICES),.V_ENVS(V_ENVS),.V_WIDTH(V_WIDTH),.E_WIDTH(E_WIDTH))timing_gen_inst  // ObjectKind=Sheet Symbol|PrimaryId=U_timing_gen
(
	.reset_reg_N(reset_reg_N),                               // ObjectKind=Sheet Entry|PrimaryId=timing_gen.v-reset_reg_N
	.n_xxxx_zero( n_xxxx_zero ),     // ObjectKind=Sheet Entry|PrimaryId=timing_gen.v-n_xxxx_zero
	.sCLK_XVXENVS( sCLK_XVXENVS ),// ObjectKind=Sheet Entry|PrimaryId=timing_gen.v-sCLK_XVXOSC
	.xxxx( xxxx )                  // ObjectKind=Sheet Entry|PrimaryId=timing_gen.v-xxxx[5..0]
);



pitch_control #(.VOICES(VOICES),.V_OSC(V_OSC),.V_WIDTH(V_WIDTH),.O_WIDTH(O_WIDTH),.OE_WIDTH(OE_WIDTH)) pitch_control_inst  // ObjectKind=Sheet Symbol|PrimaryId=U_pitch_control
(
	.reset_reg_N( reset_reg_N ),		// ObjectKind=Sheet Entry|PrimaryId=pitch_control.v-reset_reg_N
	.reset_data_N( reset_data_N ),	// ObjectKind=Sheet Entry|PrimaryId=pitch_control.v-reset_reg_N
	.xxxx( xxxx ),                  // ObjectKind=Sheet Entry|PrimaryId=pitch_control.v-xxxx[5..0]
	.sCLK_XVXOSC (sCLK_XVXOSC),
	.note_on( reg_note_on ),         // ObjectKind=Sheet Entry|PrimaryId=pitch_control.v-note_on
	.cur_key_adr( reg_cur_key_adr ), // ObjectKind=Sheet Entry|PrimaryId=pitch_control.v-cur_key_adr[2..0]
	.cur_key_val( reg_cur_key_val ), // ObjectKind=Sheet Entry|PrimaryId=pitch_control.v-cur_key_val[7..0]
	.pitch_val( pitch_val ), // ObjectKind=Sheet Entry|PrimaryId=pitch_control.v-pitch_val[13..0]
	.write( write ),             // ObjectKind=Sheet Entry|PrimaryId=pitch_control.v-write
	.read ( read ),
	.sysex_data_patch_send (sysex_data_patch_send),
	.adr( adr ),                 // ObjectKind=Sheet Entry|PrimaryId=pitch_control.v-adr[6..0]
	.data( data ),               // ObjectKind=Sheet Entry|PrimaryId=pitch_control.v-data[7..0]
	.osc_sel( osc_sel ),         // ObjectKind=Sheet Entry|PrimaryId=pitch_control.v-osc_sel
	.com_sel( com_sel ),         // ObjectKind=Sheet Entry|PrimaryId=pitch_control.v-com_sel
	.osc_pitch_val( osc_pitch_val )// ObjectKind=Sheet Entry|PrimaryId=pitch_control.v-osc_pitch_val[23..0]
);
		
osc #(.VOICES(VOICES),.V_OSC(V_OSC),.V_ENVS(V_ENVS),.V_WIDTH(V_WIDTH),.O_WIDTH(O_WIDTH),.OE_WIDTH(OE_WIDTH)) osc_inst // ObjectKind=Sheet Symbol|PrimaryId=U_osc
(
	.reset_reg_N( reset_reg_N ),		// ObjectKind=Sheet Entry|PrimaryId=osc.v-reset_reg_N
	.reset_data_N( reset_data_N ),	// ObjectKind=Sheet Entry|PrimaryId=pitch_control.v-reset_reg_N
	.sCLK_XVXENVS( sCLK_XVXENVS ),// ObjectKind=Sheet Entry|PrimaryId=osc.v-sCLK_XVXENVS
	.sCLK_XVXOSC( sCLK_XVXOSC ),// ObjectKind=Sheet Entry|PrimaryId=osc.v-sCLK_XVXOSC
	.xxxx( xxxx ),                  // ObjectKind=Sheet Entry|PrimaryId=osc.v-xxxx[5..0]
	.modulation( modulation ),          // ObjectKind=Sheet Entry|PrimaryId=osc.v-modulation[10..0]
	.osc_pitch_val( osc_pitch_val ),// ObjectKind=Sheet Entry|PrimaryId=osc.v-osc_pitch_val[23..0]
	.osc_accum_zero( osc_accum_zero ),  	// ObjectKind=Sheet Entry|PrimaryId=env_gen_indexed.v-osc_accum_zero[V_ENVS..0]
	.voice_free ( voice_free ),// ObjectKind=Sheet Entry|PrimaryId=osc.v-voice_free[7..0]
	.write( write ),             // ObjectKind=Sheet Entry|PrimaryId=osc.v-write
	.read ( read ),
	.sysex_data_patch_send (sysex_data_patch_send),
	.adr( adr ),                 // ObjectKind=Sheet Entry|PrimaryId=osc.v-adr[6..0]
	.data( data ),               // ObjectKind=Sheet Entry|PrimaryId=osc.v-data[7..0]
	.osc_sel( osc_sel ),         // ObjectKind=Sheet Entry|PrimaryId=osc.v-osc_sel
	.sine_lut_out( sine_lut_out )        // ObjectKind=Sheet Entry|PrimaryId=osc.v-sine_lut_out[16..0]
);

velocity velocity_inst
(
	.reset_reg_N(reset_reg_N) ,	// input  reset_reg_N_sig
	.vx(xxxx[V_WIDTH+E_WIDTH-1:E_WIDTH]) ,	// input [V_WIDTH-1:0] vx_sig
	.reg_note_on(reg_note_on) ,	// input  reg_note_on_sig
	.reg_cur_vel_on(reg_cur_vel_on) ,	// input [7:0] reg_cur_vel_on_sig
	.reg_cur_key_adr(reg_cur_key_adr) ,	// input [V_WIDTH-1:0] reg_cur_key_adr_sig
	.level_mul(level_mul) ,	// input [7:0] level_mul_sig
	.level_mul_vel(level_mul_vel) 	// output [7:0] level_mul_vel_sig
);

defparam velocity_inst.VOICES = VOICES;
defparam velocity_inst.V_WIDTH = V_WIDTH;

mixer_2 #(.VOICES(VOICES),.V_OSC(V_OSC),.O_ENVS(O_ENVS),.V_WIDTH(V_WIDTH),.O_WIDTH(O_WIDTH),.OE_WIDTH(OE_WIDTH)) mixer_2_inst  // ObjectKind=Sheet Symbol|PrimaryId=U_mixer
(
	.reset_reg_N( reset_reg_N ),		// ObjectKind=Sheet Entry|PrimaryId=mixer.v-reset_reg_N
	.reset_data_N( reset_data_N ),	// ObjectKind=Sheet Entry|PrimaryId=pitch_control.v-reset_reg_N
	.sCLK_XVXENVS( sCLK_XVXENVS ),// ObjectKind=Sheet Entry|PrimaryId=mixer.v-sCLK_XVXENVS
	.sCLK_XVXOSC( sCLK_XVXOSC ), // ObjectKind=Sheet Entry|PrimaryId=synth_clk_gen.v-sCLK_XVXOSC
	.xxxx( xxxx ),                 // ObjectKind=Sheet Entry|PrimaryId=mixer.v-xxxx[5..0]
	.n_xxxx_zero( n_xxxx_zero ),        // ObjectKind=Sheet Entry|PrimaryId=mixer.v-n_xxxx_zero
	.level_mul( level_mul_vel ),  // ObjectKind=Sheet Entry|PrimaryId=mixer.v-level_mul[7..0]
//	.level_mul( level_mul ),  // ObjectKind=Sheet Entry|PrimaryId=mixer.v-level_mul[7..0]
	.sine_lut_out( sine_lut_out ),        // ObjectKind=Sheet Entry|PrimaryId=mixer.v-sine_lut_out[16..0]
	.modulation( modulation ),          // ObjectKind=Sheet Entry|PrimaryId=mixer.v-modulation[10..0]
	.write( write ),             // ObjectKind=Sheet Entry|PrimaryId=mixer.v-write
	.read ( read ),
	.sysex_data_patch_send (sysex_data_patch_send),
	.adr( adr ),                 // ObjectKind=Sheet Entry|PrimaryId=mixer.v-adr[6..0]
	.data( data ),               // ObjectKind=Sheet Entry|PrimaryId=mixer.v-data[7..0]
	.osc_sel( osc_sel ),         // ObjectKind=Sheet Entry|PrimaryId=mixer.v-osc_sel
	.m1_sel( m1_sel ),           // ObjectKind=Sheet Entry|PrimaryId=mixer.v-m1_sel
	.m2_sel( m2_sel ),           // ObjectKind=Sheet Entry|PrimaryId=mixer.v-m2_sel
	.com_sel( com_sel ),         // ObjectKind=Sheet Entry|PrimaryId=mixer.v-com_sel
	.lsound_out( lsound_out ),         // ObjectKind=Sheet Entry|PrimaryId=mixer.v-rsound_out[23..0]
	.rsound_out( rsound_out )          // ObjectKind=Sheet Entry|PrimaryId=mixer.v-rsound_out[23..0]
);
	
env_gen_indexed #(.VOICES(VOICES),.V_ENVS(V_ENVS),.V_WIDTH(V_WIDTH),.E_WIDTH(E_WIDTH)) env_gen_indexed_inst  // ObjectKind=Sheet Symbol|PrimaryId=U_env_gen_indexed
(
	.reset_reg_N( reset_reg_N ),		// ObjectKind=Sheet Entry|PrimaryId=env_gen_indexed.v-reset_reg_N
	.reset_data_N( reset_data_N ),	// ObjectKind=Sheet Entry|PrimaryId=pitch_control.v-reset_reg_N
	.sCLK_XVXENVS( sCLK_XVXENVS ),// ObjectKind=Sheet Entry|PrimaryId=env_gen_indexed.v-sCLK_XVXENVS
	.xxxx( xxxx ),                  // ObjectKind=Sheet Entry|PrimaryId=env_gen_indexed.v-xxxx[5..0]
	.keys_on( reg_keys_on ),         // ObjectKind=Sheet Entry|PrimaryId=env_gen_indexed.v-keys_on[7..0]
	.write( write ),             // ObjectKind=Sheet Entry|PrimaryId=env_gen_indexed.v-write
	.read ( read ),
	.sysex_data_patch_send (sysex_data_patch_send),
	.adr( adr ),                 // ObjectKind=Sheet Entry|PrimaryId=env_gen_indexed.v-adr[6..0]
	.data( data ),               // ObjectKind=Sheet Entry|PrimaryId=env_gen_indexed.v-data[7..0]
	.env_sel( env_sel ),         // ObjectKind=Sheet Entry|PrimaryId=env_gen_indexed.v-env_sel
	.level_mul( level_mul ),  	// ObjectKind=Sheet Entry|PrimaryId=env_gen_indexed.v-level_mul[7..0]
	.osc_accum_zero( osc_accum_zero ),  	// ObjectKind=Sheet Entry|PrimaryId=env_gen_indexed.v-osc_accum_zero[V_ENVS..0]
	.voice_free( voice_free )	// ObjectKind=Sheet Entry|PrimaryId=env_gen_indexed.v-voice_free[7..0]
);


endmodule
