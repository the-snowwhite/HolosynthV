/////////////////////////////////////////////
////     2Channel-Music-Synthesizer     /////
/////////////////////////////////////////////
/*****************************************************/
/*             KEY & SW List               			 */
/* BUTTON[1]: I2C reset                       		 */
/* BUTTON[2]: Demo Sound and Keyboard mode selection */
/* BUTTON[3]: Keyboard code Reset             		 */
/* BUTTON[4]: Keyboard system Reset                  */
/*****************************************************/

module synthesizer #(
parameter AUD_BIT_DEPTH = 24,
parameter VOICES = 32,
parameter V_OSC = 4,				// number of oscilators pr. voice.
parameter O_ENVS = 2,				// number of envelope generators pr. oscilator.
parameter V_ENVS = V_OSC * O_ENVS,	// number of envelope generators  pr. voice.
parameter V_WIDTH = utils::clogb2(VOICES),
parameter O_WIDTH = utils::clogb2(V_OSC),
parameter OE_WIDTH = utils::clogb2(O_ENVS),
parameter E_WIDTH = O_WIDTH + OE_WIDTH,
parameter Invert_rxd = 0,
parameter REG_CLK_FREQUENCY = 50_000_000
) (
// Clock
    input wire              reg_clk,
    input wire              AUDIO_CLK,
// reset
    input wire              reset_reg_n,
    input wire              reset_data_n,
    input wire              trig,
// MIDI uart
    input wire              MIDI_Rx_DAT,
    output wire             midi_txd,

    input wire  [4:1]       button,
    output wire [VOICES-1:0] keys_on,
    output wire [VOICES-1:0] voice_free,
    output wire [V_WIDTH-1:0]	active_keys,

    output wire [AUD_BIT_DEPTH-1:0]  lsound_out,
    output wire [AUD_BIT_DEPTH-1:0]  rsound_out,

    output wire             xxxx_zero,
    output wire             xxxx_top,

    input wire              cpu_read,
    input wire              cpu_write,
    input wire              chipselect,
    input wire  [9:0]       address,
    input wire  [31:0]      cpu_readdata,
    output wire [31:0]      cpu_writedata,
    input wire  [2:0]       socmidi_addr,
    input wire              socmidi_read,
    input wire              socmidi_write,
//    input wire              socmidi_cs,
    input wire  [7:0]       socmidi_data_in,
    output reg [7:0]        socmidi_data_out,
    output wire             run
);

//-----		Registers		-----//
// io:

    wire [5:0]          cpu_sel;
    wire [5:0]          syx_sel;
    wire signed [7:0]   synth_data_out;
    wire signed [7:0]   synth_data_in;
    wire reset_data;
    assign reset_data = ~reset_data_n;

//    wire data_DLY0, data_DLY1, data_DLY2, reg_DLY0, reg_DLY1, reg_DLY2;

    wire reg_reset_N;
//    wire data_reset_N;
//    wire reset_data_n;

 //   assign data_reset_N = button[2];

//    wire reset_reg_N = reg_DLY2;
//    assign reset_data_n = data_DLY1;

//---	Midi	---//
// inputs
    wire midi_rxd;
//outputs
    wire midi_out_ready,midi_send_byte;
    wire [7:0] midi_out_data;
    wire [7:0] cur_status,midibyte_nr,midi_data_byte;

//---	Midi	Decoder ---//
    wire syx_data_ready;
//    wire dec_sysex_data_patch_send;
// note events
    wire               	note_on;
    wire [V_WIDTH-1:0] 	cur_key_adr;
    wire [7:0]         	cur_key_val;
    wire [7:0]         	cur_vel_on;
    wire [7:0]         	cur_vel_off;
// from midi_controller_unit
    wire [13:0] 		pitch_val;
// from env gen

// inputs
// outputs
    wire        prg_ch_cmd,pitch_cmd;
    wire [7:0]  prg_ch_data;
    wire 	    off_note_error;

    wire        ictrl_cmd;
    wire [7:0]  ictrl, ictrl_data;

    wire HC_LCD_CLK, HC_VGA_CLOCK;

    wire        audio_pll_locked;

    wire [63:0] lvoice_out;
    wire [63:0] rvoice_out;

//---	Midi	Controllers unit ---//
    wire [6:0]	syx_dec_addr;
    wire [2:0]	syx_bank_addr;
    wire [6:0]	adr;
    wire		env_sel	;
    wire		osc_sel;
    wire		m1_sel;
    wire		m2_sel;
    wire		com_sel;
    wire		read;
    wire		write;
    wire		syx_read;
    wire		syx_write;
    wire		syx_read_select;
    wire [7:0]  sysex_data_out;

    wire [4:0]  midi_ch;
    reg  [7:0]  out_data;

    wire    write_dataenable;

    assign midi_rxd = MIDI_Rx_DAT; // Direct to optocopler RS-232 port (fix it in in topfile)

    assign reg_reset_N = button[1] & reset_reg_n;

    assign cpu_writedata[7:0] = synth_data_out;
    assign synth_data_in = write_dataenable ? sysex_data_out : cpu_readdata[7:0];

addr_decoder #(.addr_width(3),.num_lines(6)) addr_decoder_inst
(
    .clk(reg_clk) ,	// input  clk_sig
    .reset_n(reg_reset_N) ,	// input  reset_sig
    .address(address[9:7]) ,	// input [addr_width-1:0] address_sig
    .sel(cpu_sel[5:0]) 	// output [num_lines:0] sel_sig
);

addr_decoder #(.addr_width(3),.num_lines(6)) syx_addr_decoder_inst
(
    .clk(reg_clk) ,	// input  clk_sig
    .reset_n(reg_reset_N) ,	// input  reset_sig
    .address(syx_bank_addr) ,	// input [addr_width-1:0] address_sig
    .sel(syx_sel[5:0]) 	// output [num_lines:0] sel_sig
);

addr_mux #(.addr_width(7),.num_lines(7)) addr_mux_inst
(
    .clk(reg_clk) ,	// input  in_select_sig
    .syx_data_ready(write_dataenable) ,	// input  in_select_sig
    .dec_syx(syx_data_ready) ,	// input  dec_syx_sig
    .cpu_and({chipselect,cpu_read}) ,	// input [1:0] cpu_and_sig
    .dec_addr(syx_dec_addr) ,	// input [addr_width-1:0] dec_addr_sig
    .cpu_addr(address[6:0]) ,	// input [addr_width-1:0] cpu_addr_sig
    .cpu_sel_bus({cpu_write,cpu_read,cpu_sel[5],cpu_sel[3:0]}) ,	// input [num_lines-1:0] cpu_sel_sig
//    .dec_sel_bus(dec_sel_bus) ,	// input [num_lines-1:0] dec_sel_sig
    .dec_sel_bus({syx_write,syx_read,syx_sel[5],syx_sel[3:0]}) ,	// input [num_lines-1:0] dec_sel_sig
    .syx_read_select (syx_read_select), // output
    .addr_out(adr) ,	// output [addr_width-1:0] addr_out_sig
    .sel_out_bus({write,read,com_sel,m2_sel,m1_sel,osc_sel,env_sel}) 	// output [num_lines-1:0] sel_out_sig
);

////////////	Init Reset sig Gen	////////////
// system reset  //
/*
reset_delay	reset_reg_delay_inst  (
    .iCLK(reg_clk),
    .reset_reg_N(reg_reset_N),
    .oRST_0(reg_DLY0),
    .oRST_1(reg_DLY1),
    .oRST_2(reg_DLY2)
);

reset_delay	reset_data_delay_inst  (
    .iCLK(reg_clk),
    .reset_reg_N(data_reset_N),
    .oRST_0(data_DLY0),
    .oRST_1(data_DLY1),
    .oRST_2(data_DLY2)
);
*/
    // Sound clk gen //

synth_controller #(.VOICES(VOICES),.V_WIDTH(V_WIDTH),.Invert_rxd(Invert_rxd),.REG_CLK_FREQUENCY(REG_CLK_FREQUENCY)) synth_controller_inst(

    .reg_clk(reg_clk) ,
    .socmidi_addr(socmidi_addr) ,
    .socmidi_data_in(socmidi_data_in) ,
    .socmidi_write(socmidi_write) ,
    .midi_rxd(midi_rxd) ,
    .midi_txd(midi_txd) ,
    .voice_free(voice_free) ,
    .cur_midi_ch(cur_midi_ch), 
    .note_on(note_on) ,
    .keys_on(keys_on) ,
    .cur_key_adr(cur_key_adr) ,
    .cur_key_val(cur_key_val) ,
    .cur_vel_on(cur_vel_on) ,
    .cur_vel_off(cur_vel_off) ,
    .pitch_val(pitch_val) ,
    .prg_ch_cmd(prg_ch_cmd) ,
    .prg_ch_data(prg_ch_data) ,
// controller data bus
    .syx_data_ready(syx_data_ready) ,   //output
    .write_dataenable (write_dataenable),
    .syx_dec_addr(syx_dec_addr) ,
    .syx_bank_addr(syx_bank_addr) ,
    .syx_read(syx_read) ,
    .syx_write(syx_write) ,
    .sysex_data_out (sysex_data_out) ,
    .synth_data_out (synth_data_out),  // input
    .active_keys(active_keys)
);

    //////////// Sound Generation /////////////

// 2CH Audio Sound output -- Audio Generater //
synth_engine #(.AUD_BIT_DEPTH (AUD_BIT_DEPTH),.VOICES(VOICES),.V_OSC(V_OSC),.V_ENVS(V_ENVS),.V_WIDTH(V_WIDTH),.O_WIDTH(O_WIDTH),.OE_WIDTH(OE_WIDTH)) synth_engine_inst	(
// AUDIO CODEC //
    .AUDIO_CLK              ( AUDIO_CLK ),              // input
    .reg_clk                ( reg_clk ),
    .reset_reg_N            ( reg_reset_N ) ,           // input  reset_sig
    .reset_data_N           ( reset_data_n ),
    .trig                   ( trig ),
    .lsound_out             ( lsound_out ),             //  Audio Raw Dat
    .rsound_out             ( rsound_out ),             //  Audio Raw Data
    .xxxx_zero              ( xxxx_zero ) ,             // output  count complete signal
    .xxxx_top               ( xxxx_top ) ,              // output  cycle complete signal
    .cur_midi_ch            ( cur_midi_ch ) ,               // output  
    // KEY //
    // -- Sound Control -- //
    //	to pitch control //
    .note_on                ( note_on ) ,               // input  note_on_sig
    .keys_on                ( keys_on ) ,               // input [VOICES-1:0] keys_on_sig
    .cur_key_adr            ( cur_key_adr ) ,           // input [V_WIDTH-1:0] cur_key_adr_sig
    .cur_key_val            ( cur_key_val ) ,           // input [7:0] cur_key_val_sig
    .cur_vel_on             ( cur_vel_on ) ,            // input [7:0] cur_vel_on_sig
    .cur_vel_off            ( cur_vel_off ) ,           // input [7:0] cur_vel_off_sig
// from midi_controller_unit
    .pitch_val              ( pitch_val ),
    .active_keys            ( active_keys ) ,
// controller data bus
    .write                  ( write ),                  // input  write_sig
    .read                   ( read ),                   // input read synth_data signal
    .syx_read_select        ( syx_read_select ),        // input
    .adr                    ( adr ) ,                   // input [6:0] adr_sig
    .synth_data_out         ( synth_data_out ) ,        // output
    .synth_data_in          ( synth_data_in ) ,
    .env_sel                ( env_sel ) ,
    .osc_sel                ( osc_sel ) ,
    .m1_sel                 ( m1_sel ) ,
    .m2_sel                 ( m2_sel ) ,
    .com_sel                ( com_sel ),
// from env gen //
    .run                    ( run ),
    .voice_free             ( voice_free )              //output from envgen
);

endmodule
