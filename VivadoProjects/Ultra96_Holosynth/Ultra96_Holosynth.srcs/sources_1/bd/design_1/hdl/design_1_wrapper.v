//Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2018.2 (lin64) Build 2258646 Thu Jun 14 20:02:38 MDT 2018
//Date        : Tue Dec 11 22:44:09 2018
//Host        : kdeneon-ws running 64-bit KDE neon User Edition 5.14
//Command     : generate_target design_1_wrapper.bd
//Design      : design_1_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module design_1_wrapper
   (BT_ctsn,
    BT_rtsn,
    Led_out,
    ext_AUD_ADCLR_CLK_0,
    ext_AUD_B_CLK_0,
    ext_AUD_DACLR_CLK_0,
    midi_rxd_0,
    midi_txd_0,
    oAUD_DACDAT_0);
  input BT_ctsn;
  output BT_rtsn;
  output [3:0]Led_out;
  inout ext_AUD_ADCLR_CLK_0;
  inout ext_AUD_B_CLK_0;
  inout ext_AUD_DACLR_CLK_0;
  input midi_rxd_0;
  output midi_txd_0;
  output oAUD_DACDAT_0;

  wire BT_ctsn;
  wire BT_rtsn;
  wire [3:0]Led_out;
  wire ext_AUD_ADCLR_CLK_0;
  wire ext_AUD_B_CLK_0;
  wire ext_AUD_DACLR_CLK_0;
  wire midi_rxd_0;
  wire midi_txd_0;
  wire oAUD_DACDAT_0;

  design_1 design_1_i
       (.BT_ctsn(BT_ctsn),
        .BT_rtsn(BT_rtsn),
        .Led_out(Led_out),
        .ext_AUD_ADCLR_CLK_0(ext_AUD_ADCLR_CLK_0),
        .ext_AUD_B_CLK_0(ext_AUD_B_CLK_0),
        .ext_AUD_DACLR_CLK_0(ext_AUD_DACLR_CLK_0),
        .midi_rxd_0(midi_rxd_0),
        .midi_txd_0(midi_txd_0),
        .oAUD_DACDAT_0(oAUD_DACDAT_0));
endmodule
