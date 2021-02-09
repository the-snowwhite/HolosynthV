# Pin num
# J16 31
set_property PACKAGE_PIN E14 [get_ports ext_AUD_ADCLRCLK_0]
# J16 33
set_property PACKAGE_PIN E13 [get_ports ext_AUD_BCLK_0]
# J16 35
set_property PACKAGE_PIN F15 [get_ports ext_AUD_DACLRCLK_0]
# J16 37
set_property PACKAGE_PIN E15 [get_ports oAUD_DACDAT_0]

# J16 22
set_property PACKAGE_PIN G11 [get_ports midi_rxd_0]
# J16 24
set_property PACKAGE_PIN F10 [get_ports midi_txd_0]

# J16 21
set_property PACKAGE_PIN E10 [get_ports {Led_out[0]}]
# J16 23 
set_property PACKAGE_PIN D10 [get_ports {Led_out[1]}]
# J16 25
set_property PACKAGE_PIN A12 [get_ports {Led_out[2]}]
# J16 27
set_property PACKAGE_PIN A11 [get_ports {Led_out[3]}]

#set_property IOSTANDARD LVCMOS18 [get_ports -of_objects [get_iobanks 66]]
#set_property PACKAGE_PIN C5 [get_ports {uart_usb_sel_0}]

#set_property PACKAGE_PIN F4   [get_ports {fan_out}];  # "F4.FAN_PWM"
#Set the bank voltage for IO Bank 25,26 to 3.3V
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 25]]
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 26]]







