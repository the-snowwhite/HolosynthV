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
	input					reset_n,
// MIDI uart
	input					MIDI_Rx_DAT,		//	MIDI Data
	output					midi_txd,

	input		[4:1]		button,				//	Button[4:1]

//	output	[8:1]			GLED,				//	LED[4:1]
	output [VOICES-1:0]     keys_on,
//	output	[18:1]		    RLED,				//	LED[4:1]
	output [VOICES-1:0]	    voice_free,

//	inout					AUD_ADCLRCK,		//	Audio CODEC ADC LR Clock
//	inout					AUD_DACLRCK,		//	Audio CODEC DAC LR Clock
//	input					AUD_ADCDAT,			//	Audio CODEC ADC Data
//	output					AUD_DACDAT,			//	Audio CODEC DAC Data
//	inout					AUD_BCLK,			//	Audio CODEC Bit-Stream Clock
//	input					AUDIO_CLK,			//	CPU Audio CODEC Chip Clock
	input					OSC_CLK,			//	ADAU-1966 Audio CODEC Chip Clock
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
	input 					io_clk,
	input					io_reset_n,
	input					cpu_read,
	input					cpu_write,
	input					chipselect,
	input [9:0]				address,
	input [31:0]			writedata,
	output reg [31:0]		readdata,
	input					socmidi_read,
	input					socmidi_write,
	input					socmidi_cs,
	input [2:0]				socmidi_addr,
	input [7:0]			    socmidi_data_out,
	output reg [7:0]		socmidi_data_in,
    input                   switch4
);

parameter VOICES = 32;
parameter V_OSC = 4;				// number of oscilators pr. voice.
parameter O_ENVS = 2;				// number of envelope generators pr. oscilator.

parameter V_ENVS = V_OSC * O_ENVS;	// number of envelope generators  pr. voice.

parameter V_WIDTH = utils::clogb2(VOICES);
parameter O_WIDTH = utils::clogb2(V_OSC);
parameter OE_WIDTH = utils::clogb2(O_ENVS);
parameter E_WIDTH = O_WIDTH + OE_WIDTH;


//-----		Registers		-----//
// io:

	reg 			write_delay;
	reg 			reg_w_act;
	reg [7:0] 		indata;
    wire [5:0]      cpu_sel;
 	wire [7:0]		synth_data;
	wire w_act = (cpu_write | write_delay);
	wire write_active = (cpu_write | reg_w_act);
	wire io_reset = ~io_reset_n;

	assign synth_data = (!cpu_read && write_active) ? indata : 8'bz;

always @(posedge io_clk) begin
	write_delay <= cpu_write;
	reg_w_act <= w_act;
end

always @(posedge io_clk) begin
	if (io_reset)
		readdata[7:0] <= 8'b0;
	else if (read)
		readdata[7:0] <= (com_sel && adr == 2) ? out_data : synth_data;
	else if	(write)
		indata <= writedata[7:0];
end


	reg [7:0] midi_ch;
	reg [7:0] out_data;

 /** @brief write data
*/
    always@(negedge reset_reg_n or negedge write)begin
        if(!reset_reg_n) begin
            midi_ch <= 8'h00;
        end else begin
            if(com_sel) begin
                if(adr == 2) midi_ch <= synth_data;
            end
        end
    end

 /** @brief read data
*/
	always @(posedge read) begin
		if(com_sel) begin
            if(adr == 2) out_data <= midi_ch;
        end
	end


addr_decoder #(.addr_width(3),.num_lines(6)) addr_decoder_inst
(
	.clk(io_clk) ,	// input  clk_sig
	.reset(io_reset) ,	// input  reset_sig
	.address(address[9:7]) ,	// input [addr_width-1:0] address_sig
	.sel(cpu_sel[5:0]) 	// output [num_lines:0] sel_sig
);

	wire reg_reset_N = button[1] & reset_n;
	wire data_reset_N = button[2] & sys_pll_locked;
	wire data_DLY0, data_DLY1, data_DLY2, reg_DLY1, reg_DLY2;

	wire reset_reg_n = reg_DLY2;
	wire reset_data_n = data_DLY1;

//---	Midi	---//
// inputs

	wire midi_rxd = MIDI_Rx_DAT; // Direct to optocopler RS-232 port (fix it in in topfile)
//outputs
	wire midi_out_ready,midi_send_byte;
	wire [7:0] midi_out_data;
	wire byteready;
	wire [7:0] cur_status,midibyte_nr,midi_data_byte;

//---	Midi	Decoder ---//
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

// inputs
// outputs
	wire octrl_cmd,prg_ch_cmd,pitch_cmd;
	wire[7:0] octrl,octrl_data,prg_ch_data;
	wire [V_WIDTH:0]	active_keys;
	wire 	off_note_error;

	wire ictrl_cmd;
	wire [7:0]ictrl, ictrl_data;

	wire HC_LCD_CLK, HC_VGA_CLOCK;

	wire CLOCK_25;
//	wire OSC_CLK;
	wire sys_pll_locked, audio_pll_locked;

	wire [63:0] lvoice_out;
	wire [63:0] rvoice_out;

//---	Midi	Controllers unit ---//
	wire [6:0]	dec_addr;
	wire [6:0]	adr;
	wire [6:0]	dec_sel_bus;
	wire		env_sel	;
	wire		osc_sel;
	wire		m1_sel;
	wire		m2_sel;
	wire		com_sel;
	wire		read;
	wire		write;
	wire		sysex_data_patch_send;

addr_mux #(.addr_width(7),.num_lines(7)) addr_mux_inst
(
	.clk(CLOCK_25) ,	// input  in_select_sig
	.dataready(dataready) ,	// input  in_select_sig
	.dec_syx(dec_sysex_data_patch_send) ,	// input  dec_syx_sig
	.cpu_and({chipselect,cpu_read}) ,	// input [1:0] cpu_and_sig
	.dec_addr(dec_addr) ,	// input [addr_width-1:0] dec_addr_sig
	.cpu_addr(address) ,	// input [addr_width-1:0] cpu_addr_sig
	.cpu_sel({cpu_write,cpu_read,cpu_sel[5],cpu_sel[3:0]}) ,	// input [num_lines-1:0] cpu_sel_sig
	.dec_sel(dec_sel_bus) ,	// input [num_lines-1:0] dec_sel_sig
	.syx_out (sysex_data_patch_send),
	.addr_out(adr) ,	// output [addr_width-1:0] addr_out_sig
	.sel_out({write,read,com_sel,m2_sel,m1_sel,osc_sel,env_sel}) 	// output [num_lines-1:0] sel_out_sig
);


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
//	`ifdef _271MhzOscs
//		audio_271_pll	audio_pll_inst ( //  271.052632 MHz
//	`else
//		audio_pll	audio_pll_inst ( // 90.416666 Mhz
//	`endif
//	`ifdef _CycloneV
//		.refclk		( EXT_CLOCK_IN ),
//		.outclk_0	( OSC_CLK ),    // 90.416666 Mhz  Mhz
//		.outclk_1	( AUDIO_CLK ),  // 33.906250 Mhz
//		.outclk_2	( AUD_XCK ),    // 16.953125 Mhz
//		.locked		(audio_pll_locked)    //  locked.export
//	`else
//		.inclk0		( EXT_CLOCK_IN ),
//		.c0	( OSC_CLK ),  // 180.555556 Mhz --> 270 Mhz
//		.c1	( AUDIO_CLK ) // 16.927083 Mhz
////		.c1	( ) // 16.927083 Mhz
//	`endif
//	);


//---				---//

synth_controller #(.VOICES(VOICES),.V_WIDTH(V_WIDTH)) synth_controller_inst(

	.reset_reg_N(reset_reg_n) ,		        // input  reset_reg_N_sig
	.CLOCK_25(CLOCK_25) ,				    // input  CLOCK_25_sig
	.socmidi_addr(socmidi_addr) ,			// input  byteready_sig
	.socmidi_data_out(socmidi_data_out) ,	// input  byteready_sig
//	.cpu_com_sel(com_sel) ,				    // input  byteready_sig
	.socmidi_write(socmidi_write) ,			// input  byteready_sig
	.midi_rxd(midi_rxd) ,				    // input  byteready_sig
	.midi_txd(midi_txd) ,			        // input [7:0] cur_status_sig
	.voice_free(voice_free) ,			    // input [VOICES-1:0] voice_free_sig
	.midi_ch(midi_ch) ,				        // input [3:0] midi_ch_sig

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
// controller synth_data bus
	.data_ready(dataready) ,						// output  write_sig
	.read_write (dec_read_write),
	.sysex_data_patch_send (dec_sysex_data_patch_send),
	.dec_addr(dec_addr) ,								// output [6:0] adr_sig
	.synth_data (synth_data) ,							// inout [7:0] data_sig
	.dec_sel_bus( dec_sel_bus) ,					// output  env_sel_sig
	.active_keys(active_keys) ,			// output [V_WIDTH:0] active_keys_sig
    .switch4(switch4)
);


rt_controllers #(.VOICES(VOICES),.V_OSC(V_OSC)) rt_controllers_inst(
	.CLOCK_25			( CLOCK_25 ),
	.reset_data_N		( reset_data_n ),
// from synth_controller
	.ictrl			( octrl ),
	.ictrl_data		( octrl_data ),
	.pitch_cmd		( pitch_cmd ),
// outputs
	.pitch_val		( pitch_val )
);

	//////////// Sound Generation /////////////

//	assign	AUD_ADCLRCK	=	AUD_DACLRCK;

// 2CH Audio Sound output -- Audio Generater //
synth_engine #(.VOICES(VOICES),.V_OSC(V_OSC),.V_ENVS(V_ENVS),.V_WIDTH(V_WIDTH),.O_WIDTH(O_WIDTH),.OE_WIDTH(OE_WIDTH)) synth_engine_inst	(
// AUDIO CODEC //
	.OSC_CLK( OSC_CLK ),				// input
//	.AUD_XCK( AUD_XCK ),				// input
	.reset_reg_N(reset_reg_n) ,			// input  reset_sig
	.reset_data_N		( reset_data_n ),
//	.AUD_BCLK ( AUD_BCLK ),				// output
//	.AUD_DACDAT( AUD_DACDAT ),			// output
//	.AUD_DACLRCK( AUD_DACLRCK ),			// output
	.lsound_out (lsound_out ),      //  Audio Raw Dat
	.rsound_out (rsound_out ),      //  Audio Raw Data
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
	.read (read), 					// input read synth_data signal
	.sysex_data_patch_send (sysex_data_patch_send), // input
	.adr(adr) ,						// input [6:0] adr_sig
	.data (synth_data) ,					// bi-dir [7:0] data_sig
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
