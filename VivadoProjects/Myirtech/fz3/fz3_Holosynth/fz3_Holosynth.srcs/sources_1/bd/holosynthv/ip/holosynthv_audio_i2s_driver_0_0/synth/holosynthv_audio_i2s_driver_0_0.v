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


// IP VLNV: xilinx.com:module_ref:audio_i2s_driver:1.0
// IP Revision: 1

(* X_CORE_INFO = "audio_i2s_driver,Vivado 2020.2.2" *)
(* CHECK_LICENSE_TYPE = "holosynthv_audio_i2s_driver_0_0,audio_i2s_driver,{}" *)
(* CORE_GENERATION_INFO = "holosynthv_audio_i2s_driver_0_0,audio_i2s_driver,{x_ipProduct=Vivado 2020.2.2,x_ipVendor=xilinx.com,x_ipLibrary=module_ref,x_ipName=audio_i2s_driver,x_ipVersion=1.0,x_ipCoreRevision=1,x_ipLanguage=VERILOG,x_ipSimLanguage=MIXED,AUD_BIT_DEPTH=24}" *)
(* IP_DEFINITION_SOURCE = "module_ref" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module holosynthv_audio_i2s_driver_0_0 (
  reset_reg_N,
  iAUD_DACLRCK,
  iAUDB_CLK,
  i2s_enable,
  i_lsound_out,
  i_rsound_out,
  oAUD_DACDAT
);

(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME reset_reg_N, POLARITY ACTIVE_LOW, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 reset_reg_N RST" *)
input wire reset_reg_N;
input wire iAUD_DACLRCK;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME iAUDB_CLK, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.000, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 iAUDB_CLK CLK" *)
input wire iAUDB_CLK;
input wire i2s_enable;
input wire [23 : 0] i_lsound_out;
input wire [23 : 0] i_rsound_out;
output wire oAUD_DACDAT;

  audio_i2s_driver #(
    .AUD_BIT_DEPTH(24)
  ) inst (
    .reset_reg_N(reset_reg_N),
    .iAUD_DACLRCK(iAUD_DACLRCK),
    .iAUDB_CLK(iAUDB_CLK),
    .i2s_enable(i2s_enable),
    .i_lsound_out(i_lsound_out),
    .i_rsound_out(i_rsound_out),
    .oAUD_DACDAT(oAUD_DACDAT)
  );
endmodule