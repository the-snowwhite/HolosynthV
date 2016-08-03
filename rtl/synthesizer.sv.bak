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

module synthesizer (
// Clock
	input					EXT_CLOCK_IN,				
// reset
	output				reg_DLY0,
// MIDI uart
	input					MIDI_Rx_DAT,		//	MIDI Data
	output				midi_txd,

	input		[4:1]		button,				//	Button[4:1]

	output	[8:1]		GLED,					//	LED[4:1] 
	output	[18:1]	RLED,					//	LED[4:1] 

	inout					AUD_ADCLRCK,		//	Audio CODEC ADC LR Clock
	inout					AUD_DACLRCK,		//	Audio CODEC DAC LR Clock
	input					AUD_ADCDAT,			//	Audio CODEC ADC Data
	output				AUD_DACDAT,			//	Audio CODEC DAC Data
	inout					AUD_BCLK,			//	Audio CODEC Bit-Stream Clock
	output				AUD_XCK,				//	Audio CODEC Chip Clock
	
	output				byteready,	// output  byteready_sig
	output[7:0]			midi_data_byte, 		// output [7:0] midi_data_byte_sig
	output[7:0]			midibyte_nr,	// output [7:0] midibyte_nr_sig
	output[7:0]			cur_status,	// output [7:0] cur_status_sig
	output reg			reg_read_write_act,
	inout [7:0]			data,
	input [6:0] 		cpu_adr,
	input					cpu_env_sel,
	input					cpu_osc_sel,
	input					cpu_m1_sel,
	input					cpu_m2_sel,
	input					cpu_com_sel,
	input					cpu_read,
	input					cpu_write,
	input					cpu_chip_sel
);

parameter VOICES = 32;
parameter V_OSC = 4;	// number of oscilators pr. voice.
parameter O_ENVS = 2;	// number of envelope generators pr. oscilator.

parameter V_ENVS = V_OSC * O_ENVS;	// number of envelope generators  pr. voice.

parameter V_WIDTH = utils::clogb2(VOICES);
parameter O_WIDTH = utils::clogb2(V_OSC);
parameter OE_WIDTH = utils::clogb2(O_ENVS);
parameter E_WIDTH = O_WIDTH + OE_WIDTH;


//-----		Registers		-----//


/////// LED Display ////////
assign GLED[8:1] = keys_on[((VOICES -1) & 7):0];

assign RLED[16:1] = voice_free[((VOICES - 1) & 15):0];

	wire reg_reset_N = button[1] & audio_pll_locked;
	wire data_reset_N = button[2] & sys_pll_locked;
//	wire reg_reset_N = button[1];
//	wire data_reset_N = button[2];
	wire data_DLY0, data_DLY1, data_DLY2, reg_DLY1, reg_DLY2;	
	
	wire reset_reg_n = reg_DLY2;
	wire reset_data_n = data_DLY1;

//---	Midi	---//
// inputs
	
	wire midi_rxd = MIDI_Rx_DAT; // Direct to optocopler RS-232 port (fix it in in topfile)			
//outputs
	wire midi_out_ready,midi_send_byte;
	wire [7:0] midi_out_data;
//	wire byteready;
//	wire [7:0] cur_status,midibyte_nr,midi_data_byte;

//---	Midi	Decoder ---//
	wire [VOICES-1:0]  	keys_on;
	wire dataready;
	wire dec_sysex_data_patch_send;
// note events
	wire               	note_on;
	wire [V_WIDTH-1:0] 	cur_key_adr;
	wire [7:0]         	cur_key_val;
	wire [7:0]         	cur_vel_on;
	wire [7:0]         	cur_vel_off;
// from midi_controller_unit
	wire [13:0] 		pitch_val;
// from env gen
	wire [VOICES-1:0] 	voice_free;

// inputs
// outputs
	wire octrl_cmd,prg_ch_cmd,pitch_cmd;
	wire[7:0] octrl,octrl_data,prg_ch_data;
	wire [V_WIDTH:0]	active_keys;
	wire 	off_note_error;
	wire sys_real;
	wire [7:0] sys_real_dat;

	wire [3:0] midi_ch_sig = 0;

	wire ictrl_cmd;
	wire [7:0]ictrl, ictrl_data;

	wire HC_LCD_CLK, HC_VGA_CLOCK;

	wire CLOCK_25;
	wire OSC_CLK;
	wire sys_pll_locked, audio_pll_locked;
	
	wire [63:0] lvoice_out;
	wire [63:0] rvoice_out;
		
//---	Midi	Controllers unit ---//
	wire [6:0]	dec_adr;
	wire			dec_env_sel;
	wire			dec_osc_sel;
	wire			dec_m1_sel;
	wire			dec_m2_sel;
	wire			dec_com_sel;
	wire			dec_read;
	wire 			dec_write;
	
	wire [6:0]	adr = reg_read_write_act ? dec_adr : cpu_adr;
	wire			env_sel = reg_read_write_act ? dec_env_sel : cpu_env_sel;
	wire			osc_sel = reg_read_write_act ? dec_osc_sel : cpu_osc_sel;
	wire			m1_sel = reg_read_write_act ? dec_m1_sel : cpu_m1_sel;
	wire			m2_sel = reg_read_write_act ? dec_m2_sel : cpu_m2_sel;
	wire			com_sel = reg_read_write_act ? dec_com_sel : cpu_com_sel;
	wire			read = reg_read_write_act ? dec_read : cpu_read;
	wire			write = reg_read_write_act ? dec_write : cpu_write;
	wire			sysex_data_patch_send = reg_read_write_act ? dec_sysex_data_patch_send : (cpu_chip_sel & cpu_read);
	
	wire 			read_write_act = (dataready || reg_dataready[0] || reg_dataready[1] || reg_dataready[2]
				|| reg_dataready[3] || reg_dataready[4]);
	
	reg reg_dataready[4:0];
	
	always @(posedge CLOCK_25) begin
		reg_read_write_act <= read_write_act;
		reg_dataready[0] <= dataready;
		reg_dataready[1] <= reg_dataready[0];
		reg_dataready[2] <= reg_dataready[1];
		reg_dataready[3] <= reg_dataready[2];
		reg_dataready[4] <= reg_dataready[3];
	end
	
	

////////////	Init Reset sig Gen	////////////	
// system reset  //

reset_delay	reset_reg_delay_inst  (
	.iCLK(EXT_CLOCK_IN),
	.reset_reg_N(reg_reset_N),
	.oRST_0(reg_DLY0),
	.oRST_1(reg_DLY1),
	.oRST_2(reg_DLY2)
);

reset_delay	reset_data_delay_inst  (
	.iCLK(EXT_CLOCK_IN),
	.reset_reg_N(data_reset_N),
	.oRST_0(data_DLY0),
	.oRST_1(data_DLY1),
	.oRST_2(data_DLY2)
);
	//  PLL
//reg CLOCK_25;
//always@(posedge EXT_CLOCK_IN) begin	
//		CLOCK_25 <= ~CLOCK_25; 	end
		
sys_pll	sys_disp_pll_inst	(	
`ifdef _CycloneV
	.refclk		( EXT_CLOCK_IN ),
	.outclk_0	( CLOCK_25 ),
	.locked		(sys_pll_locked)    //  locked.export
`else
	.inclk0		( EXT_CLOCK_IN ),
	.c0			( CLOCK_25 )
`endif
);

	// Sound clk gen //
`ifdef _Synth
	//	AUDIO SOUND
	`ifdef _271MhzOscs
		audio_271_pll	audio_pll_inst ( //  271.052632 MHz
	`else
		audio_pll	audio_pll_inst ( // 180.555556 Mhz
	`endif
	`ifdef _CycloneV
		.refclk		( EXT_CLOCK_IN ),
		.outclk_0	( OSC_CLK ),  // 180.555556 Mhz  Mhz
		.outclk_1	( AUD_XCK ), // 16.927083 Mhz
		.locked		(audio_pll_locked)    //  locked.export
//		.outclk_1	( ) // 16.927083 Mhz
	`else
		.inclk0		( EXT_CLOCK_IN ),
		.c0	( OSC_CLK ),  // 180.555556 Mhz --> 270 Mhz
		.c1	( AUD_XCK ) // 16.927083 Mhz
//		.c1	( ) // 16.927083 Mhz
	`endif
	);	


//---				---//

MIDI_UART MIDI_UART_inst (
	.reset_reg_N		(reset_reg_n),		// input  reset_sig
	.CLOCK_25			(CLOCK_25),		// input  reset sig
	.midi_rxd			(midi_rxd),		// input  midi serial data in
	.byteready			(byteready),	// output  byteready_sig
	.sys_real			(sys_real),		// realtime sysex msg arrived
	.sys_real_dat		(sys_real_dat),	// [7:0] realtime sysex msg midi_data_byte
	.cur_status			(cur_status),	// output [7:0] cur_status_sig
	.midibyte_nr		(midibyte_nr),	// output [7:0] midibyte_nr_sig
	.midibyte			(midi_data_byte), 		// output [7:0] midi_data_byte_sig
	.midi_out_ready	(midi_out_ready),// output midi out buffer ready
	.midi_send_byte	(midi_send_byte),
	.midi_out_data		(midi_out_data),// input midi_out_data_sig
	.midi_txd			(midi_txd)		// output midi serial data output
);

midi_decoder #(.VOICES(VOICES),.V_WIDTH(V_WIDTH)) midi_decoder_inst(

	.reset_reg_N(reset_reg_n) ,		// input  reset_reg_N_sig
	.CLOCK_25(CLOCK_25) ,				// input  CLOCK_25_sig
	.byteready(byteready) ,				// input  byteready_sig
	.cur_status(cur_status) ,			// input [7:0] cur_status_sig
	.midibyte_nr(midibyte_nr) ,		// input [7:0] midibyte_nr_sig
	.midibyte(midi_data_byte) ,		// input [7:0] midibyte_sig
	.voice_free(voice_free) ,			// input [VOICES-1:0] voice_free_sig
	.midi_ch(midi_ch_sig) ,				// input [3:0] midi_ch_sig

	.note_on(note_on) ,					// output  note_on_sig
	.keys_on(keys_on) ,					// output [VOICES-1:0] keys_on_sig
	.cur_key_adr(cur_key_adr) ,		// output [V_WIDTH-1:0] cur_key_adr_sig
	.cur_key_val(cur_key_val) ,		// output [7:0] cur_key_val_sig
	.cur_vel_on(cur_vel_on) ,			// output [7:0] cur_vel_on_sig
	.cur_vel_off(cur_vel_off) ,		// output [7:0] cur_vel_off_sig
	.pitch_cmd(pitch_cmd) ,				// output  pitch_cmd_sig
	.octrl(octrl) ,						// output [7:0] octrl_sig
	.octrl_data(octrl_data) ,			// output [7:0] octrl_data_sig
	.prg_ch_cmd(prg_ch_cmd) ,			// output  prg_ch_cmd_sig
	.prg_ch_data(prg_ch_data) ,		// output [7:0] prg_ch_data_sig
// controller data bus
	.write(dec_write) ,						// output  write_sig
	.data_ready(dataready) ,						// output  write_sig
	.read (dec_read), 							// output read data signal
	.read_write (dec_read_write),
	.sysex_data_patch_send (dec_sysex_data_patch_send),
	.adr(dec_adr) ,								// output [6:0] adr_sig
	.data (data) ,							// inout [7:0] data_sig

	.midi_out_ready (midi_out_ready),// input
	.midi_send_byte (midi_send_byte),// input
	.midi_out_data (midi_out_data),	// output
	.env_sel(dec_env_sel) ,					// output  env_sel_sig
	.osc_sel(dec_osc_sel) ,					// output  osc_sel_sig
	.m1_sel(dec_m1_sel) ,						// output  m1_sel_sig
	.m2_sel(dec_m2_sel) ,						// output  m2_sel_sig
	.com_sel(dec_com_sel) ,					// output  com_sel_sig
	.active_keys(active_keys)			// output [V_WIDTH:0] active_keys_sig
);

	
midi_controllers #(.VOICES(VOICES),.V_OSC(V_OSC)) midi_controllers_inst(
	.CLOCK_25			( CLOCK_25 ),
	.reset_data_N		( reset_data_n ),
// from midi_decoder
	.ictrl			( octrl ), 
	.ictrl_data		( octrl_data ), 
	.pitch_cmd		( pitch_cmd ),
// outputs	
	.pitch_val		( pitch_val )
);

	//////////// Sound Generation /////////////	

	assign	AUD_ADCLRCK	=	AUD_DACLRCK;
					
// 2CH Audio Sound output -- Audio Generater //
synth_engine #(.VOICES(VOICES),.V_OSC(V_OSC),.V_ENVS(V_ENVS),.V_WIDTH(V_WIDTH),.O_WIDTH(O_WIDTH),.OE_WIDTH(OE_WIDTH)) synth_engine_inst	(		        
// AUDIO CODEC //		
	.OSC_CLK( OSC_CLK ),				// input
		.AUDIO_CLK( AUD_XCK ),				// input
//	.AUDIO_CLK( AUD_XCK ),					// output
	.reset_reg_N(reset_reg_n) ,			// input  reset_sig
	.reset_data_N		( reset_data_n ),
	.AUD_BCLK ( AUD_BCLK ),				// output
	.AUD_DACDAT( AUD_DACDAT ),			// output
	.AUD_DACLRCK( AUD_DACLRCK ),			// output																
	// KEY //		
	// -- Sound Control -- //
	//	to pitch control //
	.note_on(note_on) ,					// input  note_on_sig
	.keys_on(keys_on) ,					// input [VOICES-1:0] keys_on_sig
	.cur_key_adr(cur_key_adr) ,		// input [V_WIDTH-1:0] cur_key_adr_sig
	.cur_key_val(cur_key_val) ,		// input [7:0] cur_key_val_sig
	.cur_vel_on(cur_vel_on) ,			// input [7:0] cur_vel_on_sig
	.cur_vel_off(cur_vel_off) ,		// input [7:0] cur_vel_off_sig
// from midi_controller_unit
	.pitch_val ( pitch_val ),
// controller data bus
	.write(write) ,				// input  write_sig
	.read (read), 					// input read data signal
	.sysex_data_patch_send (sysex_data_patch_send), // input
	.adr(adr) ,						// input [6:0] adr_sig
	.data (data) ,					// bi-dir [7:0] data_sig
	.env_sel(env_sel) ,			// input  env_sel_sig
	.osc_sel(osc_sel) ,			// input  osc_sel_sig
	.m1_sel(m1_sel) ,				// input  m1_sel_sig
	.m2_sel(m2_sel) ,				// input  m2_sel_sig
	.com_sel(com_sel), 			// input  com_sel_sig
// from env gen // 
	.voice_free( voice_free )	//output from envgen
);
`endif



endmodule
