//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2022.1 (lin64) Build 3526262 Mon Apr 18 15:47:01 MDT 2022
//Date        : Fri Jun 10 17:47:08 2022
//Host        : neon-ws running 64-bit Ubuntu 20.04.4 LTS
//Command     : generate_target holosynthv_wrapper.bd
//Design      : holosynthv_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module holosynthv_wrapper
   (Led_out,
    ext_AUD_BCLK_0,
    ext_AUD_DACLRCLK_0,
    midi_rxd_0,
    midi_txd_0,
    oAUD_DACDAT_0);
  output [2:0]Led_out;
  output ext_AUD_BCLK_0;
  output ext_AUD_DACLRCLK_0;
  input midi_rxd_0;
  output midi_txd_0;
  output oAUD_DACDAT_0;

  wire [2:0]Led_out;
  wire ext_AUD_BCLK_0;
  wire ext_AUD_DACLRCLK_0;
  wire midi_rxd_0;
  wire midi_txd_0;
  wire oAUD_DACDAT_0;

  holosynthv holosynthv_i
       (.Led_out(Led_out),
        .ext_AUD_BCLK_0(ext_AUD_BCLK_0),
        .ext_AUD_DACLRCLK_0(ext_AUD_DACLRCLK_0),
        .midi_rxd_0(midi_rxd_0),
        .midi_txd_0(midi_txd_0),
        .oAUD_DACDAT_0(oAUD_DACDAT_0));
endmodule
