create_generated_clock -name midi_clk -source [get_pins {design_1_i/zynq_ultra_ps_e_0/inst/PS8_i/PLCLK[0]}] -divide_by 1600 [get_pins design_1_i/holosynth_0/inst/synthesizer_inst/synth_controller_inst/MIDI_UART_inst/midi_clk_reg/Q]
set_false_path -from [get_clocks bclk44] -to [get_clocks ext_AUD_B_CLK_0]
set_false_path -from [get_clocks clk_pl_0] -to [get_clocks bclk44]
set_false_path -from [get_clocks clk_pl_0] -to [get_clocks bclk48]
set_false_path -from [get_clocks clk_pl_0] -to [get_clocks ext_AUD_B_CLK_0]
set_false_path -from [get_clocks ext_AUD_B_CLK_0] -to [get_clocks bclk44]
set_false_path -from [get_clocks ext_AUD_B_CLK_0] -to [get_clocks bclk48]
set_false_path -from [get_clocks playback_lrclk44] -to [get_clocks bclk48]
set_false_path -from [get_clocks playback_lrclk44] -to [get_clocks ext_AUD_B_CLK_0]
set_false_path -from [get_clocks playback_lrclk48] -to [get_clocks ext_AUD_B_CLK_0]
set_false_path -from [get_clocks bclk48] -to [get_clocks ext_AUD_B_CLK_0]
#set_false_path -from [get_pins design_1_i/holosynth_0/inst/synthesizer_inst/reset_reg_delay_inst/oRST_2_reg/C] -to [get_pins {design_1_i/holosynth_0/inst/synthesizer_inst/synth_engine_inst/synth_clk_gen_inst/sCLK_XVXENVS_DIV_reg[0]/CLR}]
set_false_path -from [get_clocks clk_pl_0] -to [get_clocks -of_objects [get_pins design_1_i/clk_wiz_0/inst/mmcme4_adv_inst/CLKOUT0]]

#create_debug_core u_ila_0 ila
#set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
#set_property ALL_PROBE_SAME_MU_CNT 2 [get_debug_cores u_ila_0]
#set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
#set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
#set_property C_EN_STRG_QUAL true [get_debug_cores u_ila_0]
#set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
#set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
#set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
#set_property port_width 1 [get_debug_ports u_ila_0/clk]
#connect_debug_port u_ila_0/clk [get_nets [list design_1_i/zynq_ultra_ps_e_0/inst/pl_clk0]]
#set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
#set_property port_width 8 [get_debug_ports u_ila_0/probe0]
#connect_debug_port u_ila_0/probe0 [get_nets [list {design_1_i/holosynth_0/cpu_writedata[0]} {design_1_i/holosynth_0/cpu_writedata[1]} {design_1_i/holosynth_0/cpu_writedata[2]} {design_1_i/holosynth_0/cpu_writedata[3]} {design_1_i/holosynth_0/cpu_writedata[4]} {design_1_i/holosynth_0/cpu_writedata[5]} {design_1_i/holosynth_0/cpu_writedata[6]} {design_1_i/holosynth_0/cpu_writedata[7]}]]
#create_debug_port u_ila_0 probe
#set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
#set_property port_width 8 [get_debug_ports u_ila_0/probe1]
#connect_debug_port u_ila_0/probe1 [get_nets [list {design_1_i/holosynth_0/cpu_readdata[0]} {design_1_i/holosynth_0/cpu_readdata[1]} {design_1_i/holosynth_0/cpu_readdata[2]} {design_1_i/holosynth_0/cpu_readdata[3]} {design_1_i/holosynth_0/cpu_readdata[4]} {design_1_i/holosynth_0/cpu_readdata[5]} {design_1_i/holosynth_0/cpu_readdata[6]} {design_1_i/holosynth_0/cpu_readdata[7]}]]
#create_debug_port u_ila_0 probe
#set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
#set_property port_width 10 [get_debug_ports u_ila_0/probe2]
#connect_debug_port u_ila_0/probe2 [get_nets [list {design_1_i/holosynth_0/cpu_addr[0]} {design_1_i/holosynth_0/cpu_addr[1]} {design_1_i/holosynth_0/cpu_addr[2]} {design_1_i/holosynth_0/cpu_addr[3]} {design_1_i/holosynth_0/cpu_addr[4]} {design_1_i/holosynth_0/cpu_addr[5]} {design_1_i/holosynth_0/cpu_addr[6]} {design_1_i/holosynth_0/cpu_addr[7]} {design_1_i/holosynth_0/cpu_addr[8]} {design_1_i/holosynth_0/cpu_addr[9]}]]
#create_debug_port u_ila_0 probe
#set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
#set_property port_width 8 [get_debug_ports u_ila_0/probe3]
#connect_debug_port u_ila_0/probe3 [get_nets [list {design_1_i/holosynth_0/inst/synthesizer_inst/synth_controller_inst/sysex_func_inst/synth_data_out[0]} {design_1_i/holosynth_0/inst/synthesizer_inst/synth_controller_inst/sysex_func_inst/synth_data_out[1]} {design_1_i/holosynth_0/inst/synthesizer_inst/synth_controller_inst/sysex_func_inst/synth_data_out[2]} {design_1_i/holosynth_0/inst/synthesizer_inst/synth_controller_inst/sysex_func_inst/synth_data_out[3]} {design_1_i/holosynth_0/inst/synthesizer_inst/synth_controller_inst/sysex_func_inst/synth_data_out[4]} {design_1_i/holosynth_0/inst/synthesizer_inst/synth_controller_inst/sysex_func_inst/synth_data_out[5]} {design_1_i/holosynth_0/inst/synthesizer_inst/synth_controller_inst/sysex_func_inst/synth_data_out[6]} {design_1_i/holosynth_0/inst/synthesizer_inst/synth_controller_inst/sysex_func_inst/synth_data_out[7]}]]
#create_debug_port u_ila_0 probe
#set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
#set_property port_width 1 [get_debug_ports u_ila_0/probe4]
#connect_debug_port u_ila_0/probe4 [get_nets [list design_1_i/holosynth_0/cpu_read]]
#create_debug_port u_ila_0 probe
#set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
#set_property port_width 1 [get_debug_ports u_ila_0/probe5]
#connect_debug_port u_ila_0/probe5 [get_nets [list design_1_i/holosynth_0/cpu_write]]
#create_debug_port u_ila_0 probe
#set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
#set_property port_width 1 [get_debug_ports u_ila_0/probe6]
#connect_debug_port u_ila_0/probe6 [get_nets [list design_1_i/holosynth_0/inst/synthesizer_inst/read]]
#create_debug_port u_ila_0 probe
#set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
#set_property port_width 1 [get_debug_ports u_ila_0/probe7]
#connect_debug_port u_ila_0/probe7 [get_nets [list design_1_i/holosynth_0/inst/synthesizer_inst/write]]
#set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
#set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
#set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
#connect_debug_port dbg_hub/clk [get_nets clk_out_OBUF]
