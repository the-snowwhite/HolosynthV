create_generated_clock -name holosynthv_i/holosynth_0/inst/synthesizer_inst/synth_controller_inst/MIDI_UART_inst/midi_out_ready_reg_0 -source [get_pins holosynthv_i/holosynth_0/inst/synthesizer_inst/synth_controller_inst/MIDI_UART_inst/midi_clk_reg/Q] -divide_by 800 [get_pins holosynthv_i/holosynth_0/inst/synthesizer_inst/synth_controller_inst/MIDI_UART_inst/midi_out_ready_reg/Q]
create_generated_clock -name holosynthv_i/holosynth_0/inst/synthesizer_inst/synth_controller_inst/MIDI_UART_inst/startbit_d -source [get_pins {holosynthv_i/zynq_ultra_ps_e_0/inst/PS8_i/PLCLK[0]}] -divide_by 800 [get_pins holosynthv_i/holosynth_0/inst/synthesizer_inst/synth_controller_inst/MIDI_UART_inst/startbit_d_reg/Q]
create_generated_clock -name holosynthv_i/holosynth_0/inst/synthesizer_inst/synth_controller_inst/seq_trigger_inst/is_data_byte_reg_0 -source [get_pins {holosynthv_i/zynq_ultra_ps_e_0/inst/PS8_i/PLCLK[0]}] -divide_by 2 [get_pins holosynthv_i/holosynth_0/inst/synthesizer_inst/synth_controller_inst/seq_trigger_inst/is_data_byte_reg/Q]
create_generated_clock -name holosynthv_i/holosynth_0/inst/synthesizer_inst/synth_engine_inst/key_sync_inst/reg_note_on -source [get_pins {holosynthv_i/zynq_ultra_ps_e_0/inst/PS8_i/PLCLK[1]}] -divide_by 2 [get_pins holosynthv_i/holosynth_0/inst/synthesizer_inst/synth_engine_inst/key_sync_inst/reg_note_on_reg/Q]
create_generated_clock -name holosynthv_i/holosynth_0/inst/synthesizer_inst/synth_engine_inst/synth_clk_gen_inst/timing_gen_inst/xxxx_zero_reg_0 -source [get_pins holosynthv_i/holosynth_0/inst/synthesizer_inst/synth_engine_inst/synth_clk_gen_inst/sCLK_XVXENVS_reg/Q] -divide_by 256 [get_pins holosynthv_i/holosynth_0/inst/synthesizer_inst/synth_engine_inst/synth_clk_gen_inst/timing_gen_inst/xxxx_zero_reg/Q]
set_input_delay -clock [get_clocks clk_pl_0] -min -add_delay 6.000 [get_ports midi_rxd_0]
set_input_delay -clock [get_clocks clk_pl_0] -max -add_delay 8.000 [get_ports midi_rxd_0]
create_clock -period 16000.000 -name VIRTUAL_holosynthv_i/holosynth_0/inst/synthesizer_inst/synth_controller_inst/MIDI_UART_inst/midi_clk_reg_0 -waveform {0.000 8000.000}
set_output_delay -clock [get_clocks clk_pl_0] -min -add_delay 0.000 [get_ports {Led_out[*]}]
set_output_delay -clock [get_clocks clk_pl_0] -max -add_delay 6.000 [get_ports {Led_out[*]}]
set_output_delay -clock [get_clocks VIRTUAL_clk_out1_holosynthv_clk_wiz_0_0] -min -add_delay 0.000 [get_ports ext_AUD_ADCLRCLK_0]
set_output_delay -clock [get_clocks VIRTUAL_clk_out1_holosynthv_clk_wiz_0_0] -max -add_delay 6.000 [get_ports ext_AUD_ADCLRCLK_0]
set_output_delay -clock [get_clocks VIRTUAL_clk_out2_holosynthv_clk_wiz_0_0] -min -add_delay 0.000 [get_ports ext_AUD_ADCLRCLK_0]
set_output_delay -clock [get_clocks VIRTUAL_clk_out2_holosynthv_clk_wiz_0_0] -max -add_delay 6.000 [get_ports ext_AUD_ADCLRCLK_0]
set_output_delay -clock [get_clocks VIRTUAL_clk_out1_holosynthv_clk_wiz_0_0] -min -add_delay 0.000 [get_ports ext_AUD_BCLK_0]
set_output_delay -clock [get_clocks VIRTUAL_clk_out1_holosynthv_clk_wiz_0_0] -max -add_delay 6.000 [get_ports ext_AUD_BCLK_0]
set_output_delay -clock [get_clocks VIRTUAL_clk_out2_holosynthv_clk_wiz_0_0] -min -add_delay 0.000 [get_ports ext_AUD_BCLK_0]
set_output_delay -clock [get_clocks VIRTUAL_clk_out2_holosynthv_clk_wiz_0_0] -max -add_delay 6.000 [get_ports ext_AUD_BCLK_0]
set_output_delay -clock [get_clocks VIRTUAL_clk_out1_holosynthv_clk_wiz_0_0] -min -add_delay 0.000 [get_ports ext_AUD_DACLRCLK_0]
set_output_delay -clock [get_clocks VIRTUAL_clk_out1_holosynthv_clk_wiz_0_0] -max -add_delay 6.000 [get_ports ext_AUD_DACLRCLK_0]
set_output_delay -clock [get_clocks VIRTUAL_clk_out2_holosynthv_clk_wiz_0_0] -min -add_delay 0.000 [get_ports ext_AUD_DACLRCLK_0]
set_output_delay -clock [get_clocks VIRTUAL_clk_out2_holosynthv_clk_wiz_0_0] -max -add_delay 6.000 [get_ports ext_AUD_DACLRCLK_0]
set_output_delay -clock [get_clocks VIRTUAL_holosynthv_i/holosynth_0/inst/synthesizer_inst/synth_controller_inst/MIDI_UART_inst/midi_clk_reg_0] -min -add_delay -5.000 [get_ports midi_txd_0]
set_output_delay -clock [get_clocks VIRTUAL_holosynthv_i/holosynth_0/inst/synthesizer_inst/synth_controller_inst/MIDI_UART_inst/midi_clk_reg_0] -max -add_delay 20.000 [get_ports midi_txd_0]
