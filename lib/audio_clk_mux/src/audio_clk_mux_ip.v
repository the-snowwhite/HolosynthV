
`timescale 1 ns / 1 ps

    module audio_clk_mux_ip(
// Users to add ports here
        input  wire  run,
        input  wire  i2s_enable_i,
        input  wire  [31:0] samplerate,
        input  wire  sync_clk,
        input  wire  aud_44_in_clk,
        input  wire  aud_48_in_clk,
        input  wire  reset_n,
// Clock derived outputs
        inout  tri   ext_AUD_BCLK,
        inout  tri   ext_AUD_DACLRCLK,
        inout  tri   ext_AUD_ADCLRCLK,
        output wire  ext_playback_lrclk,
        output wire  ext_shift_remoteclk,
        output wire  i2s_enable_o,
        output wire  ext_mclk,
        output wire  ext_capture_lrclk

// User ports ends
// Do not modify the ports beyond this line


    );
// Instantiation of core
    audio_clk_mux_ip_v1_1_core # () 
    audio_clk_mux_ip_v1_1_core_inst (
        .run(run),
        .samplerate(samplerate),
        .i2s_enable_i(i2s_enable_i),
        .sync_clk(sync_clk),
        .aud_44_in_clk(aud_44_in_clk),
        .aud_48_in_clk(aud_48_in_clk),
        .reset_n(reset_n),
        .ext_AUD_BCLK(ext_AUD_BCLK),
        .ext_AUD_DACLRCLK(ext_AUD_DACLRCLK),
        .ext_AUD_ADCLRCLK(ext_AUD_ADCLRCLK),
        .ext_playback_lrclk(ext_playback_lrclk),
        .ext_shift_remoteclk(ext_shift_remoteclk),
        .i2s_enable_o(i2s_enable_o),
        .ext_mclk(ext_mclk),
        .ext_capture_lrclk(ext_capture_lrclk)
    );

// Add user logic here

// User logic ends

    endmodule
