module synth_engine #(
parameter VOICES    = 32,                   // = 32
parameter V_OSC     = 8,                    // = 8 number of oscilators pr. voice.
parameter O_ENVS    = 2,                    // = 2 number of envelope generators pr. oscilator.
parameter V_ENVS    = O_ENVS * V_OSC,       // = 16 number of envelope generators  pr. voice.
parameter V_WIDTH   = utils::clogb2(VOICES),// = 5
parameter O_WIDTH   = utils::clogb2(V_OSC), // = 3
parameter OE_WIDTH  = 1,                    // = 1
parameter E_WIDTH   = O_WIDTH + OE_WIDTH,   // = 4
parameter AUD_BIT_DEPTH = 24
) (
    input wire                  AUDIO_CLK,
    input wire                  data_clk,
    input wire                  reset_reg_N,
    input wire                  reset_data_N,
    input wire                  trig,
    output wire [AUD_BIT_DEPTH-1:0]  lsound_out,
    output wire [AUD_BIT_DEPTH-1:0]  rsound_out,
    output wire                 xxxx_zero,
// from synth_controller
// note events
    input wire  [VOICES-1:0]    keys_on,
    input wire                  note_on,
    input wire  [V_WIDTH-1:0]   cur_key_adr,
    input wire  [7:0]           cur_key_val,
    input wire  [7:0]           cur_vel_on,
    input wire  [7:0]           cur_vel_off,
// midi data events
    input wire                  write,
    input wire                  read,
    input wire                  read_select,
    input wire  [6:0]           adr,
    wire     [7:0]           synth_data_out,
    input wire  [7:0]           synth_data_in,
    input wire                  env_sel,
    input wire                  osc_sel,
    input wire                  m1_sel,
    input wire                  m2_sel,
    input wire                  com_sel,
// from midi_controller_unit
    input wire  [13:0]          pitch_val,
// from env gen
    output wire                 run,
    output wire [VOICES-1:0]    voice_free
);

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

synth_clk_gen #(.VOICES(VOICES),.V_OSC(V_OSC),.V_ENVS(V_ENVS),.V_WIDTH(V_WIDTH),.E_WIDTH(E_WIDTH))synth_clk_gen_inst
(
    .reset_reg_N    ( reset_reg_N ),    // input
    .AUDIO_CLK      ( AUDIO_CLK ),      // input
    .trig           ( trig ),           // input
    .sCLK_XVXENVS   ( sCLK_XVXENVS ),   // output
    .sCLK_XVXOSC    ( sCLK_XVXOSC ),    // output
    .xxxx           ( xxxx ),           // output
    .run            ( run ),
    .xxxx_zero      ( xxxx_zero )       // output
);

// wire SYNC_CLK;
// assign SYNC_CLK = run ? AUDIO_CLK : 1'b0;

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

pitch_control #(.VOICES(VOICES),.V_OSC(V_OSC),.V_WIDTH(V_WIDTH),.O_WIDTH(O_WIDTH),.OE_WIDTH(OE_WIDTH)) pitch_control_inst
(
    .data_clk               ( data_clk ),
    .reset_reg_N            ( reset_reg_N ),
    .reset_data_N           ( reset_data_N ),
    .xxxx                   ( xxxx ),
    .sCLK_XVXOSC            ( sCLK_XVXOSC ),
    .note_on                ( reg_note_on ),
    .cur_key_adr            ( reg_cur_key_adr ),
    .cur_key_val            ( reg_cur_key_val ),
    .pitch_val              ( pitch_val ),
    .write                  ( write ),
    .read                   ( read ),
    .read_select  ( read_select ),
    .adr                    ( adr ),
    .synth_data_out         ( synth_data_out ),
    .synth_data_in          ( synth_data_in ),
    .osc_sel                ( osc_sel ),
    .com_sel                ( com_sel ),
    .osc_pitch_val          ( osc_pitch_val )
);

osc #(.VOICES(VOICES),.V_OSC(V_OSC),.V_ENVS(V_ENVS),.V_WIDTH(V_WIDTH),.O_WIDTH(O_WIDTH),.OE_WIDTH(OE_WIDTH)) osc_inst
(
    .data_clk               ( data_clk ),
    .reset_reg_N            ( reset_reg_N ),
    .reset_data_N           ( reset_data_N ),
    .sCLK_XVXENVS           ( sCLK_XVXENVS ),
    .sCLK_XVXOSC            ( sCLK_XVXOSC ),
    .xxxx                   ( xxxx ),
    .modulation             ( modulation ),
    .osc_pitch_val          ( osc_pitch_val ),
    .osc_accum_zero         ( osc_accum_zero ),
    .voice_free             ( voice_free ),
    .write                  ( write ),
    .read                   ( read ),
    .read_select  (read_select),
    .adr                    ( adr ),
    .synth_data_out         ( synth_data_out ),
    .synth_data_in          ( synth_data_in ),
    .osc_sel                ( osc_sel ),
    .sine_lut_out           ( sine_lut_out )
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
    .data_clk( data_clk ),
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
    .read_select (read_select),
    .adr( adr ),
    .synth_data_out( synth_data_out ),
    .synth_data_in( synth_data_in ),
    .osc_sel( osc_sel ),
    .m1_sel( m1_sel ),
    .m2_sel( m2_sel ),
    .com_sel( com_sel ),
    .lsound_out( lsound_out ),
    .rsound_out( rsound_out )
);

env_gen_indexed #(.VOICES(VOICES),.V_ENVS(V_ENVS),.V_WIDTH(V_WIDTH),.E_WIDTH(E_WIDTH)) env_gen_indexed_inst  // ObjectKind=Sheet Symbol|PrimaryId=U_env_gen_indexed
(
    .data_clk( data_clk ),
    .reset_reg_N( reset_reg_N ),		// ObjectKind=Sheet Entry|PrimaryId=env_gen_indexed.v-reset_reg_N
    .reset_data_N( reset_data_N ),	// ObjectKind=Sheet Entry|PrimaryId=pitch_control.v-reset_reg_N
    .sCLK_XVXENVS( sCLK_XVXENVS ),
    .xxxx( xxxx ),
    .keys_on( reg_keys_on ),         // ObjectKind=Sheet Entry|PrimaryId=env_gen_indexed.v-keys_on[7..0]
    .write( write ),             // ObjectKind=Sheet Entry|PrimaryId=env_gen_indexed.v-write
    .read ( read ),
    .read_select (read_select),
    .adr( adr ),                 // ObjectKind=Sheet Entry|PrimaryId=env_gen_indexed.v-adr[6..0]
    .synth_data_out( synth_data_out ),               // ObjectKind=Sheet Entry|PrimaryId=env_gen_indexed.v-data[7..0]
    .synth_data_in( synth_data_in ),               // ObjectKind=Sheet Entry|PrimaryId=env_gen_indexed.v-data[7..0]
    .env_sel( env_sel ),         // ObjectKind=Sheet Entry|PrimaryId=env_gen_indexed.v-env_sel
    .level_mul( level_mul ),  	         // output
    .osc_accum_zero( osc_accum_zero ),  // output
    .voice_free( voice_free )           // output
);


endmodule
