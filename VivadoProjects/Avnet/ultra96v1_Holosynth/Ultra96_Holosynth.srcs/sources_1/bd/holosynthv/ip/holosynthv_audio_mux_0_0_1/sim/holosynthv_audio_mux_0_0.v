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


// IP VLNV: xilinx.com:module_ref:audio_mux:1.0
// IP Revision: 1

`timescale 1ns/1ps

(* IP_DEFINITION_SOURCE = "module_ref" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module holosynthv_audio_mux_0_0 (
  clk,
  address,
  read,
  write,
  datain,
  lsound_in,
  rsound_in,
  xxxx_top,
  lrck,
  run,
  dataout,
  l_read,
  r_read,
  sample_ready,
  trig,
  i2s_enable
);

(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME clk, FREQ_HZ 50000000, PHASE 0.000, CLK_DOMAIN holosynthv_zynq_ultra_ps_e_0_0_pl_clk0, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 clk CLK" *)
input wire clk;
input wire [1 : 0] address;
input wire read;
input wire write;
input wire [31 : 0] datain;
input wire [23 : 0] lsound_in;
input wire [23 : 0] rsound_in;
input wire xxxx_top;
input wire lrck;
input wire run;
output wire [31 : 0] dataout;
output wire l_read;
output wire r_read;
output wire sample_ready;
output wire trig;
output wire i2s_enable;

  audio_mux #(
    .FIFO_WIDTH(6),
    .AUD_BIT_DEPTH(24)
  ) inst (
    .clk(clk),
    .address(address),
    .read(read),
    .write(write),
    .datain(datain),
    .lsound_in(lsound_in),
    .rsound_in(rsound_in),
    .xxxx_top(xxxx_top),
    .lrck(lrck),
    .run(run),
    .dataout(dataout),
    .l_read(l_read),
    .r_read(r_read),
    .sample_ready(sample_ready),
    .trig(trig),
    .i2s_enable(i2s_enable)
  );
endmodule
