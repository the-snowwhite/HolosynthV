create_generated_clock -name midi_clk -source [get_pins {holosynthv_i/zynq_ultra_ps_e_0/inst/PS8_i/PLCLK[0]}] -divide_by 800 [get_pins holosynthv_i/holosynth_0/inst/synthesizer_inst/synth_controller_inst/MIDI_UART_inst/midi_clk_reg/Q]

set_false_path -from [get_clocks -of_objects [get_pins holosynthv_i/clk_wiz_0/inst/mmcme4_adv_inst/CLKOUT0]] -to [get_clocks -of_objects [get_pins holosynthv_i/clk_wiz_0/inst/mmcme4_adv_inst/CLKOUT1]]
set_false_path -from [get_clocks -of_objects [get_pins holosynthv_i/clk_wiz_0/inst/mmcme4_adv_inst/CLKOUT1]] -to [get_clocks -of_objects [get_pins holosynthv_i/clk_wiz_0/inst/mmcme4_adv_inst/CLKOUT0]]

set_false_path -from [get_pins {holosynthv_i/rst_ps8_0_99M/U0/ACTIVE_LOW_PR_OUT_DFF[0].FDRE_PER_N/C}] -to [get_pins holosynthv_i/audio_clk_mux_core_0/inst/sync_inst_1/sig_buffer0_0_reg/D]
set_false_path -from [get_pins holosynthv_i/audio_mux_0/inst/samplerate_is_48_reg/C] -to [get_pins holosynthv_i/audio_clk_mux_core_0/inst/sync_inst_1/sig_buffer0_1_reg/D]
set_false_path -from [get_pins holosynthv_i/audio_mux_0/inst/samplerate_is_48_reg/C] -to [get_pins holosynthv_i/audio_clk_mux_core_0/inst/BUFGMUX_CTRL_inst/S0]
set_false_path -from [get_pins {holosynthv_i/rst_ps8_0_99M/U0/ACTIVE_LOW_PR_OUT_DFF[0].FDRE_PER_N/C}] -to [get_pins holosynthv_i/audio_clk_mux_core_0/inst/sync_inst_1/sig_buffer0_0_reg/D]
set_false_path -from [get_pins holosynthv_i/audio_mux_0/inst/samplerate_is_48_reg/C] -to [get_pins holosynthv_i/audio_clk_mux_core_0/inst/sync_inst_1/sig_buffer0_1_reg/D]
set_false_path -from [get_pins holosynthv_i/audio_mux_0/inst/samplerate_is_48_reg/C] -to [get_pins holosynthv_i/audio_clk_mux_core_0/inst/BUFGMUX_CTRL_inst/S1]
