module holosynth #(
parameter a_NUM_VOICES = 32,
parameter b_NUM_OSCS_PER_VOICE = 8, // number of oscilators pr. voice.
parameter c_NUM_ENVGENS_PER_OSC = 2,			// number of envelope generators pr. oscilator.
parameter V_ENVS = b_NUM_OSCS_PER_VOICE * c_NUM_ENVGENS_PER_OSC,
parameter AUD_BIT_DEPTH = 24
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

    output wire [31:0]  lsound_out,
    output wire [31:0]  rsound_out,

    output wire         xxxx_zero,

    input  wire         cpu_read,
    input  wire         cpu_write,
    input  wire         cpu_chip_sel,
    input  wire [11:2]  cpu_addr,
    input  wire [7:0]   data_from_cpu,
    output wire [7:0]   data_to_cpu,
    input  wire         socmidi_read,
    input  wire         socmidi_write,
//    input                socmidi_cs,
    input  wire [2:0]   socmidi_addr,
    input  wire [7:0]   socmidi_data_from_cpu,
    output wire [7:0]   socmidi_data_to_cpu,
    output wire         run,
    input  wire         uart_usb_sel
);

    wire txd;
    assign midi_txd = ~txd;
    
    synthesizer #(.VOICES(a_NUM_VOICES),.V_OSC(b_NUM_OSCS_PER_VOICE),.O_ENVS(c_NUM_ENVGENS_PER_OSC),.AUD_BIT_DEPTH(AUD_BIT_DEPTH))  synthesizer_inst(
        .CLOCK_50               (fpga_clk) ,
        .AUDIO_CLK              (AUDIO_CLK),             // input
        .reset_n                (reset_n),
        .trig                   (AUD_DACLRCK),
        .MIDI_Rx_DAT            (~midi_rxd) ,   // input  MIDI_DAT_sig (inverted due to inverter in rs232 chip)
        .midi_txd               (txd),		    // output midi transmit signal (inverted due to inverter in rs232 chip)
        .button                 (4'b1111),            //  Button[3:0]
        .lsound_out             (lsound_out[31:8] ),      //  Audio Raw Data Low
        .rsound_out             (rsound_out[31:8] ),      //  Audio Raw Data high
        .xxxx_zero              (xxxx_zero),                // output  cycle complete signag
        .keys_on                (keys_on),				//  LED [7:0]
        .voice_free             (voice_free) , 			//  Red LED [4:1]
        .io_reset_n             (reset_n) ,	// input  io_reset_sig
        .address                (cpu_addr) ,	// input [9:0] address_sig
        .cpu_write              (cpu_write) ,	// input  cpu_write_sig
        .cpu_read               (cpu_read) ,	// input  cpu_read_sig
        .chipselect             (cpu_chip_sel) ,	// input  chipselect_sig
        .data_to_cpu            (data_to_cpu) ,	// output [31:0] writedata_sig
        .data_from_cpu          (data_from_cpu), 	// input [31:0] readdata_sig
        .socmidi_addr           (socmidi_addr) ,	// input [9:0] address_sig
        .socmidi_write          (socmidi_write) ,	// input  cpu_write_sig
        .socmidi_read           (socmidi_read) ,	// input  cpu_read_sig
//        .socmidi_cs             (socmidi_chip_sel) ,	// input  chipselect_sig
        .socmidi_data_from_cpu  (socmidi_data_from_cpu) ,	// input [31:0] writedata_sig
        .socmidi_data_to_cpu    (socmidi_data_to_cpu), 	// output [31:0] readdata_sig
        .run                    (run),
//        .switch3                (uart_usb_sel)
        .uart_usb_sel           (1'b1)
    );
    
endmodule
