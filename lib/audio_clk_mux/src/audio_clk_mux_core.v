
`timescale 1 ns / 1 ps

    module audio_clk_mux_core
    (
        // Users to add ports here

        // Clock inputs, synthesized in PLL or external TCXOs
        input  wire  run,
        input  wire  samplerate_is_48,
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
        output wire  ext_mclk,
        output wire  ext_capture_lrclk

        // User ports ends
        // Do not modify the ports beyond this line
    );

// Add user logic here

    reg [31:0]	slv_reg0;
    reg [31:0]  slv_reg4;

    wire slv_reg_wren;
    reg [2:0] wren_dly;

    wire aud_muxed_clk;

    wire bclk;

    wire play_lrclk;
    wire cap_lrclk;

    wire playback_lrclk;
    wire capture_lrclk;
    // In slave mode, an external master makes the clocks
    wire master_slave_mode; // 1 = master, 0 (default) = slave
    
    wire samplerate_is_48_synced;
    
    assign slv_reg_wren = (wren_dly[1] | wren_dly[2]) ? 1'b1 : 1'b0;

/*
    wire cmd_reg2_wr;
    wire mclk44;
    wire bclk44;
    wire playback_lrclk44;
    wire capture_lrclk44;
    wire mclk48;
    wire bclk48;
    wire playback_lrclk48;
    wire capture_lrclk48;

    wire [31:0]  cmd_reg1_44;
    wire [31:0]  cmd_reg2_44;
    wire [31:0]  cmd_reg1_48;
    wire [31:0]  cmd_reg2_48;
    
    wire reset_44_n;
    wire cmd_reg2_44_wr;
    wire reset_48_n;
    wire cmd_reg2_48_wr;
*/    
    wire ext_AUD_BCLK_sig;
    wire ext_AUD_DACLRCLK_sig;
    wire ext_AUD_ADCLRCLK_sig;
    
    // IOBUF: Single-ended Bi-directional Buffer
    // All devices
    // Xilinx HDL Language Template, version 2017.3
    IOBUF #(
        .DRIVE(4), // Specify the output drive strength
        .IBUF_LOW_PWR("TRUE"), // Low Power - "TRUE", High Performance = "FALSE"
        .IOSTANDARD("DEFAULT"), // Specify the I/O standard
        .SLEW("SLOW") // Specify the output slew rate
    ) IOBUF_inst1 (
        .O(ext_AUD_BCLK_sig),// Buffer output
        .IO(ext_AUD_BCLK),// Buffer inout port (connect directly to top-level port)
        .I(ext_shift_remoteclk),  // Buffer input
        .T(~master_slave_mode) // 3-state enable input, high=input, low=output
    );
    // End of IOBUF_inst instantiation

    IOBUF #(
        .DRIVE(4), // Specify the output drive strength
        .IBUF_LOW_PWR("TRUE"), // Low Power - "TRUE", High Performance = "FALSE"
        .IOSTANDARD("DEFAULT"), // Specify the I/O standard
        .SLEW("SLOW") // Specify the output slew rate
    ) IOBUF_inst2 (
        .O(ext_AUD_DACLRCLK_sig),// Buffer output
        .IO(ext_AUD_DACLRCLK),// Buffer inout port (connect directly to top-level port)
        .I(playback_lrclk),  // Buffer input
        .T(~master_slave_mode) // 3-state enable input, high=input, low=output
    );
    // End of IOBUF_inst instantiation

    IOBUF #(
        .DRIVE(4), // Specify the output drive strength
        .IBUF_LOW_PWR("TRUE"), // Low Power - "TRUE", High Performance = "FALSE"
        .IOSTANDARD("DEFAULT"), // Specify the I/O standard
        .SLEW("SLOW") // Specify the output slew rate
    ) IOBUF_inst3 (
        .O(ext_AUD_ADCLRCLK_sig),// Buffer output
        .IO(ext_AUD_ADCLRCLK),// Buffer inout port (connect directly to top-level port)
        .I(capture_lrclk),  // Buffer input
        .T(~master_slave_mode) // 3-state enable input, high=input, low=output
    );
    // End of IOBUF_inst instantiation

    /*
    * Example: Input clock is 24.5760MHz  (48000) slv_reg0 = h0003 0003,  slv_reg4 = h00000F0F
    * mclk_divisor = 0 (divide by (0+1)*2=2) => mclk = 12.288MHz  slv_reg0 --> cmd_reg1[31:24]
    * bclk_divisor = 3 (divide by (3+1)*2=8) => bclk = 3.072MHz   slv_reg0 --> cmd_reg1[23:16]
    * lrclk_divisor = 15 (divide by (15*16+15+1)*2=512) => lrclk = 0.048MHz slv_reg4 --> cmd_reg2[15:8] && cmd_reg2[7:0]
    *
    * Example: Input clock is 33.8688MHz  (44100) slv_reg0 = h0005 0003,  slv_reg4 = h00001717
    * mclk_divisor = 0 (divide by (0+1)*2=2) => mclk = 16.9344MHz  slv_reg0 --> cmd_reg1[31:24]
    * bclk_divisor = 5 (divide by (5+1)*2=12) => bclk = 2.8224MHz   slv_reg0 --> cmd_reg1[23:16]
    * lrclk_divisor = 23 (divide by (23*16+15+1)*2=768 => lrclk = 0.0441MHz slv_reg4 --> cmd_reg2[15:8] && cmd_reg2[7:0]
    */

// input mux

// BUFGMUX_CTRL: 2-to-1 General Clock MUX Buffer
//               Virtex UltraScale+
// Xilinx HDL Language Template, version 2019.2

BUFGMUX_CTRL BUFGMUX_CTRL_inst (
    .O(aud_muxed_clk),   // 1-bit output: Clock output
    .I0(aud_44_in_clk), // 1-bit input: Clock input (S=0)
    .I1(aud_48_in_clk), // 1-bit input: Clock input (S=1)
    .S(samplerate_is_48_synced)    // 1-bit input: Clock select
);

// End of BUFGMUX_CTRL_inst instantiation
    
// Output muxes

    assign ext_playback_lrclk   = master_slave_mode ? playback_lrclk    : ext_AUD_DACLRCLK_sig;
    assign ext_capture_lrclk    = master_slave_mode ? capture_lrclk     : ext_AUD_ADCLRCLK_sig;

    assign ext_shift_remoteclk = master_slave_mode ? bclk : ext_AUD_BCLK_sig;
    assign playback_lrclk       = master_slave_mode ? play_lrclk : ext_playback_lrclk;
    assign capture_lrclk        = master_slave_mode ? cap_lrclk : ext_capture_lrclk;

    // Register access

//    assign master_slave_mode    = slv_reg0[0]; // 1 = master, 0 (default) = slave
    assign master_slave_mode    = 1'b1;; // 1 = master, 0 (default) = slave
//    assign clk_sel_44_48        = slv_reg4[1]; // 1 = mclk derived from 44, 0 (default) mclk derived from 48
    
//    assign cmd_reg2_wr          = ( slv_reg_wren ) ? 1'b1 : 1'b0;

    
    syncro2_2 sync_inst_1 (
        .clk(aud_muxed_clk),
        .sig1_in(reset_n),
        .sig2_in(samplerate_is_48),
        .sig1_out(reset_synced_n),
        .sig2_out(samplerate_is_48_synced)
    );


    always @( posedge aud_muxed_clk )
    begin
        if (samplerate_is_48_synced) begin
            slv_reg0 <= 32'h00030003;
            slv_reg4 <= 32'h00000F0F;
        end
        else begin
            slv_reg0 <= 32'h00050003;
            slv_reg4 <= 32'h00001717;
        end
    end  
    
    audio_clock_generator playback_gen (
        .clk         (aud_muxed_clk),
        .reset_n     (reset_synced_n),
        .cmd_reg1    (slv_reg0),
        .cmd_reg2    (slv_reg4),
        .mclk        (ext_mclk),
        .bclk        (bclk),
        .lrclk1      (play_lrclk),
        .lrclk2      (cap_lrclk)
    );
/*    
    syncro32 sync32_inst44_1 (
        .clka_clkin(sync_clk),
        .clkb_clkin(ext_clk44_clkin),
        .wr_en(cmd_reg2_44_wr),
        .sig_in(slv_reg0),
        .sig_out(cmd_reg1_44)
    );
    
    syncro32 sync32_inst44_2 (
        .clka_clkin(sync_clk),
        .clkb_clkin(ext_clk44_clkin),
        .wr_en(cmd_reg2_44_wr),
        .sig_in(slv_reg4),
        .sig_out(cmd_reg2_44)
    );
    
    syncro sync_inst48 (
        .clka_clkin(sync_clk),
        .clkb_clkin(ext_clk48_clkin),
        .sig1_in(reset_n),
        .sig2_in(slv_reg_wren),
        .sig1_out(reset_48_n),
        .sig2_out(cmd_reg2_48_wr)
    );
    
    syncro32 sync32_inst48_1 (
        .clka_clkin(sync_clk),
        .clkb_clkin(ext_clk48_clkin),
        .wr_en(cmd_reg2_48_wr),
        .sig_in(slv_reg0),
        .sig_out(cmd_reg1_48)
    );
    
    syncro32 sync32_inst48_2 (
        .clka_clkin(sync_clk),
        .clkb_clkin(ext_clk48_clkin),
        .wr_en(cmd_reg2_48_wr),
        .sig_in(slv_reg4),
        .sig_out(cmd_reg2_48)
    );
    
    audio_clock_generator playback_gen44 (
        .clk_clkin   (ext_clk44_clkin),
        .reset_n     (reset_44_n & ~cmd_reg2_44_wr),
        .cmd_reg1    (cmd_reg1_44),
        .cmd_reg2    (cmd_reg2_44),
        .mclk        (mclk44),
        .bclk        (bclk44),
        .lrclk_clear (cmd_reg2_44_wr),
        .lrclk1      (playback_lrclk44),
        .lrclk2      (capture_lrclk44)
    );
    
    audio_clock_generator playback_gen48 (
        .clk_clkin   (ext_clk48_clkin),
        .reset_n     (reset_48_n & ~cmd_reg2_48_wr),
        .cmd_reg1    (cmd_reg1_48),
        .cmd_reg2    (cmd_reg2_48),
        .mclk        (mclk48),
        .bclk        (bclk48),
        .lrclk_clear (cmd_reg2_48_wr),
        .lrclk1      (playback_lrclk48),
        .lrclk2      (capture_lrclk48)
    );
*/
    // User logic ends

    endmodule
