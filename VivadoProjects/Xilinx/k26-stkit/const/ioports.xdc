#set_property IOSTANDARD  LVCMOS33 [get_ports "som240_1_a17"]; # Net name HDA11
#set_property IOSTANDARD  LVCMOS33 [get_ports "som240_1_d20"]; # Net name HDA12
#set_property IOSTANDARD  LVCMOS33 [get_ports "som240_1_d21"]; # Net name HDA13
#set_property IOSTANDARD  LVCMOS33 [get_ports "som240_1_d22"]; # Net name HDA14
#set_property IOSTANDARD  LVCMOS33 [get_ports "som240_1_b20"]; # Net name HDA15
#set_property IOSTANDARD  LVCMOS33 [get_ports "som240_1_b21"]; # Net name HDA16_CC
#set_property IOSTANDARD  LVCMOS33 [get_ports "som240_1_b22"]; # Net name HDA17
#set_property IOSTANDARD  LVCMOS33 [get_ports "som240_1_c22"]; # Net name HDA18


#set_property SLEW SLOW [get_ports "som240_1_a17"]; # Net name HDA11
#set_property SLEW SLOW [get_ports "som240_1_d20"]; # Net name HDA12
#set_property SLEW SLOW [get_ports "som240_1_d21"]; # Net name HDA13
#set_property SLEW SLOW [get_ports "som240_1_d22"]; # Net name HDA14
#set_property SLEW SLOW [get_ports "som240_1_b20"]; # Net name HDA15
#set_property SLEW SLOW [get_ports "som240_1_b21"]; # Net name HDA16_CC
#set_property SLEW SLOW [get_ports "som240_1_b22"]; # Net name HDA17
#set_property SLEW SLOW [get_ports "som240_1_c22"]; # Net name HDA18


#set_property DRIVE 4   [get_ports "som240_1_a17"]; # Net name HDA11
#set_property DRIVE 4   [get_ports "som240_1_d20"]; # Net name HDA12
#set_property DRIVE 4   [get_ports "som240_1_d21"]; # Net name HDA13
#set_property DRIVE 4   [get_ports "som240_1_d22"]; # Net name HDA14
#set_property DRIVE 4   [get_ports "som240_1_b20"]; # Net name HDA15
#set_property DRIVE 4   [get_ports "som240_1_b21"]; # Net name HDA16_CC
#set_property DRIVE 4   [get_ports "som240_1_b22"]; # Net name HDA17
#set_property DRIVE 4   [get_ports "som240_1_c22"]; # Net name HDA18

# Pin num
# J3 1
set_property PACKAGE_PIN H12 [get_ports ext_AUD_BCLK_0]
# J3 3
set_property PACKAGE_PIN E10 [get_ports ext_AUD_DACLRCLK_0]
# J3 5
set_property PACKAGE_PIN D10 [get_ports oAUD_DACDAT_0]

# J3 7
set_property PACKAGE_PIN C11 [get_ports midi_rxd_0]
# J3 2
set_property PACKAGE_PIN B10 [get_ports midi_txd_0]

# J3 4
set_property PACKAGE_PIN E12 [get_ports {Led_out[0]}]
# J3 6
set_property PACKAGE_PIN D11 [get_ports {Led_out[1]}]
# J3 9
set_property PACKAGE_PIN B11 [get_ports {Led_out[2]}]
# J16 27
set_property IOSTANDARD  LVCMOS33 [get_ports "ext_AUD_BCLK_0"]; # Net name HDA11
set_property IOSTANDARD  LVCMOS33 [get_ports "ext_AUD_DACLRCLK_0"]; # Net name HDA12
set_property IOSTANDARD  LVCMOS33 [get_ports "oAUD_DACDAT_0"]; # Net name HDA13
set_property IOSTANDARD  LVCMOS33 [get_ports "midi_rxd_0"]; # Net name HDA14
set_property IOSTANDARD  LVCMOS33 [get_ports "midi_txd_0"]; # Net name HDA15
set_property IOSTANDARD  LVCMOS33 [get_ports {Led_out[0]}]; # Net name HDA16_CC
set_property IOSTANDARD  LVCMOS33 [get_ports {Led_out[1]}]; # Net name HDA17
set_property IOSTANDARD  LVCMOS33 [get_ports {Led_out[2]}]; # Net name HDA18

#set_property PACKAGE_PIN A11 [get_ports {Led_out[3]}]

