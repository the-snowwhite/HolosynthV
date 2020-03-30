
#create_debug_core u_ila_0 ila
#set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
#set_property ALL_PROBE_SAME_MU_CNT 2 [get_debug_cores u_ila_0]
#set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
#set_property C_DATA_DEPTH 131072 [get_debug_cores u_ila_0]
#set_property C_EN_STRG_QUAL true [get_debug_cores u_ila_0]
#set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
#set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
#set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
#set_property port_width 1 [get_debug_ports u_ila_0/clk]
#connect_debug_port u_ila_0/clk [get_nets [list design_1_i/zynq_ultra_ps_e_0/inst/pl_clk0]]
#set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
#set_property port_width 8 [get_debug_ports u_ila_0/probe0]
#connect_debug_port u_ila_0/probe0 [get_nets [list {design_1_i/holosynth_0/inst/synthesizer_inst/synth_controller_inst/MIDI_UART_inst/cur_status_u_reg[7]_0[0]} {design_1_i/holosynth_0/inst/synthesizer_inst/synth_controller_inst/MIDI_UART_inst/cur_status_u_reg[7]_0[1]} {design_1_i/holosynth_0/inst/synthesizer_inst/synth_controller_inst/MIDI_UART_inst/cur_status_u_reg[7]_0[2]} {design_1_i/holosynth_0/inst/synthesizer_inst/synth_controller_inst/MIDI_UART_inst/cur_status_u_reg[7]_0[3]} {design_1_i/holosynth_0/inst/synthesizer_inst/synth_controller_inst/MIDI_UART_inst/cur_status_u_reg[7]_0[4]} {design_1_i/holosynth_0/inst/synthesizer_inst/synth_controller_inst/MIDI_UART_inst/cur_status_u_reg[7]_0[5]} {design_1_i/holosynth_0/inst/synthesizer_inst/synth_controller_inst/MIDI_UART_inst/cur_status_u_reg[7]_0[6]} {design_1_i/holosynth_0/inst/synthesizer_inst/synth_controller_inst/MIDI_UART_inst/cur_status_u_reg[7]_0[7]}]]
#create_debug_port u_ila_0 probe
#set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
#set_property port_width 8 [get_debug_ports u_ila_0/probe1]
#connect_debug_port u_ila_0/probe1 [get_nets [list {design_1_i/holosynth_0/inst/synthesizer_inst/synth_controller_inst/MIDI_UART_inst/cur_status_r[0]} {design_1_i/holosynth_0/inst/synthesizer_inst/synth_controller_inst/MIDI_UART_inst/cur_status_r[1]} {design_1_i/holosynth_0/inst/synthesizer_inst/synth_controller_inst/MIDI_UART_inst/cur_status_r[2]} {design_1_i/holosynth_0/inst/synthesizer_inst/synth_controller_inst/MIDI_UART_inst/cur_status_r[3]} {design_1_i/holosynth_0/inst/synthesizer_inst/synth_controller_inst/MIDI_UART_inst/cur_status_r[4]} {design_1_i/holosynth_0/inst/synthesizer_inst/synth_controller_inst/MIDI_UART_inst/cur_status_r[5]} {design_1_i/holosynth_0/inst/synthesizer_inst/synth_controller_inst/MIDI_UART_inst/cur_status_r[6]} {design_1_i/holosynth_0/inst/synthesizer_inst/synth_controller_inst/MIDI_UART_inst/cur_status_r[7]}]]
#create_debug_port u_ila_0 probe
#set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
#set_property port_width 8 [get_debug_ports u_ila_0/probe2]
#connect_debug_port u_ila_0/probe2 [get_nets [list {design_1_i/holosynth_0/inst/synthesizer_inst/synth_controller_inst/MIDI_UART_inst/midi_in_data_u_reg[7]_0[0]} {design_1_i/holosynth_0/inst/synthesizer_inst/synth_controller_inst/MIDI_UART_inst/midi_in_data_u_reg[7]_0[1]} {design_1_i/holosynth_0/inst/synthesizer_inst/synth_controller_inst/MIDI_UART_inst/midi_in_data_u_reg[7]_0[2]} {design_1_i/holosynth_0/inst/synthesizer_inst/synth_controller_inst/MIDI_UART_inst/midi_in_data_u_reg[7]_0[3]} {design_1_i/holosynth_0/inst/synthesizer_inst/synth_controller_inst/MIDI_UART_inst/midi_in_data_u_reg[7]_0[4]} {design_1_i/holosynth_0/inst/synthesizer_inst/synth_controller_inst/MIDI_UART_inst/midi_in_data_u_reg[7]_0[5]} {design_1_i/holosynth_0/inst/synthesizer_inst/synth_controller_inst/MIDI_UART_inst/midi_in_data_u_reg[7]_0[6]} {design_1_i/holosynth_0/inst/synthesizer_inst/synth_controller_inst/MIDI_UART_inst/midi_in_data_u_reg[7]_0[7]}]]
#create_debug_port u_ila_0 probe
#set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
#set_property port_width 7 [get_debug_ports u_ila_0/probe3]
#connect_debug_port u_ila_0/probe3 [get_nets [list {design_1_i/holosynth_0/inst/synthesizer_inst/synth_controller_inst/MIDI_UART_inst/samplebyte[0]} {design_1_i/holosynth_0/inst/synthesizer_inst/synth_controller_inst/MIDI_UART_inst/samplebyte[1]} {design_1_i/holosynth_0/inst/synthesizer_inst/synth_controller_inst/MIDI_UART_inst/samplebyte[2]} {design_1_i/holosynth_0/inst/synthesizer_inst/synth_controller_inst/MIDI_UART_inst/samplebyte[3]} {design_1_i/holosynth_0/inst/synthesizer_inst/synth_controller_inst/MIDI_UART_inst/samplebyte[4]} {design_1_i/holosynth_0/inst/synthesizer_inst/synth_controller_inst/MIDI_UART_inst/samplebyte[5]} {design_1_i/holosynth_0/inst/synthesizer_inst/synth_controller_inst/MIDI_UART_inst/samplebyte[6]}]]
#create_debug_port u_ila_0 probe
#set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
#set_property port_width 1 [get_debug_ports u_ila_0/probe4]
#connect_debug_port u_ila_0/probe4 [get_nets [list design_1_i/holosynth_0/inst/synthesizer_inst/synth_controller_inst/MIDI_UART_inst/byteready_u]]
#create_debug_port u_ila_0 probe
#set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
#set_property port_width 1 [get_debug_ports u_ila_0/probe5]
#connect_debug_port u_ila_0/probe5 [get_nets [list design_1_i/holosynth_0/inst/synthesizer_inst/synth_controller_inst/MIDI_UART_inst/clk_enable_dly]]
#create_debug_port u_ila_0 probe
#set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
#set_property port_width 1 [get_debug_ports u_ila_0/probe6]
#connect_debug_port u_ila_0/probe6 [get_nets [list design_1_i/holosynth_0/inst/synthesizer_inst/synth_controller_inst/MIDI_UART_inst/midi_rxd]]
#create_debug_port u_ila_0 probe
#set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
#set_property port_width 1 [get_debug_ports u_ila_0/probe7]
#connect_debug_port u_ila_0/probe7 [get_nets [list design_1_i/holosynth_0/inst/synthesizer_inst/synth_controller_inst/MIDI_UART_inst/startbit_d]]
#set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
#set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
#set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
#connect_debug_port dbg_hub/clk [get_nets clk_out_OBUF]
