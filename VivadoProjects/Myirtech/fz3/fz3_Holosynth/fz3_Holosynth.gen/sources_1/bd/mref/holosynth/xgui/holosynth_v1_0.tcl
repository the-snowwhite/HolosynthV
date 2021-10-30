# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "AUD_BIT_DEPTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "Invert_rxd" -parent ${Page_0}
  ipgui::add_param $IPINST -name "REG_CLK_FREQUENCY" -parent ${Page_0}
  ipgui::add_param $IPINST -name "V_ENVS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "V_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "a_NUM_VOICES" -parent ${Page_0}
  ipgui::add_param $IPINST -name "b_NUM_OSCS_PER_VOICE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "c_NUM_ENVGENS_PER_OSC" -parent ${Page_0}


}

proc update_PARAM_VALUE.AUD_BIT_DEPTH { PARAM_VALUE.AUD_BIT_DEPTH } {
	# Procedure called to update AUD_BIT_DEPTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AUD_BIT_DEPTH { PARAM_VALUE.AUD_BIT_DEPTH } {
	# Procedure called to validate AUD_BIT_DEPTH
	return true
}

proc update_PARAM_VALUE.Invert_rxd { PARAM_VALUE.Invert_rxd } {
	# Procedure called to update Invert_rxd when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.Invert_rxd { PARAM_VALUE.Invert_rxd } {
	# Procedure called to validate Invert_rxd
	return true
}

proc update_PARAM_VALUE.REG_CLK_FREQUENCY { PARAM_VALUE.REG_CLK_FREQUENCY } {
	# Procedure called to update REG_CLK_FREQUENCY when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.REG_CLK_FREQUENCY { PARAM_VALUE.REG_CLK_FREQUENCY } {
	# Procedure called to validate REG_CLK_FREQUENCY
	return true
}

proc update_PARAM_VALUE.V_ENVS { PARAM_VALUE.V_ENVS } {
	# Procedure called to update V_ENVS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.V_ENVS { PARAM_VALUE.V_ENVS } {
	# Procedure called to validate V_ENVS
	return true
}

proc update_PARAM_VALUE.V_WIDTH { PARAM_VALUE.V_WIDTH } {
	# Procedure called to update V_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.V_WIDTH { PARAM_VALUE.V_WIDTH } {
	# Procedure called to validate V_WIDTH
	return true
}

proc update_PARAM_VALUE.a_NUM_VOICES { PARAM_VALUE.a_NUM_VOICES } {
	# Procedure called to update a_NUM_VOICES when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.a_NUM_VOICES { PARAM_VALUE.a_NUM_VOICES } {
	# Procedure called to validate a_NUM_VOICES
	return true
}

proc update_PARAM_VALUE.b_NUM_OSCS_PER_VOICE { PARAM_VALUE.b_NUM_OSCS_PER_VOICE } {
	# Procedure called to update b_NUM_OSCS_PER_VOICE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.b_NUM_OSCS_PER_VOICE { PARAM_VALUE.b_NUM_OSCS_PER_VOICE } {
	# Procedure called to validate b_NUM_OSCS_PER_VOICE
	return true
}

proc update_PARAM_VALUE.c_NUM_ENVGENS_PER_OSC { PARAM_VALUE.c_NUM_ENVGENS_PER_OSC } {
	# Procedure called to update c_NUM_ENVGENS_PER_OSC when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.c_NUM_ENVGENS_PER_OSC { PARAM_VALUE.c_NUM_ENVGENS_PER_OSC } {
	# Procedure called to validate c_NUM_ENVGENS_PER_OSC
	return true
}


proc update_MODELPARAM_VALUE.a_NUM_VOICES { MODELPARAM_VALUE.a_NUM_VOICES PARAM_VALUE.a_NUM_VOICES } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.a_NUM_VOICES}] ${MODELPARAM_VALUE.a_NUM_VOICES}
}

proc update_MODELPARAM_VALUE.V_WIDTH { MODELPARAM_VALUE.V_WIDTH PARAM_VALUE.V_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.V_WIDTH}] ${MODELPARAM_VALUE.V_WIDTH}
}

proc update_MODELPARAM_VALUE.b_NUM_OSCS_PER_VOICE { MODELPARAM_VALUE.b_NUM_OSCS_PER_VOICE PARAM_VALUE.b_NUM_OSCS_PER_VOICE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.b_NUM_OSCS_PER_VOICE}] ${MODELPARAM_VALUE.b_NUM_OSCS_PER_VOICE}
}

proc update_MODELPARAM_VALUE.c_NUM_ENVGENS_PER_OSC { MODELPARAM_VALUE.c_NUM_ENVGENS_PER_OSC PARAM_VALUE.c_NUM_ENVGENS_PER_OSC } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.c_NUM_ENVGENS_PER_OSC}] ${MODELPARAM_VALUE.c_NUM_ENVGENS_PER_OSC}
}

proc update_MODELPARAM_VALUE.V_ENVS { MODELPARAM_VALUE.V_ENVS PARAM_VALUE.V_ENVS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.V_ENVS}] ${MODELPARAM_VALUE.V_ENVS}
}

proc update_MODELPARAM_VALUE.AUD_BIT_DEPTH { MODELPARAM_VALUE.AUD_BIT_DEPTH PARAM_VALUE.AUD_BIT_DEPTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AUD_BIT_DEPTH}] ${MODELPARAM_VALUE.AUD_BIT_DEPTH}
}

proc update_MODELPARAM_VALUE.Invert_rxd { MODELPARAM_VALUE.Invert_rxd PARAM_VALUE.Invert_rxd } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.Invert_rxd}] ${MODELPARAM_VALUE.Invert_rxd}
}

proc update_MODELPARAM_VALUE.REG_CLK_FREQUENCY { MODELPARAM_VALUE.REG_CLK_FREQUENCY PARAM_VALUE.REG_CLK_FREQUENCY } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.REG_CLK_FREQUENCY}] ${MODELPARAM_VALUE.REG_CLK_FREQUENCY}
}

