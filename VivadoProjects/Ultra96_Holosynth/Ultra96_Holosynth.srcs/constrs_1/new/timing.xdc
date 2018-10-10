#create_generated_clock -name midi_clk -source [get_clocks clk_pl_0] -divide_by 1600 [get_pins design_1_i/holosynth_0/inst/synthesizer_inst/synth_controller_inst/MIDI_UART_inst/midi_clk_reg/Q]

create_generated_clock -name midi_clk -source [get_pins {design_1_i/zynq_ultra_ps_e_0/inst/PS8_i/PLCLK[0]}] -divide_by 1600 [get_pins design_1_i/holosynth_0/inst/synthesizer_inst/synth_controller_inst/MIDI_UART_inst/midi_clk_reg/Q]
