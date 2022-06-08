create_generated_clock -name holosynthv_i/holosynth_0/inst/synthesizer_inst/synth_controller_inst/MIDI_UART_inst/midi_clk_reg_0 -source [get_pins {holosynthv_i/zynq_ultra_ps_e_0/inst/PS8_i/PLCLK[0]}] -divide_by 200 [get_pins holosynthv_i/holosynth_0/inst/synthesizer_inst/synth_controller_inst/MIDI_UART_inst/midi_clk_reg/Q]

create_clock -period 29.493 -name VIRTUAL_clk_out1_holosynthv_clk_wiz_0_0 -waveform {0.000 14.747}

set_false_path -to [get_cells -hierarchical *is_metastable_sig*]


