
`timescale 1 ns / 1 ps

	module audio_clk_mux_ip(
		// Users to add ports here
        input  wire [31:0] samplerate,		
        input  wire  sync_clk,
        input  wire  ext_clk44_clkin,
        input  wire  ext_clk48_clkin, // this clock, divided by mclk_devisor, should be 22.
        input  wire  reset_n,
        // Clock derived outputs
        inout  tri   ext_AUD_B_CLK,
        inout  tri   ext_AUD_DACLR_CLK,
        inout  tri   ext_AUD_ADCLR_CLK,
        output wire ext_playback_lrclk,
        output wire ext_capture_lrclk,
        output wire  ext_m_clk,
        output wire  ext_shift_remote_clk // 1 = mclk derived from 44, 0 (default) mclk derived from 48

		// User ports ends
		// Do not modify the ports beyond this line


	);
// Instantiation of core
	audio_clk_mux_ip_v1_1_core # () 
	audio_clk_mux_ip_v1_1_core_inst (
	    .samplerate(samplerate),
	    .sync_clk(sync_clk),
	    .ext_clk44_clkin(ext_clk44_clkin),
        .ext_clk48_clkin(ext_clk48_clkin),
        .reset_n(reset_n),
        .ext_AUD_B_CLK(ext_AUD_B_CLK),
        .ext_AUD_DACLR_CLK(ext_AUD_DACLR_CLK),
        .ext_AUD_ADCLR_CLK(ext_AUD_ADCLR_CLK),
        .ext_playback_lrclk(ext_playback_lrclk),
        .ext_capture_lrclk(ext_capture_lrclk),
        .ext_m_clk(ext_m_clk),
        .ext_shift_remote_clk(ext_shift_remote_clk)
	);

	// Add user logic here

	// User logic ends

	endmodule
