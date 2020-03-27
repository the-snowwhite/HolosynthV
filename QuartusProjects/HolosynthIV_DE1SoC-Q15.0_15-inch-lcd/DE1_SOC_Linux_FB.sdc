## Generated SDC file "DE1_SOC_Linux_FB.out.sdc"

## Copyright (C) 2017  Intel Corporation. All rights reserved.
## Your use of Intel Corporation's design tools, logic functions
## and other software and tools, and its AMPP partner logic
## functions, and any output files from any of the foregoing
## (including device programming or simulation files), and any
## associated documentation or information are expressly subject
## to the terms and conditions of the Intel Program License
## Subscription Agreement, the Intel Quartus Prime License Agreement,
## the Intel MegaCore Function License Agreement, or other
## applicable license agreement, including, without limitation,
## that your use is for the sole purpose of programming logic
## devices manufactured by Intel and sold by Intel or its
## authorized distributors.  Please refer to the applicable
## agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 17.0.1 Build 598 06/07/2017 SJ Standard Edition"

## DATE    "Mon Jul  3 17:55:52 2017"

##
## DEVICE  "5CSEMA5F31C6"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {clock-50}  -period 20.000 -waveform { 0.000 10.000 } [get_ports {CLOCK_50}]
create_clock -name {clock2-50} -period 20.000 -waveform { 0.000 10.000 } [get_ports {CLOCK2_50}]


#**************************************************************
# Create Generated Clock
#**************************************************************

derive_pll_clocks

#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************



#**************************************************************
# Set Input Delay
#**************************************************************

#set_input_delay -clock CLOCK_50 -max 3 [all_inputs]

#set_input_delay -clock CLOCK_50 -min 2 [all_inputs]

#**************************************************************
# Set Output Delay
#**************************************************************

#set_output_delay -clock CLOCK_50 -max 3 [all_inputs]

#set_output_delay -clock CLOCK_50 -min 2 [all_inputs]

#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

