create_generated_clock -name holosynthv_i/holosynth_0/inst/synthesizer_inst/synth_controller_inst/MIDI_UART_inst/midi_clk_reg_0 -source [get_pins {holosynthv_i/zynq_ultra_ps_e_0/inst/PS8_i/PLCLK[0]}] -divide_by 200 [get_pins holosynthv_i/holosynth_0/inst/synthesizer_inst/synth_controller_inst/MIDI_UART_inst/midi_clk_reg/Q]

create_clock -period 29.493 -name VIRTUAL_clk_out1_holosynthv_clk_wiz_0_0 -waveform {0.000 14.747}
create_clock -period 40.525 -name VIRTUAL_clk_out2_holosynthv_clk_wiz_0_0 -waveform {0.000 20.263}

set_clock_groups -logically_exclusive -group [get_clocks -include_generated_clocks clk_out1_holosynthv_clk_wiz_0_0] -group [get_clocks -include_generated_clocks clk_out2_holosynthv_clk_wiz_0_0]

set_false_path -to [get_cells -hierarchical *is_metastable_sig*]

#set_false_path -from [get_pins {holosynthv_i/rst_ps8_0_99M/U0/ACTIVE_LOW_PR_OUT_DFF[0].FDRE_PER_N/C}] -to [get_pins holosynthv_i/audio_clk_mux_core_0/inst/sync_inst_1/sig_buffer0_0_reg/D]
#set_false_path -from [get_pins holosynthv_i/audio_mux_0/inst/samplerate_is_48_reg/C] -to [get_pins holosynthv_i/audio_clk_mux_core_0/inst/sync_inst_1/sig_buffer0_1_reg/D]

set_false_path -from [get_clocks -of_objects [get_pins holosynthv_i/clk_wiz_0/inst/mmcme4_adv_inst/CLKOUT0]] -to [get_clocks clk_pl_0]
set_false_path -from [get_clocks -of_objects [get_pins holosynthv_i/clk_wiz_0/inst/mmcme4_adv_inst/CLKOUT1]] -to [get_clocks clk_pl_0]
