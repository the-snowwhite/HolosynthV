//Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2020.2 (lin64) Build 3064766 Wed Nov 18 09:12:47 MST 2020
//Date        : Fri Feb 19 16:46:48 2021
//Host        : kdeneon-ws3 running 64-bit Ubuntu 18.04.5 LTS
//Command     : generate_target holosynthv_wrapper.bd
//Design      : holosynthv_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module holosynthv_wrapper
   (Led_out,
    ext_AUD_ADCLRCLK_0,
    ext_AUD_BCLK_0,
    ext_AUD_DACLRCLK_0,
    midi_rxd_0,
    midi_txd_0,
    oAUD_DACDAT_0);
  output [3:0]Led_out;
  inout ext_AUD_ADCLRCLK_0;
  inout ext_AUD_BCLK_0;
  inout ext_AUD_DACLRCLK_0;
  input midi_rxd_0;
  output midi_txd_0;
  output oAUD_DACDAT_0;

  wire [3:0]Led_out;
  wire ext_AUD_ADCLRCLK_0;
  wire ext_AUD_BCLK_0;
  wire ext_AUD_DACLRCLK_0;
  wire midi_rxd_0;
  wire midi_txd_0;
  wire oAUD_DACDAT_0;

  holosynthv holosynthv_i
       (.Led_out(Led_out),
        .ext_AUD_ADCLRCLK_0(ext_AUD_ADCLRCLK_0),
        .ext_AUD_BCLK_0(ext_AUD_BCLK_0),
        .ext_AUD_DACLRCLK_0(ext_AUD_DACLRCLK_0),
        .midi_rxd_0(midi_rxd_0),
        .midi_txd_0(midi_txd_0),
        .oAUD_DACDAT_0(oAUD_DACDAT_0));
endmodule
