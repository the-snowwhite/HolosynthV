#create_generated_clock -name midi_clk -source [get_clocks clk_pl_0] -divide_by 1600 [get_pins design_1_i/holosynth_0/inst/synthesizer_inst/synth_controller_inst/MIDI_UART_inst/midi_clk_reg/Q]

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
set_false_path -from [get_pins design_1_i/holosynth_0/inst/synthesizer_inst/reset_reg_delay_inst/oRST_2_reg/C] -to [get_pins {design_1_i/holosynth_0/inst/synthesizer_inst/synth_engine_inst/synth_clk_gen_inst/sCLK_XVXENVS_DIV_reg[0]/CLR}]
set_false_path -from [get_clocks clk_pl_0] -to [get_clocks -of_objects [get_pins design_1_i/clk_wiz_0/inst/mmcme4_adv_inst/CLKOUT0]]





