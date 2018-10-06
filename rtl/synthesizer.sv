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
`define _Synth
`define _24BitAudio

module synthesizer #(
parameter VOICES = 32,
parameter V_OSC = 4,				// number of oscilators pr. voice.
parameter O_ENVS = 2,				// number of envelope generators pr. oscilator.
parameter V_ENVS = V_OSC * O_ENVS,	// number of envelope generators  pr. voice.
parameter V_WIDTH = utils::clogb2(VOICES),
parameter O_WIDTH = utils::clogb2(V_OSC),
parameter OE_WIDTH = utils::clogb2(O_ENVS),
parameter E_WIDTH = O_WIDTH + OE_WIDTH
) (
// Clock
    input wire          CLOCK_50,
    input wire              AUDIO_CLK,
// reset
    input wire              reset_n,
    input wire              trig,
// MIDI uart
    input wire              MIDI_Rx_DAT,
    output wire             midi_txd,

    input wire  [4:1]       button,
    output wire [VOICES-1:0] keys_on,
    output wire [VOICES-1:0] voice_free,

`ifdef _32BitAudio
    output wire signed [31:0]      lsound_out,
    output wire signed [31:0]      rsound_out,
`elsif _24BitAudio
    output wire signed [23:0]      lsound_out,
    output wire signed [23:0]      rsound_out,
`else
    output wire signed [15:0]      lsound_out,
    output wire signed [15:0]      rsound_out,
`endif
    output wire             xxxx_zero,

    input wire              io_reset_n,
    input wire              cpu_read,
    input wire              cpu_write,
    input wire              chipselect,
    input wire  [9:0]       address,
    input wire  [31:0]      writedata,
    output reg  [31:0]  readdata,
    input wire              socmidi_read,
    input wire              socmidi_write,
    input wire              socmidi_cs,
    input wire  [2:0]       socmidi_addr,
    input wire  [7:0]       socmidi_data_out,
    output reg [7:0]    socmidi_data_in,
    output wire             run,
    input wire              switch3
);

//-----		Registers		-----//
// io:

    reg                 write_delay;
    reg                 reg_w_act;
    reg signed [7:0]    indata;
    wire [5:0]          cpu_sel;
    wire signed [7:0]   synth_data;
    wire w_act;
    wire write_active;
    wire io_reset;
    assign w_act = (cpu_write | write_delay);
    assign write_active = (cpu_write | reg_w_act);
    assign io_reset = ~io_reset_n;

    assign synth_data = (!cpu_read && write_active) ? indata : 8'bz;

always @(posedge CLOCK_50) begin
    write_delay <= cpu_write;
    reg_w_act <= w_act;
end

always @(posedge CLOCK_50) begin
    if (io_reset) begin
        readdata[7:0] <= 8'b0;
    end
    else if (read) begin
            readdata[7:0] <= (com_sel && adr == 2) ? out_data : synth_data;
    end
    else if	(write) begin
        indata <= writedata[7:0];
    end
end


    reg [7:0] midi_ch;
    reg [7:0] out_data;

/** @brief write data
*/
    always@(negedge reset_reg_N or negedge write)begin
        if(!reset_reg_N) begin
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
    .clk(CLOCK_50) ,	// input  clk_sig
    .reset(io_reset) ,	// input  reset_sig
    .address(address[9:7]) ,	// input [addr_width-1:0] address_sig
    .sel(cpu_sel[5:0]) 	// output [num_lines:0] sel_sig
);

    wire data_DLY0, data_DLY1, data_DLY2, reg_DLY0, reg_DLY1, reg_DLY2;

    wire reg_reset_N;
    wire data_reset_N;
    wire reset_data_n;

    assign reg_reset_N = button[1] & reset_n;
    assign data_reset_N = button[2];

    wire reset_reg_N = reg_DLY2;
    assign reset_data_n = data_DLY1;

//---	Midi	---//
// inputs
    wire midi_rxd;
    assign midi_rxd = MIDI_Rx_DAT; // Direct to optocopler RS-232 port (fix it in in topfile)
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

//    wire OSC_CLK;
    wire audio_pll_locked;

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
    .clk(CLOCK_50) ,	// input  in_select_sig
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
    .iCLK(CLOCK_50),
    .reset_reg_N(reg_reset_N),
    .oRST_0(reg_DLY0),
    .oRST_1(reg_DLY1),
    .oRST_2(reg_DLY2)
);

reset_delay	reset_data_delay_inst  (
    .iCLK(CLOCK_50),
    .reset_reg_N(data_reset_N),
    .oRST_0(data_DLY0),
    .oRST_1(data_DLY1),
    .oRST_2(data_DLY2)
);

    // Sound clk gen //
`ifdef _Synth

synth_controller #(.VOICES(VOICES),.V_WIDTH(V_WIDTH)) synth_controller_inst(

    .reset_reg_N(reset_reg_N) ,
    .CLOCK_50(CLOCK_50) ,
    .socmidi_addr(socmidi_addr) ,
    .socmidi_data_out(socmidi_data_out) ,
    .socmidi_write(socmidi_write) ,
    .midi_rxd(midi_rxd) ,
    .midi_txd(midi_txd) ,
    .voice_free(voice_free) ,
    .midi_ch(midi_ch) ,

    .note_on(note_on) ,
    .keys_on(keys_on) ,
    .cur_key_adr(cur_key_adr) ,
    .cur_key_val(cur_key_val) ,
    .cur_vel_on(cur_vel_on) ,
    .cur_vel_off(cur_vel_off) ,
    .pitch_cmd(pitch_cmd) ,
    .octrl(octrl) ,
    .octrl_data(octrl_data) ,
    .prg_ch_cmd(prg_ch_cmd) ,
    .prg_ch_data(prg_ch_data) ,
// controller data bus
    .data_ready(dataready) ,
    .read_write (dec_read_write),
    .sysex_data_patch_send (dec_sysex_data_patch_send),
    .dec_addr(dec_addr) ,
    .synth_data (synth_data) ,
    .dec_sel_bus( dec_sel_bus) ,
    .active_keys(active_keys) ,
    .switch3(switch3)
);


rt_controllers #(.VOICES(VOICES),.V_OSC(V_OSC)) rt_controllers_inst(
    .CLOCK_50       ( CLOCK_50 ),
    .reset_data_N   ( reset_data_n ),
// from synth_controller
    .ictrl          ( octrl ),
    .ictrl_data     ( octrl_data ),
    .pitch_cmd      ( pitch_cmd ),
// outputs
    .pitch_val      ( pitch_val )
);

    //////////// Sound Generation /////////////

// 2CH Audio Sound output -- Audio Generater //
synth_engine #(.VOICES(VOICES),.V_OSC(V_OSC),.V_ENVS(V_ENVS),.V_WIDTH(V_WIDTH),.O_WIDTH(O_WIDTH),.OE_WIDTH(OE_WIDTH)) synth_engine_inst	(
// AUDIO CODEC //
    .AUDIO_CLK              ( AUDIO_CLK ),              // input
    .reset_reg_N            ( reset_reg_N ) ,           // input  reset_sig
    .reset_data_N           ( reset_data_n ),
    .trig                   ( trig ),
    .lsound_out             ( lsound_out ),             //  Audio Raw Dat
    .rsound_out             ( rsound_out ),             //  Audio Raw Data
    .xxxx_zero              ( xxxx_zero) ,              // output  cycle complete signag
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
// controller data bus
    .write                  ( write) ,                  // input  write_sig
    .read                   ( read),                    // input read synth_data signal
    .sysex_data_patch_send  ( sysex_data_patch_send),   // input
    .adr                    ( adr) ,                    // input [6:0] adr_sig
    .data                   ( synth_data ) ,
    .env_sel                ( env_sel ) ,
    .osc_sel                ( osc_sel ) ,
    .m1_sel                 ( m1_sel ) ,
    .m2_sel                 ( m2_sel ) ,
    .com_sel                ( com_sel ),
// from env gen //
    .run                    ( run ),
    .voice_free             ( voice_free )              //output from envgen
);
`endif



endmodule
