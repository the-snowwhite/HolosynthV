#set_false_path -from [get_clocks clk_pl_0] -to [get_clocks clk_pl_2]
#set_false_path -from [get_clocks clk_pl_0] -to [get_clocks clk_pl_3]
create_clock -period 66 [get_ports ext_AUD_B_CLK]

create_generated_clock -name mclk44 -source [get_ports ext_clk44_clkin] -divide_by 2 [get_pins audio_clk_mux_axi_ip_v1_1_S00_AXI_inst/playback_gen44/mclk_divider/q_reg/Q]
create_generated_clock -name bclk44 -source [get_ports ext_clk44_clkin] -divide_by 12 [get_pins audio_clk_mux_axi_ip_v1_1_S00_AXI_inst/playback_gen44/bclk_divider/q_reg/Q]
create_generated_clock -name playback_lrclk44 -source [get_ports ext_clk44_clkin] -divide_by 768 [get_pins */playback_gen44/lrclk1_divider/q_reg/Q]
create_generated_clock -name capture_lrclk44 -source [get_ports ext_clk44_clkin] -divide_by 768 [get_pins */playback_gen44/lrclk2_divider/q_reg/Q]

create_generated_clock -name mclk48 -source [get_ports ext_clk48_clkin] -divide_by 2 [get_pins */playback_gen48/mclk_divider/q_reg/Q]
create_generated_clock -name bclk48 -source [get_ports ext_clk48_clkin] -divide_by 8 [get_pins */playback_gen48/bclk_divider/q_reg/Q]
create_generated_clock -name playback_lrclk48 -source [get_ports ext_clk48_clkin] -divide_by 512 [get_pins */playback_gen48/lrclk1_divider/q_reg/Q]
create_generated_clock -name capture_lrclk48 -source [get_ports ext_clk48_clkin] -divide_by 512 [get_pins */playback_gen48/lrclk2_divider/q_reg/Q]

set_max_delay 10 -datapath_only -from [get_clocks -of_objects [get_nets s00_axi_aclk ]] -to [get_clocks -of_objects [get_nets ext_clk44_clkin]]
set_max_delay 10 -datapath_only -from [get_clocks -of_objects [get_nets s00_axi_aclk ]] -to [get_clocks -of_objects [get_nets ext_clk48_clkin]]
