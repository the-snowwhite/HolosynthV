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

create_clock -name {clock_50} -period 20.000 -waveform { 0.000 10.000 } [get_ports {CLOCK_50}]
create_clock -name {clock2_50} -period 20.000 -waveform { 0.000 10.000 } [get_ports {CLOCK2_50}]


#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name {synthesizer_inst|audio_pll_inst|audio_pll_inst|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|vcoph[0]} -source [get_pins {synthesizer_inst|audio_pll_inst|audio_pll_inst|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|refclkin}] -duty_cycle 50/1 -multiply_by 217 -divide_by 10 -master_clock {clock_50} [get_pins {synthesizer_inst|audio_pll_inst|audio_pll_inst|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|vcoph[0]}] 
create_generated_clock -name {synthesizer_inst|audio_pll_inst|audio_pll_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk} -source [get_pins {synthesizer_inst|audio_pll_inst|audio_pll_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|vco0ph[0]}] -duty_cycle 50/1 -multiply_by 1 -divide_by 12 -master_clock {synthesizer_inst|audio_pll_inst|audio_pll_inst|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|vcoph[0]} [get_pins {synthesizer_inst|audio_pll_inst|audio_pll_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] 
create_generated_clock -name {synthesizer_inst|audio_pll_inst|audio_pll_inst|altera_pll_i|general[1].gpll~PLL_OUTPUT_COUNTER|divclk} -source [get_pins {synthesizer_inst|audio_pll_inst|audio_pll_inst|altera_pll_i|general[1].gpll~PLL_OUTPUT_COUNTER|vco0ph[0]}] -duty_cycle 50/1 -multiply_by 1 -divide_by 64 -master_clock {synthesizer_inst|audio_pll_inst|audio_pll_inst|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|vcoph[0]} [get_pins {synthesizer_inst|audio_pll_inst|audio_pll_inst|altera_pll_i|general[1].gpll~PLL_OUTPUT_COUNTER|divclk}] 
create_generated_clock -name {u0|pll_stream|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|vcoph[0]} -source [get_pins {u0|pll_stream|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|refclkin}] -duty_cycle 50/1 -multiply_by 12 -divide_by 2 -master_clock {clock_50} [get_pins {u0|pll_stream|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|vcoph[0]}] 
create_generated_clock -name {u0|pll_stream|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk} -source [get_pins {u0|pll_stream|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|vco0ph[0]}] -duty_cycle 50/1 -multiply_by 1 -divide_by 2 -master_clock {u0|pll_stream|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|vcoph[0]} [get_pins {u0|pll_stream|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] 
create_generated_clock -name {u0|pll_stream|altera_pll_i|general[1].gpll~PLL_OUTPUT_COUNTER|divclk} -source [get_pins {u0|pll_stream|altera_pll_i|general[1].gpll~PLL_OUTPUT_COUNTER|vco0ph[0]}] -duty_cycle 50/1 -multiply_by 1 -divide_by 4 -master_clock {u0|pll_stream|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|vcoph[0]} [get_pins {u0|pll_stream|altera_pll_i|general[1].gpll~PLL_OUTPUT_COUNTER|divclk}] 
create_generated_clock -name {synthesizer_inst|sys_disp_pll_inst|sys_pll_inst|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|vcoph[0]} -source [get_pins {synthesizer_inst|sys_disp_pll_inst|sys_pll_inst|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|refclkin}] -duty_cycle 50/1 -multiply_by 12 -divide_by 2 -master_clock {clock_50} [get_pins {synthesizer_inst|sys_disp_pll_inst|sys_pll_inst|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|vcoph[0]}] 
create_generated_clock -name {synthesizer_inst|sys_disp_pll_inst|sys_pll_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk} -source [get_pins {synthesizer_inst|sys_disp_pll_inst|sys_pll_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|vco0ph[0]}] -duty_cycle 50/1 -multiply_by 1 -divide_by 12 -master_clock {synthesizer_inst|sys_disp_pll_inst|sys_pll_inst|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|vcoph[0]} [get_pins {synthesizer_inst|sys_disp_pll_inst|sys_pll_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] 


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {clock_50}] -rise_to [get_clocks {clock_50}] -setup 0.440  
set_clock_uncertainty -rise_from [get_clocks {clock_50}] -rise_to [get_clocks {clock_50}] -hold 0.400  
set_clock_uncertainty -rise_from [get_clocks {clock_50}] -fall_to [get_clocks {clock_50}] -setup 0.440  
set_clock_uncertainty -rise_from [get_clocks {clock_50}] -fall_to [get_clocks {clock_50}] -hold 0.400  
set_clock_uncertainty -fall_from [get_clocks {clock_50}] -rise_to [get_clocks {clock_50}] -setup 0.440  
set_clock_uncertainty -fall_from [get_clocks {clock_50}] -rise_to [get_clocks {clock_50}] -hold 0.400  
set_clock_uncertainty -fall_from [get_clocks {clock_50}] -fall_to [get_clocks {clock_50}] -setup 0.440  
set_clock_uncertainty -fall_from [get_clocks {clock_50}] -fall_to [get_clocks {clock_50}] -hold 0.400  


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

