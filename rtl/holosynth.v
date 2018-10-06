`define _Synth
`define _24BitAudio

module holosynth #(
parameter a_NUM_VOICES = 32,
parameter b_NUM_OSCS_PER_VOICE = 8, // number of oscilators pr. voice.
parameter c_NUM_ENVGENS_PER_OSC = 2,			// number of envelope generators pr. oscilator.
parameter V_ENVS = b_NUM_OSCS_PER_VOICE * c_NUM_ENVGENS_PER_OSC	// number of envelope generators  pr. voice.
) (
// Clock
    input  wire         fpga_clk,
    input  wire         AUDIO_CLK,
// reset
    input  wire         reset_n,
    input  wire         AUD_DACLRCK,
// MIDI uart
    input  wire         midi_rxd,
    output wire         midi_txd,

//    input   [3:0]        button,
    output [a_NUM_VOICES-1:0] keys_on,
    output [a_NUM_VOICES-1:0] voice_free,

`ifdef _32BitAudio
    output wire [31:0]  lsound_out,
    output wire [31:0]  rsound_out,
`elsif _24BitAudio
    output wire [23:0]  lsound_out,
    output wire [23:0]  rsound_out,
`else
    output wire [15:0]  lsound_out,
    output wire [15:0]  rsound_out,
`endif
    output wire          xxxx_zero,

    input  wire          cpu_read,
    input  wire          cpu_write,
    input  wire          cpu_chip_sel,
    input  wire [9:0]    cpu_addr,
    input  wire [31:0]   cpu_data_in,
    output wire [31:0]   cpu_data_out,
    input  wire          socmidi_read,
    input  wire          socmidi_write,
//    input                socmidi_cs,
    input  wire [2:0]    socmidi_addr,
    input  wire [7:0]    socmidi_data_in,
    output wire [7:0]    socmidi_data_out,
    output wire          run,
    input  wire          uart_usb_sel
);
    
    synthesizer #(.VOICES(a_NUM_VOICES),.V_OSC(b_NUM_OSCS_PER_VOICE),.O_ENVS(c_NUM_ENVGENS_PER_OSC))  synthesizer_inst(
        .CLOCK_50               (fpga_clk) ,
        .AUDIO_CLK              (AUDIO_CLK),             // input
        .reset_n                (reset_n),
        .trig                   (AUD_DACLRCK),
        .MIDI_Rx_DAT            (midi_rxd) ,    // input  MIDI_DAT_sig (inverted due to inverter in rs232 chip)
        .midi_txd               (midi_txd),		// output midi transmit signal (inverted due to inverter in rs232 chip)
        .button                 (4'b1111),            //  Button[3:0]
    `ifdef _Synth
        `ifdef _32BitAudio
        .lsound_out             (lsound_out[31:0] ),      //  Audio Raw Data Low
        .rsound_out             (rsound_out[31:0] ),      //  Audio Raw Data high
        `elsif _24BitAudio
        .lsound_out             (lsound_out[23:0] ),      //  Audio Raw Data Low
        .rsound_out             (rsound_out[23:0] ),      //  Audio Raw Data high
        `else
        .lsound_out             (lsound_out[15:0] ),      //  Audio Raw Data Low
        .rsound_out             (rsound_out[15:0] ),      //  Audio Raw Data high
        `endif
        .xxxx_zero              (xxxx_zero),                // output  cycle complete signag
    `endif
        .keys_on                (keys_on),				//  LED [7:0]
        .voice_free             (voice_free) , 			//  Red LED [4:1]
//        .io_reset_n             (reset_n) ,	// input  io_reset_sig
        .cpu_addr               (cpu_addr) ,	// input [9:0] address_sig
        .cpu_write              (cpu_write) ,	// input  cpu_write_sig
        .cpu_read               (cpu_read) ,	// input  cpu_read_sig
        .cpu_chip_sel           (cpu_chip_sel) ,	// input  chipselect_sig
        .cpu_data_in            (cpu_data_in) ,	// input [31:0] writedata_sig
        .cpu_data_out           (cpu_data_out), 	// output [31:0] readdata_sig
        .socmidi_addr           (socmidi_addr) ,	// input [9:0] address_sig
        .socmidi_write          (socmidi_write) ,	// input  cpu_write_sig
        .socmidi_read           (socmidi_read) ,	// input  cpu_read_sig
//        .socmidi_cs             (socmidi_chip_sel) ,	// input  chipselect_sig
        .socmidi_data_in        (socmidi_data_in) ,	// input [31:0] writedata_sig
        .socmidi_data_out       (socmidi_data_out), 	// output [31:0] readdata_sig
        .run                    (run),
//        .switch3                (uart_usb_sel)
        .uart_usb_sel           (1'b1)
    );
    
endmodule
