# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "AUD_BIT_DEPTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "FIFO_WIDTH" -parent ${Page_0}


}

proc update_PARAM_VALUE.AUD_BIT_DEPTH { PARAM_VALUE.AUD_BIT_DEPTH } {
	# Procedure called to update AUD_BIT_DEPTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AUD_BIT_DEPTH { PARAM_VALUE.AUD_BIT_DEPTH } {
	# Procedure called to validate AUD_BIT_DEPTH
	return true
}

proc update_PARAM_VALUE.FIFO_WIDTH { PARAM_VALUE.FIFO_WIDTH } {
	# Procedure called to update FIFO_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.FIFO_WIDTH { PARAM_VALUE.FIFO_WIDTH } {
	# Procedure called to validate FIFO_WIDTH
	return true
}


proc update_MODELPARAM_VALUE.FIFO_WIDTH { MODELPARAM_VALUE.FIFO_WIDTH PARAM_VALUE.FIFO_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.FIFO_WIDTH}] ${MODELPARAM_VALUE.FIFO_WIDTH}
}

proc update_MODELPARAM_VALUE.AUD_BIT_DEPTH { MODELPARAM_VALUE.AUD_BIT_DEPTH PARAM_VALUE.AUD_BIT_DEPTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AUD_BIT_DEPTH}] ${MODELPARAM_VALUE.AUD_BIT_DEPTH}
}

