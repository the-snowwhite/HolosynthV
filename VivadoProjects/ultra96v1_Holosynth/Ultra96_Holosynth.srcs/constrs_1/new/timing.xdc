create_generated_clock -name midi_clk -source [get_pins {holosynthv_i/zynq_ultra_ps_e_0/inst/PS8_i/PLCLK[0]}] -divide_by 800 [get_pins holosynthv_i/holosynth_0/inst/synthesizer_inst/synth_controller_inst/MIDI_UART_inst/midi_clk_reg/Q]

set_false_path -from [get_clocks -of_objects [get_pins holosynthv_i/clk_wiz_0/inst/mmcme4_adv_inst/CLKOUT0]] -to [get_clocks -of_objects [get_pins holosynthv_i/clk_wiz_1/inst/mmcme4_adv_inst/CLKOUT0]]

set_false_path -from [get_clocks -of_objects [get_pins holosynthv_i/clk_wiz_0/inst/mmcme4_adv_inst/CLKOUT0]] -to [get_clocks -of_objects [get_pins holosynthv_i/clk_wiz_0/inst/mmcme4_adv_inst/CLKOUT1]]
set_false_path -from [get_clocks -of_objects [get_pins holosynthv_i/clk_wiz_0/inst/mmcme4_adv_inst/CLKOUT1]] -to [get_clocks -of_objects [get_pins holosynthv_i/clk_wiz_0/inst/mmcme4_adv_inst/CLKOUT0]]
set_false_path -from [get_clocks clk_pl_0] -to [get_clocks -of_objects [get_pins holosynthv_i/clk_wiz_0/inst/mmcme4_adv_inst/CLKOUT1]]
set_false_path -from [get_clocks clk_pl_0] -to [get_clocks -of_objects [get_pins holosynthv_i/clk_wiz_0/inst/mmcme4_adv_inst/CLKOUT0]]

set_false_path -from [get_clocks -of_objects [get_pins holosynthv_i/clk_wiz_0/inst/mmcme4_adv_inst/CLKOUT1]] -to [get_clocks -of_objects [get_pins holosynthv_i/clk_wiz_1/inst/mmcme4_adv_inst/CLKOUT0]]
