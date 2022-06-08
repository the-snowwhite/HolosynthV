-makelib ies_lib/xilinx_vip -sv \
  "/tools/Xilinx/Vivado/2020.2/data/xilinx_vip/hdl/axi4stream_vip_axi4streampc.sv" \
  "/tools/Xilinx/Vivado/2020.2/data/xilinx_vip/hdl/axi_vip_axi4pc.sv" \
  "/tools/Xilinx/Vivado/2020.2/data/xilinx_vip/hdl/xil_common_vip_pkg.sv" \
  "/tools/Xilinx/Vivado/2020.2/data/xilinx_vip/hdl/axi4stream_vip_pkg.sv" \
  "/tools/Xilinx/Vivado/2020.2/data/xilinx_vip/hdl/axi_vip_pkg.sv" \
  "/tools/Xilinx/Vivado/2020.2/data/xilinx_vip/hdl/axi4stream_vip_if.sv" \
  "/tools/Xilinx/Vivado/2020.2/data/xilinx_vip/hdl/axi_vip_if.sv" \
  "/tools/Xilinx/Vivado/2020.2/data/xilinx_vip/hdl/clk_vip_if.sv" \
  "/tools/Xilinx/Vivado/2020.2/data/xilinx_vip/hdl/rst_vip_if.sv" \
-endlib
-makelib ies_lib/xpm -sv \
  "/tools/Xilinx/Vivado/2020.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
  "/tools/Xilinx/Vivado/2020.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib ies_lib/xpm \
  "/tools/Xilinx/Vivado/2020.2/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../bd/holosynthv/ip/holosynthv_audio_i2s_driver_0_0/sim/holosynthv_audio_i2s_driver_0_0.v" \
  "../../../bd/holosynthv/ip/holosynthv_audio_i2s_timing_gen_0_0/sim/holosynthv_audio_i2s_timing_gen_0_0.v" \
  "../../../bd/holosynthv/ip/holosynthv_audio_mux_0_0/sim/holosynthv_audio_mux_0_0.v" \
  "../../../bd/holosynthv/ip/holosynthv_clk_wiz_0_0/holosynthv_clk_wiz_0_0_clk_wiz.v" \
  "../../../bd/holosynthv/ip/holosynthv_clk_wiz_0_0/holosynthv_clk_wiz_0_0.v" \
-endlib
-makelib ies_lib/fifo_generator_v13_2_5 \
  "../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/276e/simulation/fifo_generator_vlog_beh.v" \
-endlib
-makelib ies_lib/fifo_generator_v13_2_5 \
  "../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/276e/hdl/fifo_generator_v13_2_rfs.vhd" \
-endlib
-makelib ies_lib/fifo_generator_v13_2_5 \
  "../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/276e/hdl/fifo_generator_v13_2_rfs.v" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../bd/holosynthv/ip/holosynthv_fifo_generator_0_0/sim/holosynthv_fifo_generator_0_0.v" \
  "../../../bd/holosynthv/ip/holosynthv_fifo_generator_1_0/sim/holosynthv_fifo_generator_1_0.v" \
  "../../../bd/holosynthv/ip/holosynthv_holosynth_0_0/sim/holosynthv_holosynth_0_0.v" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/431c/src/hm2_axilite_int.vhd" \
  "../../../bd/holosynthv/ip/holosynthv_holosynth_audio_0/sim/holosynthv_holosynth_audio_0.vhd" \
  "../../../bd/holosynthv/ip/holosynthv_holosynth_midi_0/sim/holosynthv_holosynth_midi_0.vhd" \
  "../../../bd/holosynthv/ip/holosynthv_holosynth_sysex_0/sim/holosynthv_holosynth_sysex_0.vhd" \
-endlib
-makelib ies_lib/generic_baseblocks_v2_1_0 \
  "../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/b752/hdl/generic_baseblocks_v2_1_vl_rfs.v" \
-endlib
-makelib ies_lib/axi_infrastructure_v1_1_0 \
  "../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/ec67/hdl/axi_infrastructure_v1_1_vl_rfs.v" \
-endlib
-makelib ies_lib/axi_register_slice_v2_1_22 \
  "../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/af2c/hdl/axi_register_slice_v2_1_vl_rfs.v" \
-endlib
-makelib ies_lib/axi_data_fifo_v2_1_21 \
  "../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/54c0/hdl/axi_data_fifo_v2_1_vl_rfs.v" \
-endlib
-makelib ies_lib/axi_crossbar_v2_1_23 \
  "../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/bc0a/hdl/axi_crossbar_v2_1_vl_rfs.v" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../bd/holosynthv/ip/holosynthv_xbar_0/sim/holosynthv_xbar_0.v" \
-endlib
-makelib ies_lib/axi_protocol_converter_v2_1_22 \
  "../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/5cee/hdl/axi_protocol_converter_v2_1_vl_rfs.v" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../bd/holosynthv/ip/holosynthv_auto_pc_0/sim/holosynthv_auto_pc_0.v" \
-endlib
-makelib ies_lib/lib_cdc_v1_0_2 \
  "../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/ef1e/hdl/lib_cdc_v1_0_rfs.vhd" \
-endlib
-makelib ies_lib/proc_sys_reset_v5_0_13 \
  "../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/8842/hdl/proc_sys_reset_v5_0_vh_rfs.vhd" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../bd/holosynthv/ip/holosynthv_rst_ps8_0_99M_0/sim/holosynthv_rst_ps8_0_99M_0.vhd" \
-endlib
-makelib ies_lib/xlconstant_v1_1_7 \
  "../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/fcfc/hdl/xlconstant_v1_1_vl_rfs.v" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../bd/holosynthv/ip/holosynthv_xlconstant_0_0/sim/holosynthv_xlconstant_0_0.v" \
-endlib
-makelib ies_lib/xlslice_v1_0_2 \
  "../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/11d0/hdl/xlslice_v1_0_vl_rfs.v" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../bd/holosynthv/ip/holosynthv_xlslice_0_0/sim/holosynthv_xlslice_0_0.v" \
-endlib
-makelib ies_lib/axi_vip_v1_1_8 -sv \
  "../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/94c3/hdl/axi_vip_v1_1_vl_rfs.sv" \
-endlib
-makelib ies_lib/zynq_ultra_ps_e_vip_v1_0_8 -sv \
  "../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/da1e/hdl/zynq_ultra_ps_e_vip_v1_0_vl_rfs.sv" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../bd/holosynthv/ip/holosynthv_zynq_ultra_ps_e_0_0/sim/holosynthv_zynq_ultra_ps_e_0_0_vip_wrapper.v" \
  "../../../bd/holosynthv/sim/holosynthv.v" \
-endlib
-makelib ies_lib/xil_defaultlib \
  glbl.v
-endlib

