# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "IMG_H" -parent ${Page_0}
  ipgui::add_param $IPINST -name "IMG_W" -parent ${Page_0}
  ipgui::add_param $IPINST -name "TBITS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "TBYTE" -parent ${Page_0}


}

proc update_PARAM_VALUE.IMG_H { PARAM_VALUE.IMG_H } {
	# Procedure called to update IMG_H when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.IMG_H { PARAM_VALUE.IMG_H } {
	# Procedure called to validate IMG_H
	return true
}

proc update_PARAM_VALUE.IMG_W { PARAM_VALUE.IMG_W } {
	# Procedure called to update IMG_W when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.IMG_W { PARAM_VALUE.IMG_W } {
	# Procedure called to validate IMG_W
	return true
}

proc update_PARAM_VALUE.TBITS { PARAM_VALUE.TBITS } {
	# Procedure called to update TBITS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.TBITS { PARAM_VALUE.TBITS } {
	# Procedure called to validate TBITS
	return true
}

proc update_PARAM_VALUE.TBYTE { PARAM_VALUE.TBYTE } {
	# Procedure called to update TBYTE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.TBYTE { PARAM_VALUE.TBYTE } {
	# Procedure called to validate TBYTE
	return true
}


proc update_MODELPARAM_VALUE.IMG_H { MODELPARAM_VALUE.IMG_H PARAM_VALUE.IMG_H } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.IMG_H}] ${MODELPARAM_VALUE.IMG_H}
}

proc update_MODELPARAM_VALUE.IMG_W { MODELPARAM_VALUE.IMG_W PARAM_VALUE.IMG_W } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.IMG_W}] ${MODELPARAM_VALUE.IMG_W}
}

proc update_MODELPARAM_VALUE.TBITS { MODELPARAM_VALUE.TBITS PARAM_VALUE.TBITS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.TBITS}] ${MODELPARAM_VALUE.TBITS}
}

proc update_MODELPARAM_VALUE.TBYTE { MODELPARAM_VALUE.TBYTE PARAM_VALUE.TBYTE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.TBYTE}] ${MODELPARAM_VALUE.TBYTE}
}

