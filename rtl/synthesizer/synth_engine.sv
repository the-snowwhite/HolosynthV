module synth_engine (
    input                   CLOCK_50,
    input                   AUDIO_CLK,
    input                   reset_reg_N,
    input                   reset_data_N,
    input                   trig,
`ifdef _32BitAudio
    output  [31:0]          lsound_out,
    output  [31:0]          rsound_out,
`elsif _24BitAudio
    output  [23:0]          lsound_out,
    output  [23:0]          rsound_out,
`else
    output  [15:0]          lsound_out,
    output  [15:0]          rsound_out,
`endif
    output		            xxxx_zero,
// from synth_controller
// note events
    input   [VOICES-1:0]    keys_on,
    input                   note_on,
    input   [V_WIDTH-1:0]   cur_key_adr,
    input   [7:0]           cur_key_val,
    input   [7:0]           cur_vel_on,
    input   [7:0]           cur_vel_off,
// midi data events
    input                   write,
    input                   read,
    input                   sysex_data_patch_send,
    input   [6:0]           adr,
    inout   [7:0]           data,
    input                   env_sel,
    input                   osc_sel,
    input                   m1_sel,
    input                   m2_sel,
    input                   com_sel,
// from midi_controller_unit
    input   [13:0]          pitch_val,
// from env gen
    output  [VOICES-1:0]    voice_free
);


parameter VOICES    = 32;                   // = 32
parameter V_OSC     = 8;                    // = 8 number of oscilators pr. voice.
parameter O_ENVS    = 2;                    // = 2 number of envelope generators pr. oscilator.
parameter V_ENVS    = O_ENVS * V_OSC;       // = 16 number of envelope generators  pr. voice.

parameter V_WIDTH   = utils::clogb2(VOICES);// = 5
parameter O_WIDTH   = utils::clogb2(V_OSC); // = 3
parameter OE_WIDTH  = 1;                    // = 1
parameter E_WIDTH   = O_WIDTH + OE_WIDTH;   // = 4

//-----		Wires		-----//
wire                        sCLK_XVXENVS;
wire                        sCLK_XVXOSC;
wire [V_WIDTH+E_WIDTH-1:0]  xxxx;
wire [7:0]                  level_mul;
wire [7:0]                  level_mul_vel;

wire                        byteready;
wire [7:0]                  cur_status;
wire [7:0]                  octrl;
wire [7:0]                  octrl_data;
wire                        pitch_cmd;
wire [7:0]                  midibyte;
wire [7:0]                  midibyte_nr;
wire [10:0]                 modulation;
wire [16:0]                 sine_lut_out;
wire [23:0]                 osc_pitch_val;

wire [V_ENVS-1:0]           osc_accum_zero;
wire                        reg_note_on;
wire [V_WIDTH-1:0]          reg_cur_key_adr;
wire [7:0]                  reg_cur_key_val;
wire [7:0]                  reg_cur_vel_on;
wire [VOICES-1:0]           reg_keys_on;
//wire                        audio_pll_locked, reset_clk_n;
//  PLL
/*
assign reset_clk_n = (audio_pll_locked && reset_reg_N) ? 1'b1 : 1'b0;
audio_pll	audio_pll_inst	(
    .refclk		( CLOCK_50 ),
    .rst		( ~reset_reg_N ),
    .outclk_0	( AUDIO_CLK ),
    .locked		( audio_pll_locked )    //  locked.export
);
*/
synth_clk_gen #(.VOICES(VOICES),.V_OSC(V_OSC),.V_ENVS(V_ENVS),.V_WIDTH(V_WIDTH),.E_WIDTH(E_WIDTH))synth_clk_gen_inst
(
    .reset_reg_N    ( reset_reg_N ),    // input
    .AUDIO_CLK      ( AUDIO_CLK ),      // input
    .trig           ( trig ),           // input
    .sCLK_XVXENVS   ( sCLK_XVXENVS ),   // output
    .sCLK_XVXOSC    ( sCLK_XVXOSC ),    // output
    .xxxx           ( xxxx ),           // output
    .xxxx_zero      ( xxxx_zero )       // output
);

note_key_vel_sync #(.VOICES(VOICES),.V_WIDTH(V_WIDTH)) key_sync_inst
(
    .xxxx_zero          (xxxx_zero),        // input
    .AUDIO_CLK          ( AUDIO_CLK ),      // input
    .note_on            (note_on),          // input
    .cur_key_adr        (cur_key_adr),      // input
    .cur_key_val        (cur_key_val),      // input
    .cur_vel_on         (cur_vel_on),       // input
    .keys_on            (keys_on),          // input
    .reg_note_on        (reg_note_on),      // output
    .reg_cur_key_adr    (reg_cur_key_adr),  // output
    .reg_cur_key_val    (reg_cur_key_val),  // output
    .reg_cur_vel_on     (reg_cur_vel_on),   // output
    .reg_keys_on        (reg_keys_on)       // output
);

pitch_control #(.VOICES(VOICES),.V_OSC(V_OSC),.V_WIDTH(V_WIDTH),.O_WIDTH(O_WIDTH),.OE_WIDTH(OE_WIDTH)) pitch_control_inst  // ObjectKind=Sheet Symbol|PrimaryId=U_pitch_control
(
    .reset_reg_N( reset_reg_N ),
    .reset_data_N( reset_data_N ),
    .xxxx( xxxx ),
    .sCLK_XVXOSC (sCLK_XVXOSC),
    .note_on( reg_note_on ),
    .cur_key_adr( reg_cur_key_adr ),
    .cur_key_val( reg_cur_key_val ),
    .pitch_val( pitch_val ),
    .write( write ),
    .read ( read ),
    .sysex_data_patch_send (sysex_data_patch_send),
    .adr( adr ),
    .data( data ),
    .osc_sel( osc_sel ),
    .com_sel( com_sel ),
    .osc_pitch_val( osc_pitch_val )
);

osc #(.VOICES(VOICES),.V_OSC(V_OSC),.V_ENVS(V_ENVS),.V_WIDTH(V_WIDTH),.O_WIDTH(O_WIDTH),.OE_WIDTH(OE_WIDTH)) osc_inst
(
    .reset_reg_N( reset_reg_N ),
    .reset_data_N( reset_data_N ),
    .sCLK_XVXENVS( sCLK_XVXENVS ),
    .sCLK_XVXOSC( sCLK_XVXOSC ),
    .xxxx( xxxx ),
    .modulation( modulation ),
    .osc_pitch_val( osc_pitch_val ),
    .osc_accum_zero( osc_accum_zero ),
    .voice_free ( voice_free ),
    .write( write ),
    .read ( read ),
    .sysex_data_patch_send (sysex_data_patch_send),
    .adr( adr ),
    .data( data ),
    .osc_sel( osc_sel ),
    .sine_lut_out( sine_lut_out )
);

velocity velocity_inst
(
    .reset_reg_N(reset_reg_N) ,             // input
    .vx(xxxx[V_WIDTH+E_WIDTH-1:E_WIDTH]) ,  // input
    .reg_note_on(reg_note_on) ,             // input
    .reg_cur_vel_on(reg_cur_vel_on) ,       // input
    .reg_cur_key_adr(reg_cur_key_adr) ,     // input
    .level_mul(level_mul) ,                 // input
    .level_mul_vel(level_mul_vel)           // output
);

defparam velocity_inst.VOICES = VOICES;
defparam velocity_inst.V_WIDTH = V_WIDTH;

mixer_2 #(.VOICES(VOICES),.V_OSC(V_OSC),.O_ENVS(O_ENVS),.V_WIDTH(V_WIDTH),.O_WIDTH(O_WIDTH),.OE_WIDTH(OE_WIDTH)) mixer_2_inst
(
    .reset_data_N( reset_data_N ),
    .sCLK_XVXENVS( sCLK_XVXENVS ),
    .sCLK_XVXOSC( sCLK_XVXOSC ),
    .xxxx( xxxx ),
    .xxxx_zero( xxxx_zero ),
    .level_mul_vel( level_mul_vel ),
    .sine_lut_out( sine_lut_out ),
    .modulation( modulation ),
    .write( write ),
    .read ( read ),
    .sysex_data_patch_send (sysex_data_patch_send),
    .adr( adr ),
    .data( data ),
    .osc_sel( osc_sel ),
    .m1_sel( m1_sel ),
    .m2_sel( m2_sel ),
    .com_sel( com_sel ),
    .lsound_out( lsound_out ),
    .rsound_out( rsound_out )
);

env_gen_indexed #(.VOICES(VOICES),.V_ENVS(V_ENVS),.V_WIDTH(V_WIDTH),.E_WIDTH(E_WIDTH)) env_gen_indexed_inst  // ObjectKind=Sheet Symbol|PrimaryId=U_env_gen_indexed
(
    .reset_reg_N( reset_reg_N ),		// ObjectKind=Sheet Entry|PrimaryId=env_gen_indexed.v-reset_reg_N
    .reset_data_N( reset_data_N ),	// ObjectKind=Sheet Entry|PrimaryId=pitch_control.v-reset_reg_N
    .sCLK_XVXENVS( sCLK_XVXENVS ),
    .xxxx( xxxx ),
    .keys_on( reg_keys_on ),         // ObjectKind=Sheet Entry|PrimaryId=env_gen_indexed.v-keys_on[7..0]
    .write( write ),             // ObjectKind=Sheet Entry|PrimaryId=env_gen_indexed.v-write
    .read ( read ),
    .sysex_data_patch_send (sysex_data_patch_send),
    .adr( adr ),                 // ObjectKind=Sheet Entry|PrimaryId=env_gen_indexed.v-adr[6..0]
    .data( data ),               // ObjectKind=Sheet Entry|PrimaryId=env_gen_indexed.v-data[7..0]
    .env_sel( env_sel ),         // ObjectKind=Sheet Entry|PrimaryId=env_gen_indexed.v-env_sel
    .level_mul( level_mul ),  	         // output
    .osc_accum_zero( osc_accum_zero ),  // output
    .voice_free( voice_free )           // output
);


endmodule
