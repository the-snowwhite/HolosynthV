// (c) Copyright 1995-2021 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
// DO NOT MODIFY THIS FILE.


// IP VLNV: xilinx.com:module_ref:holosynth:1.0
// IP Revision: 1

`timescale 1ns/1ps

(* IP_DEFINITION_SOURCE = "module_ref" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module holosynthv_holosynth_0_0 (
  reg_clk,
  AUDIO_CLK,
  reset_reg_n,
  reset_data_n,
  trig,
  midi_rxd,
  midi_txd,
  active_keys,
  lsound_out,
  rsound_out,
  xxxx_zero,
  xxxx_top,
  cpu_read,
  cpu_write,
  cpu_chip_sel,
  cpu_addr,
  cpu_readdata,
  cpu_writedata,
  socmidi_read,
  socmidi_write,
  socmidi_addr,
  socmidi_data_in,
  socmidi_data_out,
  run
);

(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME reg_clk, FREQ_HZ 50000000, FREQ_TOLERANCE_HZ 0, PHASE 0.000, CLK_DOMAIN holosynthv_zynq_ultra_ps_e_0_0_pl_clk0, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 reg_clk CLK" *)
input wire reg_clk;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME AUDIO_CLK, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.000, CLK_DOMAIN holosynthv_zynq_ultra_ps_e_0_0_pl_clk1, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 AUDIO_CLK CLK" *)
input wire AUDIO_CLK;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME reset_reg_n, POLARITY ACTIVE_LOW, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 reset_reg_n RST" *)
input wire reset_reg_n;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME reset_data_n, POLARITY ACTIVE_LOW, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 reset_data_n RST" *)
input wire reset_data_n;
input wire trig;
input wire midi_rxd;
output wire midi_txd;
output wire [5 : 0] active_keys;
output wire [23 : 0] lsound_out;
output wire [23 : 0] rsound_out;
output wire xxxx_zero;
output wire xxxx_top;
input wire cpu_read;
input wire cpu_write;
input wire cpu_chip_sel;
input wire [9 : 0] cpu_addr;
input wire [7 : 0] cpu_readdata;
output wire [7 : 0] cpu_writedata;
input wire socmidi_read;
input wire socmidi_write;
input wire [2 : 0] socmidi_addr;
input wire [7 : 0] socmidi_data_in;
output wire [7 : 0] socmidi_data_out;
output wire run;

  holosynth #(
    .a_NUM_VOICES(32),
    .V_WIDTH(5),
    .b_NUM_OSCS_PER_VOICE(8),
    .c_NUM_ENVGENS_PER_OSC(2),
    .V_ENVS(16),
    .AUD_BIT_DEPTH(24),
    .Invert_rxd(0),
    .REG_CLK_FREQUENCY(50000000)
  ) inst (
    .reg_clk(reg_clk),
    .AUDIO_CLK(AUDIO_CLK),
    .reset_reg_n(reset_reg_n),
    .reset_data_n(reset_data_n),
    .trig(trig),
    .midi_rxd(midi_rxd),
    .midi_txd(midi_txd),
    .active_keys(active_keys),
    .lsound_out(lsound_out),
    .rsound_out(rsound_out),
    .xxxx_zero(xxxx_zero),
    .xxxx_top(xxxx_top),
    .cpu_read(cpu_read),
    .cpu_write(cpu_write),
    .cpu_chip_sel(cpu_chip_sel),
    .cpu_addr(cpu_addr),
    .cpu_readdata(cpu_readdata),
    .cpu_writedata(cpu_writedata),
    .socmidi_read(socmidi_read),
    .socmidi_write(socmidi_write),
    .socmidi_addr(socmidi_addr),
    .socmidi_data_in(socmidi_data_in),
    .socmidi_data_out(socmidi_data_out),
    .run(run)
  );
endmodule
