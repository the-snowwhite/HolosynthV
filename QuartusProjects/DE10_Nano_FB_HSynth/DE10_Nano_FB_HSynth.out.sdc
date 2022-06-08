## Generated SDC file "DE10_NANO_SOC_FB.out.sdc"

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

## DATE    "Thu Jul  6 00:14:31 2017"

##
## DEVICE  "5CSEBA6U23I7"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {fpga_clk_1_50} -period 20.000 -waveform { 0.000 10.000 } [get_ports {FPGA_CLK1_50}]
create_clock -name {synthesizer:synthesizer_inst|synth_engine:synth_engine_inst|synth_clk_gen:synth_clk_gen_inst|sCLK_XVXENVS} -period 20.000
create_clock -name {synthesizer:synthesizer_inst|synth_engine:synth_engine_inst|synth_clk_gen:synth_clk_gen_inst|sCLK_XVXOSC} -period 40.000

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



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************

set_false_path -to [get_cells -hierarchical *is_metastable_sig*]

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

