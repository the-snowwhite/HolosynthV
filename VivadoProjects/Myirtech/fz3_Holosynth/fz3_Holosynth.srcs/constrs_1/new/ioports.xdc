set_property PACKAGE_PIN A2 [get_ports ext_AUD_ADCLRCLK_0]
set_property PACKAGE_PIN A1 [get_ports ext_AUD_BCLK_0]
set_property PACKAGE_PIN C3 [get_ports ext_AUD_DACLRCLK_0]
set_property PACKAGE_PIN C2 [get_ports oAUD_DACDAT_0]

set_property PACKAGE_PIN G1 [get_ports midi_rxd_0]
set_property PACKAGE_PIN F1 [get_ports midi_txd_0]

set_property PACKAGE_PIN C1 [get_ports {Led_out[0]}]
set_property PACKAGE_PIN B1 [get_ports {Led_out[1]}]
set_property PACKAGE_PIN E1 [get_ports {Led_out[2]}]
set_property PACKAGE_PIN D1 [get_ports {Led_out[3]}]

set_property IOSTANDARD LVCMOS18 [get_ports -of_objects [get_iobanks 66]]
#set_property PACKAGE_PIN C5 [get_ports {uart_usb_sel_0}]

#set_property PACKAGE_PIN F4   [get_ports {fan_out}];  # "F4.FAN_PWM"
# Set the bank voltage for IO Bank 26 to 1.8V







