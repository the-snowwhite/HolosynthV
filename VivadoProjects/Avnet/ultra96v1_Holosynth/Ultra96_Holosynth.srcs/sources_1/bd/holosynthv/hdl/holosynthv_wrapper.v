//Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2020.1 (lin64) Build 2902540 Wed May 27 19:54:35 MDT 2020
//Date        : Thu Jan 28 02:24:58 2021
//Host        : kdeneon-ws3 running 64-bit Ubuntu 18.04.4 LTS
//Command     : generate_target holosynthv_wrapper.bd
//Design      : holosynthv_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module holosynthv_wrapper
   (BT_ctsn,
    BT_rtsn,
    Led_out,
    ext_AUD_ADCLRCLK_0,
    ext_AUD_BCLK_0,
    ext_AUD_DACLRCLK_0,
    midi_rxd_0,
    midi_txd_0,
    oAUD_DACDAT_0);
  input BT_ctsn;
  output BT_rtsn;
  output [3:0]Led_out;
  inout ext_AUD_ADCLRCLK_0;
  inout ext_AUD_BCLK_0;
  inout ext_AUD_DACLRCLK_0;
  input midi_rxd_0;
  output midi_txd_0;
  output oAUD_DACDAT_0;

  wire BT_ctsn;
  wire BT_rtsn;
  wire [3:0]Led_out;
  wire ext_AUD_ADCLRCLK_0;
  wire ext_AUD_BCLK_0;
  wire ext_AUD_DACLRCLK_0;
  wire midi_rxd_0;
  wire midi_txd_0;
  wire oAUD_DACDAT_0;

  holosynthv holosynthv_i
       (.BT_ctsn(BT_ctsn),
        .BT_rtsn(BT_rtsn),
        .Led_out(Led_out),
        .ext_AUD_ADCLRCLK_0(ext_AUD_ADCLRCLK_0),
        .ext_AUD_BCLK_0(ext_AUD_BCLK_0),
        .ext_AUD_DACLRCLK_0(ext_AUD_DACLRCLK_0),
        .midi_rxd_0(midi_rxd_0),
        .midi_txd_0(midi_txd_0),
        .oAUD_DACDAT_0(oAUD_DACDAT_0));
endmodule
