set_property PACKAGE_PIN D7 [get_ports ext_AUD_ADCLR_CLK_0]
set_property PACKAGE_PIN F8 [get_ports ext_AUD_B_CLK_0]
set_property PACKAGE_PIN F7 [get_ports ext_AUD_DACLR_CLK_0]
set_property PACKAGE_PIN G7 [get_ports oAUD_DACDAT_0]

set_property PACKAGE_PIN F6 [get_ports midi_rxd_0]
set_property PACKAGE_PIN G5 [get_ports midi_txd_0]

set_property PACKAGE_PIN A6 [get_ports {Led_out[0]}]
set_property PACKAGE_PIN C7 [get_ports {Led_out[1]}]
set_property PACKAGE_PIN A7 [get_ports {Led_out[2]}]
set_property PACKAGE_PIN B6 [get_ports {Led_out[3]}]

set_property PACKAGE_PIN G6 [get_ports {clk_out}]

#set_property PACKAGE_PIN F4   [get_ports {fan_out}];  # "F4.FAN_PWM"
# Set the bank voltage for IO Bank 26 to 1.8V
set_property IOSTANDARD LVCMOS18 [get_ports -of_objects [get_iobanks 26]]

#BT_HCI_RTS on FPGA /  emio_uart0_ctsn connect to 
set_property PACKAGE_PIN B7 [get_ports BT_ctsn]
#BT_HCI_CTS on FPGA / emio_uart0_rtsn
set_property PACKAGE_PIN B5 [get_ports BT_rtsn]

set_property IOSTANDARD LVCMOS18 [get_ports BT*]
# Set the bank voltage for IO Bank 65 to 1.2V
# Set the bank voltage for IO Bank 66 to 1.2V

