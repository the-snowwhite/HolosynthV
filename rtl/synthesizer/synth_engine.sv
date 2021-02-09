module synth_engine #(
parameter AUD_BIT_DEPTH = 24,
parameter VOICES    = 32,                   // = 32
parameter V_OSC     = 8,                    // = 8 number of oscilators pr. voice.
parameter O_ENVS    = 2,                    // = 2 number of envelope generators pr. oscilator.
parameter V_ENVS    = O_ENVS * V_OSC,       // = 16 number of envelope generators  pr. voice.
parameter V_WIDTH   = utils::clogb2(VOICES),// = 5
parameter O_WIDTH   = utils::clogb2(V_OSC), // = 3
parameter OE_WIDTH  = 1,                    // = 1
parameter E_WIDTH   = O_WIDTH + OE_WIDTH   // = 4
) (
    input wire                  AUDIO_CLK,
    input wire                  reg_clk,
    input wire                  reset_reg_N,
    input wire                  reset_data_N,
    input wire                  trig,
    output wire [AUD_BIT_DEPTH-1:0]  lsound_out,
    output wire [AUD_BIT_DEPTH-1:0]  rsound_out,
    output wire                 xxxx_zero,
    output wire                 xxxx_top,
// from synth_controller
    output wire [3:0]           midi_ch,
    output wire                 uart_usb_sel,
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
    input wire                  syx_read_select,
    input wire  [6:0]           adr,
    output wire [7:0]           synth_data_out,
    input wire  [7:0]           synth_data_in,
    input wire                  env_sel,
    input wire                  osc_sel,
    input wire                  m1_sel,
    input wire                  m2_sel,
    input wire                  com_sel,
// from midi_controller_unit
    input wire  [13:0]          pitch_val,
    input wire  [V_WIDTH:0]     active_keys,
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

wire [7:0]                  cur_status;
wire [7:0]                  octrl;
wire [7:0]                  octrl_data;
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
    
    
wire [V_OSC-1:0] osc_adr_data;
wire [V_OSC-1:0] pitch_adr_data;
wire [V_OSC-1:0] midictrl_adr_data;
wire [7:0]env_regdata_out;
wire [7:0]osc_regdata_out;
wire [7:0]pitch_regdata_out;
wire [7:0]mixer_regdata_out;

    generate
        genvar osc3;
        for (osc3=0;osc3<V_OSC;osc3=osc3+1)begin : oscdataloop
            assign osc_adr_data[osc3] = (adr == (7'd6 +(osc3<<4))) ? 1'b1 : 1'b0;
        end
    endgenerate

   generate
        genvar pitch3;
        for (pitch3=0;pitch3<V_OSC;pitch3=pitch3+1)begin : pitchdataloop
            assign pitch_adr_data[pitch3] = (adr == (7'd0 +(pitch3<<4)) || (adr == 7'd1 +(pitch3<<4)) || (adr == 7'd5 +(pitch3<<4)) ||
            (adr == 7'd8 +(pitch3<<4)) || (adr == 7'd9 +(pitch3<<4))) ? 1'b1 : 1'b0;
        end
    endgenerate

    generate
        genvar mctrl3;
        for (mctrl3=0;mctrl3<V_OSC;mctrl3=mctrl3+1)begin : midictrldataloop
            assign midictrl_adr_data[mctrl3] = (adr == (7'd2 +(mctrl3<<4)) || (adr == 7'd3 +(mctrl3<<4)) || (adr == 7'd4 +(mctrl3<<4)) ||
            (adr == 7'd7 +(mctrl3<<4)) || (adr == 7'd10 +(mctrl3<<4)) || (adr == 7'd11 +(mctrl3<<4)) || (adr == 7'd12 +(mctrl3<<4))
            || (adr == 7'd13 +(mctrl3<<4)) || (adr == 7'd14 +(mctrl3<<4)) || (adr == 7'd15 +(mctrl3<<4))) ? 1'b1 : 1'b0;
        end
    endgenerate

    assign synth_data_out = (env_sel) ? env_regdata_out : 
    (((osc_adr_data != 0) && osc_sel)) ? osc_regdata_out :
    (((pitch_adr_data != 0) && osc_sel) || (com_sel && adr == 0)) ? pitch_regdata_out :
    (((midictrl_adr_data != 0) && osc_sel) || ((com_sel && (adr == 1 || adr == 2 || adr >=10)) || m1_sel || m2_sel)) ? mixer_regdata_out : 8'h00;

synth_clk_gen #(.VOICES(VOICES),.V_OSC(V_OSC),.V_ENVS(V_ENVS),.V_WIDTH(V_WIDTH),.E_WIDTH(E_WIDTH))synth_clk_gen_inst
(
    .AUDIO_CLK      ( AUDIO_CLK ),      // input
    .reset_reg_N    ( reset_data_N ),   // input
    .trig           ( trig ),           // input
    .sCLK_XVXENVS   ( sCLK_XVXENVS ),   // output
    .sCLK_XVXOSC    ( sCLK_XVXOSC ),    // output
    .xxxx           ( xxxx ),           // output
    .run            ( run ),
    .xxxx_zero  ( xxxx_zero ),      // output
    .xxxx_top       ( xxxx_top )        // output
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
    .reg_clk                ( reg_clk ),
    .xxxx                   ( xxxx ),
    .sCLK_XVXOSC            ( sCLK_XVXOSC ),
    .note_on                ( reg_note_on ),
    .cur_key_adr            ( reg_cur_key_adr ),
    .cur_key_val            ( reg_cur_key_val ),
    .pitch_val              ( pitch_val ),
    .write                  ( write ),
    .read                   ( read ),
//    .read_select            ( syx_read_select ),
    .adr                    ( adr ),
    .pitch_regdata_out      ( pitch_regdata_out ),
    .synth_data_in          ( synth_data_in ),
    .osc_sel                ( osc_sel ),
    .com_sel                ( com_sel ),
    .osc_pitch_val          ( osc_pitch_val )
);

osc #(.VOICES(VOICES),.V_OSC(V_OSC),.V_ENVS(V_ENVS),.V_WIDTH(V_WIDTH),.O_WIDTH(O_WIDTH),.OE_WIDTH(OE_WIDTH)) osc_inst
(
    .reg_clk                ( reg_clk ),
    .sCLK_XVXENVS           ( sCLK_XVXENVS ),
    .sCLK_XVXOSC            ( sCLK_XVXOSC ),
    .xxxx                   ( xxxx ),
    .modulation             ( modulation ),
    .osc_pitch_val          ( osc_pitch_val ),
    .osc_accum_zero         ( osc_accum_zero ),
    .voice_free             ( voice_free ),
    .write                  ( write ),
    .read                   ( read ),
//    .read_select  (syx_read_select),
    .adr                    ( adr ),
    .osc_regdata_out        ( osc_regdata_out ),
    .synth_data_in          ( synth_data_in ),
    .osc_sel                ( osc_sel ),
    .sine_lut_out           ( sine_lut_out )
);

velocity velocity_inst
(
    .vx(xxxx[V_WIDTH+E_WIDTH-1:E_WIDTH]) ,  // input
    .reg_note_on(reg_note_on) ,             // input
    .reg_cur_vel_on(reg_cur_vel_on) ,       // input
    .reg_cur_key_adr(reg_cur_key_adr) ,     // input
    .level_mul(level_mul) ,                 // input
    .level_mul_vel(level_mul_vel)           // output
);

defparam velocity_inst.VOICES = VOICES;
defparam velocity_inst.V_WIDTH = V_WIDTH;

mixer_2 #(.AUD_BIT_DEPTH (AUD_BIT_DEPTH),.VOICES(VOICES),.V_OSC(V_OSC),.O_ENVS(O_ENVS),.V_WIDTH(V_WIDTH),.O_WIDTH(O_WIDTH),.OE_WIDTH(OE_WIDTH)) mixer_2_inst
(
    .reg_clk( reg_clk ),
    .sCLK_XVXENVS( sCLK_XVXENVS ),
    .sCLK_XVXOSC( sCLK_XVXOSC ),
    .xxxx( xxxx ),
    .xxxx_zero( xxxx_zero ),
    .level_mul_vel( level_mul_vel ),
    .sine_lut_out( sine_lut_out ),
    .modulation( modulation ),
    .midi_ch( midi_ch ),
    .uart_usb_sel( uart_usb_sel ),
    .active_keys( active_keys ) ,
    .write( write ),
    .read ( read ),
    .adr( adr ),
    .mixer_regdata_out( mixer_regdata_out ),
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
    .reg_clk( reg_clk ),
    .sCLK_XVXENVS( sCLK_XVXENVS ),
    .xxxx( xxxx ),
    .keys_on( reg_keys_on ),         // ObjectKind=Sheet Entry|PrimaryId=env_gen_indexed.v-keys_on[7..0]
    .write( write ),             // ObjectKind=Sheet Entry|PrimaryId=env_gen_indexed.v-write
    .read ( read ),
//    .read_select (syx_read_select),
    .adr( adr ),                 // ObjectKind=Sheet Entry|PrimaryId=env_gen_indexed.v-adr[6..0]
    .env_regdata_out( env_regdata_out ),               // ObjectKind=Sheet Entry|PrimaryId=env_gen_indexed.v-data[7..0]
    .synth_data_in( synth_data_in ),               // ObjectKind=Sheet Entry|PrimaryId=env_gen_indexed.v-data[7..0]
    .env_sel( env_sel ),         // ObjectKind=Sheet Entry|PrimaryId=env_gen_indexed.v-env_sel
    .level_mul( level_mul ),  	         // output
    .osc_accum_zero( osc_accum_zero ),  // output
    .voice_free( voice_free )           // output
);


endmodule
