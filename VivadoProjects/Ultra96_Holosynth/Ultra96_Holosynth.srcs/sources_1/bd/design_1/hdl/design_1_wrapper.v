//Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2019.2 (lin64) Build 2708876 Wed Nov  6 21:39:14 MST 2019
//Date        : Sat Mar 28 16:32:54 2020
//Host        : kdeneon-ws running 64-bit Ubuntu 18.04.4 LTS
//Command     : generate_target design_1_wrapper.bd
//Design      : design_1_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module design_1_wrapper
   (Led_out,
    clk_out,
    ext_AUD_ADCLR_CLK_0,
    ext_AUD_B_CLK_0,
    ext_AUD_DACLR_CLK_0,
    midi_rxd_0,
    midi_txd_0,
    oAUD_DACDAT_0);
  output [3:0]Led_out;
  output clk_out;
  inout ext_AUD_ADCLR_CLK_0;
  inout ext_AUD_B_CLK_0;
  inout ext_AUD_DACLR_CLK_0;
  input midi_rxd_0;
  output midi_txd_0;
  output oAUD_DACDAT_0;

  wire [3:0]Led_out;
  wire clk_out;
  wire ext_AUD_ADCLR_CLK_0;
  wire ext_AUD_B_CLK_0;
  wire ext_AUD_DACLR_CLK_0;
  wire midi_rxd_0;
  wire midi_txd_0;
  wire oAUD_DACDAT_0;

  design_1 design_1_i
       (.Led_out(Led_out),
        .clk_out(clk_out),
        .ext_AUD_ADCLR_CLK_0(ext_AUD_ADCLR_CLK_0),
        .ext_AUD_B_CLK_0(ext_AUD_B_CLK_0),
        .ext_AUD_DACLR_CLK_0(ext_AUD_DACLR_CLK_0),
        .midi_rxd_0(midi_rxd_0),
        .midi_txd_0(midi_txd_0),
        .oAUD_DACDAT_0(oAUD_DACDAT_0));
endmodule
