 

`timescale 1 ns / 1 ps

    module audio_i2s_timing_gen
    (
        // Users to add ports here

        // Clock inputs, synthesized in PLL or external TCXOs
        input  wire  aud_44_in_clk,
        input  wire  reset_n,
        // Clock derived outputs
        output       ext_AUD_BCLK,
        output       ext_AUD_DACLRCLK,
        output wire  playback_lrclk,
        output wire  playback_bclk
    );

// Add user logic here

    wire aud_buf_clk;
    wire bclk;
    wire play_lrclk;
    wire reset_synced_n;

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

// clk input buf
 
   // BUFG: General Clock Buffer
   //       Virtex UltraScale+
   // Xilinx HDL Language Template, version 2020.2

   BUFG BUFG_inst (
      .O(aud_buf_clk), // 1-bit output: Clock output.
      .I(aud_44_in_clk)  // 1-bit input: Clock input.
   );

   // End of BUFG_inst instantiation
   
// Output assignments

    assign playback_lrclk   = play_lrclk;
    assign ext_AUD_DACLRCLK   = play_lrclk;

    assign ext_AUD_BCLK = bclk;
    assign playback_bclk = bclk;
    
    syncro2_1 sync_inst_1 (
        .clk(aud_buf_clk),
        .sig1_in(reset_n),
        .sig1_out(reset_synced_n)
    );

    audio_clock_generator playback_gen (
        .clk         (aud_buf_clk),
        .reset_n     (reset_synced_n),
        .cmd_reg1    (32'h00050003),
        .cmd_reg2    (32'h00001717),
        .mclk        (),
        .bclk        (bclk),
        .lrclk1      (play_lrclk),
        .lrclk2      ()
    );

    // User logic ends

    endmodule
