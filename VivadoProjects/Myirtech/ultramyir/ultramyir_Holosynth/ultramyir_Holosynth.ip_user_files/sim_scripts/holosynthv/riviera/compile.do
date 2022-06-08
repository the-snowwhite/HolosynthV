vlib work
vlib riviera

vlib riviera/xilinx_vip
vlib riviera/xpm
vlib riviera/xil_defaultlib
vlib riviera/fifo_generator_v13_2_5
vlib riviera/generic_baseblocks_v2_1_0
vlib riviera/axi_infrastructure_v1_1_0
vlib riviera/axi_register_slice_v2_1_22
vlib riviera/axi_data_fifo_v2_1_21
vlib riviera/axi_crossbar_v2_1_23
vlib riviera/axi_protocol_converter_v2_1_22
vlib riviera/lib_cdc_v1_0_2
vlib riviera/proc_sys_reset_v5_0_13
vlib riviera/xlconstant_v1_1_7
vlib riviera/xlslice_v1_0_2
vlib riviera/axi_vip_v1_1_8
vlib riviera/zynq_ultra_ps_e_vip_v1_0_8

vmap xilinx_vip riviera/xilinx_vip
vmap xpm riviera/xpm
vmap xil_defaultlib riviera/xil_defaultlib
vmap fifo_generator_v13_2_5 riviera/fifo_generator_v13_2_5
vmap generic_baseblocks_v2_1_0 riviera/generic_baseblocks_v2_1_0
vmap axi_infrastructure_v1_1_0 riviera/axi_infrastructure_v1_1_0
vmap axi_register_slice_v2_1_22 riviera/axi_register_slice_v2_1_22
vmap axi_data_fifo_v2_1_21 riviera/axi_data_fifo_v2_1_21
vmap axi_crossbar_v2_1_23 riviera/axi_crossbar_v2_1_23
vmap axi_protocol_converter_v2_1_22 riviera/axi_protocol_converter_v2_1_22
vmap lib_cdc_v1_0_2 riviera/lib_cdc_v1_0_2
vmap proc_sys_reset_v5_0_13 riviera/proc_sys_reset_v5_0_13
vmap xlconstant_v1_1_7 riviera/xlconstant_v1_1_7
vmap xlslice_v1_0_2 riviera/xlslice_v1_0_2
vmap axi_vip_v1_1_8 riviera/axi_vip_v1_1_8
vmap zynq_ultra_ps_e_vip_v1_0_8 riviera/zynq_ultra_ps_e_vip_v1_0_8

vlog -work xilinx_vip  -sv2k12 "+incdir+/tools/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"/tools/Xilinx/Vivado/2020.2/data/xilinx_vip/hdl/axi4stream_vip_axi4streampc.sv" \
"/tools/Xilinx/Vivado/2020.2/data/xilinx_vip/hdl/axi_vip_axi4pc.sv" \
"/tools/Xilinx/Vivado/2020.2/data/xilinx_vip/hdl/xil_common_vip_pkg.sv" \
"/tools/Xilinx/Vivado/2020.2/data/xilinx_vip/hdl/axi4stream_vip_pkg.sv" \
"/tools/Xilinx/Vivado/2020.2/data/xilinx_vip/hdl/axi_vip_pkg.sv" \
"/tools/Xilinx/Vivado/2020.2/data/xilinx_vip/hdl/axi4stream_vip_if.sv" \
"/tools/Xilinx/Vivado/2020.2/data/xilinx_vip/hdl/axi_vip_if.sv" \
"/tools/Xilinx/Vivado/2020.2/data/xilinx_vip/hdl/clk_vip_if.sv" \
"/tools/Xilinx/Vivado/2020.2/data/xilinx_vip/hdl/rst_vip_if.sv" \

vlog -work xpm  -sv2k12 "+incdir+../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/d0f7" "+incdir+../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/ec67/hdl" "+incdir+../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/da1e/hdl" "+incdir+/tools/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"/tools/Xilinx/Vivado/2020.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"/tools/Xilinx/Vivado/2020.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93 \
"/tools/Xilinx/Vivado/2020.2/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/d0f7" "+incdir+../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/ec67/hdl" "+incdir+../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/da1e/hdl" "+incdir+/tools/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"../../../bd/holosynthv/ip/holosynthv_audio_i2s_driver_0_0/sim/holosynthv_audio_i2s_driver_0_0.v" \
"../../../bd/holosynthv/ip/holosynthv_audio_i2s_timing_gen_0_0/sim/holosynthv_audio_i2s_timing_gen_0_0.v" \
"../../../bd/holosynthv/ip/holosynthv_audio_mux_0_0/sim/holosynthv_audio_mux_0_0.v" \
"../../../bd/holosynthv/ip/holosynthv_clk_wiz_0_0/holosynthv_clk_wiz_0_0_clk_wiz.v" \
"../../../bd/holosynthv/ip/holosynthv_clk_wiz_0_0/holosynthv_clk_wiz_0_0.v" \

vlog -work fifo_generator_v13_2_5  -v2k5 "+incdir+../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/d0f7" "+incdir+../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/ec67/hdl" "+incdir+../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/da1e/hdl" "+incdir+/tools/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/276e/simulation/fifo_generator_vlog_beh.v" \

vcom -work fifo_generator_v13_2_5 -93 \
"../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/276e/hdl/fifo_generator_v13_2_rfs.vhd" \

vlog -work fifo_generator_v13_2_5  -v2k5 "+incdir+../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/d0f7" "+incdir+../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/ec67/hdl" "+incdir+../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/da1e/hdl" "+incdir+/tools/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/276e/hdl/fifo_generator_v13_2_rfs.v" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/d0f7" "+incdir+../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/ec67/hdl" "+incdir+../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/da1e/hdl" "+incdir+/tools/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"../../../bd/holosynthv/ip/holosynthv_fifo_generator_0_0/sim/holosynthv_fifo_generator_0_0.v" \
"../../../bd/holosynthv/ip/holosynthv_fifo_generator_1_0/sim/holosynthv_fifo_generator_1_0.v" \
"../../../bd/holosynthv/ip/holosynthv_holosynth_0_0/sim/holosynthv_holosynth_0_0.v" \

vcom -work xil_defaultlib -93 \
"../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/431c/src/hm2_axilite_int.vhd" \
"../../../bd/holosynthv/ip/holosynthv_holosynth_audio_0/sim/holosynthv_holosynth_audio_0.vhd" \
"../../../bd/holosynthv/ip/holosynthv_holosynth_midi_0/sim/holosynthv_holosynth_midi_0.vhd" \
"../../../bd/holosynthv/ip/holosynthv_holosynth_sysex_0/sim/holosynthv_holosynth_sysex_0.vhd" \

vlog -work generic_baseblocks_v2_1_0  -v2k5 "+incdir+../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/d0f7" "+incdir+../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/ec67/hdl" "+incdir+../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/da1e/hdl" "+incdir+/tools/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/b752/hdl/generic_baseblocks_v2_1_vl_rfs.v" \

vlog -work axi_infrastructure_v1_1_0  -v2k5 "+incdir+../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/d0f7" "+incdir+../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/ec67/hdl" "+incdir+../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/da1e/hdl" "+incdir+/tools/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/ec67/hdl/axi_infrastructure_v1_1_vl_rfs.v" \

vlog -work axi_register_slice_v2_1_22  -v2k5 "+incdir+../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/d0f7" "+incdir+../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/ec67/hdl" "+incdir+../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/da1e/hdl" "+incdir+/tools/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/af2c/hdl/axi_register_slice_v2_1_vl_rfs.v" \

vlog -work axi_data_fifo_v2_1_21  -v2k5 "+incdir+../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/d0f7" "+incdir+../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/ec67/hdl" "+incdir+../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/da1e/hdl" "+incdir+/tools/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/54c0/hdl/axi_data_fifo_v2_1_vl_rfs.v" \

vlog -work axi_crossbar_v2_1_23  -v2k5 "+incdir+../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/d0f7" "+incdir+../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/ec67/hdl" "+incdir+../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/da1e/hdl" "+incdir+/tools/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/bc0a/hdl/axi_crossbar_v2_1_vl_rfs.v" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/d0f7" "+incdir+../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/ec67/hdl" "+incdir+../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/da1e/hdl" "+incdir+/tools/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"../../../bd/holosynthv/ip/holosynthv_xbar_0/sim/holosynthv_xbar_0.v" \

vlog -work axi_protocol_converter_v2_1_22  -v2k5 "+incdir+../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/d0f7" "+incdir+../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/ec67/hdl" "+incdir+../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/da1e/hdl" "+incdir+/tools/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/5cee/hdl/axi_protocol_converter_v2_1_vl_rfs.v" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/d0f7" "+incdir+../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/ec67/hdl" "+incdir+../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/da1e/hdl" "+incdir+/tools/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"../../../bd/holosynthv/ip/holosynthv_auto_pc_0/sim/holosynthv_auto_pc_0.v" \

vcom -work lib_cdc_v1_0_2 -93 \
"../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/ef1e/hdl/lib_cdc_v1_0_rfs.vhd" \

vcom -work proc_sys_reset_v5_0_13 -93 \
"../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/8842/hdl/proc_sys_reset_v5_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -93 \
"../../../bd/holosynthv/ip/holosynthv_rst_ps8_0_99M_0/sim/holosynthv_rst_ps8_0_99M_0.vhd" \

vlog -work xlconstant_v1_1_7  -v2k5 "+incdir+../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/d0f7" "+incdir+../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/ec67/hdl" "+incdir+../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/da1e/hdl" "+incdir+/tools/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/fcfc/hdl/xlconstant_v1_1_vl_rfs.v" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/d0f7" "+incdir+../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/ec67/hdl" "+incdir+../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/da1e/hdl" "+incdir+/tools/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"../../../bd/holosynthv/ip/holosynthv_xlconstant_0_0/sim/holosynthv_xlconstant_0_0.v" \

vlog -work xlslice_v1_0_2  -v2k5 "+incdir+../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/d0f7" "+incdir+../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/ec67/hdl" "+incdir+../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/da1e/hdl" "+incdir+/tools/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/11d0/hdl/xlslice_v1_0_vl_rfs.v" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/d0f7" "+incdir+../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/ec67/hdl" "+incdir+../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/da1e/hdl" "+incdir+/tools/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"../../../bd/holosynthv/ip/holosynthv_xlslice_0_0/sim/holosynthv_xlslice_0_0.v" \

vlog -work axi_vip_v1_1_8  -sv2k12 "+incdir+../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/d0f7" "+incdir+../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/ec67/hdl" "+incdir+../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/da1e/hdl" "+incdir+/tools/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/94c3/hdl/axi_vip_v1_1_vl_rfs.sv" \

vlog -work zynq_ultra_ps_e_vip_v1_0_8  -sv2k12 "+incdir+../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/d0f7" "+incdir+../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/ec67/hdl" "+incdir+../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/da1e/hdl" "+incdir+/tools/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/da1e/hdl/zynq_ultra_ps_e_vip_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/d0f7" "+incdir+../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/ec67/hdl" "+incdir+../../../../ultramyir_Holosynth.gen/sources_1/bd/holosynthv/ipshared/da1e/hdl" "+incdir+/tools/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"../../../bd/holosynthv/ip/holosynthv_zynq_ultra_ps_e_0_0/sim/holosynthv_zynq_ultra_ps_e_0_0_vip_wrapper.v" \
"../../../bd/holosynthv/sim/holosynthv.v" \

vlog -work xil_defaultlib \
"glbl.v"

