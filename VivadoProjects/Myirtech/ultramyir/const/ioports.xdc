# Pin num MYD-CZU3EG/Ultramyir

# PMOD1 #
#set_property PACKAGE_PIN E14 [get_ports ext_AUD_ADCLRCLK_0]

# PMOD1 1 IO_L19N_T3L_N1_DBC_AD9N_65
set_property PACKAGE_PIN J4  [get_ports ext_AUD_BCLK_0]
# PMOD1 2 IO_L19P_T3L_N0_DBC_AD9P_65
set_property PACKAGE_PIN J5  [get_ports ext_AUD_DACLRCLK_0]
# PMOD1 3 IO_L17N_T2U_N9_AD10N_65
set_property PACKAGE_PIN N8  [get_ports oAUD_DACDAT_0]

# PMOD1 7 IO_L20N_T3L_N3_AD1N_65
set_property PACKAGE_PIN H6  [get_ports midi_rxd_0]
# PMOD1 8 IO_L20P_T3L_N2_AD1P_65
set_property PACKAGE_PIN J6  [get_ports midi_txd_0]

# PMOD2 1 IO_L13N_T2L_N1_GC_QBC_64
set_property PACKAGE_PIN AD4 [get_ports {Led_out[0]}]
# PMOD2 3 IO_L20N_T3L_N3_AD1N_64
set_property PACKAGE_PIN AH3 [get_ports {Led_out[1]}]
# PMOD2 5 IO_L21P_T3L_N4_AD8P_64
set_property PACKAGE_PIN AE3 [get_ports {Led_out[2]}]
# PMOD2 7 IO_L18N_T2U_N11_AD2N_64
set_property PACKAGE_PIN AC1 [get_ports {Led_out[3]}]

#set_property PACKAGE_PIN F4   [get_ports {fan_out}];  # "F4.FAN_PWM"

#Set the bank voltage for IO Bank 65,64 to 1.8V
set_property IOSTANDARD LVCMOS18 [get_ports -of_objects [get_iobanks 65]]
set_property IOSTANDARD LVCMOS18 [get_ports -of_objects [get_iobanks 64]]









