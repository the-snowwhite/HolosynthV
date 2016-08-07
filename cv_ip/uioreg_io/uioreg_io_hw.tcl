# TCL File Generated by Component Editor 16.0
# Fri Aug 05 10:47:57 CEST 2016
# DO NOT MODIFY


# 
# uioreg_io "generic-uio,ui_pdrv" v0
# Michael Brown 2016.08.05.10:47:57
# uio interface
# 

# 
# request TCL package from ACDS 16.0
# 
package require -exact qsys 16.0


# 
# module uioreg_io
# 
set_module_property DESCRIPTION "uio interface"
set_module_property NAME uioreg_io
set_module_property VERSION 1.1
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP Interfaces
set_module_property AUTHOR "Michael Brown"
set_module_property ICON_PATH ../../QuartusProjects/HolosynthIV_DE1SoC-Q15.0_15-inch-lcd/
set_module_property DISPLAY_NAME "generic-uio,ui_pdrv"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false


# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL uioreg_io
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE false
add_fileset_file uioreg_io.v VERILOG PATH uioreg_io.v TOP_LEVEL_FILE
add_fileset_file uioreg_io_hw.tcl OTHER PATH uioreg_io_hw.tcl


# 
# parameters
# 
add_parameter ADDRESS_WIDTH INTEGER 14
set_parameter_property ADDRESS_WIDTH DEFAULT_VALUE 14
set_parameter_property ADDRESS_WIDTH DISPLAY_NAME ADDRESS_WIDTH
set_parameter_property ADDRESS_WIDTH TYPE INTEGER
set_parameter_property ADDRESS_WIDTH UNITS None
set_parameter_property ADDRESS_WIDTH ALLOWED_RANGES -2147483648:2147483647
set_parameter_property ADDRESS_WIDTH HDL_PARAMETER true
add_parameter DATA_WIDTH INTEGER 32
set_parameter_property DATA_WIDTH DEFAULT_VALUE 32
set_parameter_property DATA_WIDTH DISPLAY_NAME DATA_WIDTH
set_parameter_property DATA_WIDTH TYPE INTEGER
set_parameter_property DATA_WIDTH UNITS None
set_parameter_property DATA_WIDTH ALLOWED_RANGES -2147483648:2147483647
set_parameter_property DATA_WIDTH HDL_PARAMETER true
add_parameter IRQ_EN INTEGER 1 "Enable or disable the interrupt capabilities of input ports"
set_parameter_property IRQ_EN DEFAULT_VALUE 1
set_parameter_property IRQ_EN DISPLAY_NAME "Interrupt capabilities"
set_parameter_property IRQ_EN TYPE INTEGER
set_parameter_property IRQ_EN UNITS None
set_parameter_property IRQ_EN ALLOWED_RANGES {0:Disabled 1:Enabled}
set_parameter_property IRQ_EN DESCRIPTION "Enable or disable the interrupt capabilities of input ports"
set_parameter_property IRQ_EN HDL_PARAMETER true


# 
# module assignments
# 
set_module_assignment embeddedsw.dts.group uio-socfpga
set_module_assignment embeddedsw.dts.name uioreg-io
set_module_assignment embeddedsw.dts.params.address_width 14
set_module_assignment embeddedsw.dts.params.data_width 32
set_module_assignment embeddedsw.dts.vendor uioreg_io


# 
# display items
# 
add_display_item "" Interrupt GROUP ""


# 
# connection point clock
# 
add_interface clock clock end
set_interface_property clock clockRate 0
set_interface_property clock ENABLED true
set_interface_property clock EXPORT_OF ""
set_interface_property clock PORT_NAME_MAP ""
set_interface_property clock CMSIS_SVD_VARIABLES ""
set_interface_property clock SVD_ADDRESS_GROUP ""

add_interface_port clock clk clk Input 1


# 
# connection point reset
# 
add_interface reset reset end
set_interface_property reset associatedClock clock
set_interface_property reset synchronousEdges DEASSERT
set_interface_property reset ENABLED true
set_interface_property reset EXPORT_OF ""
set_interface_property reset PORT_NAME_MAP ""
set_interface_property reset CMSIS_SVD_VARIABLES ""
set_interface_property reset SVD_ADDRESS_GROUP ""

add_interface_port reset reset_n reset_n Input 1


# 
# connection point slave
# 
add_interface slave avalon end
set_interface_property slave addressUnits WORDS
set_interface_property slave associatedClock clock
set_interface_property slave associatedReset reset
set_interface_property slave bitsPerSymbol 8
set_interface_property slave burstOnBurstBoundariesOnly false
set_interface_property slave burstcountUnits WORDS
set_interface_property slave explicitAddressSpan 65536
set_interface_property slave holdTime 2
set_interface_property slave isMemoryDevice true
set_interface_property slave linewrapBursts false
set_interface_property slave maximumPendingReadTransactions 0
set_interface_property slave maximumPendingWriteTransactions 0
set_interface_property slave readLatency 0
set_interface_property slave readWaitStates 2
set_interface_property slave readWaitTime 2
set_interface_property slave setupTime 2
set_interface_property slave timingUnits Cycles
set_interface_property slave writeWaitStates 2
set_interface_property slave writeWaitTime 2
set_interface_property slave ENABLED true
set_interface_property slave EXPORT_OF ""
set_interface_property slave PORT_NAME_MAP ""
set_interface_property slave CMSIS_SVD_VARIABLES ""
set_interface_property slave SVD_ADDRESS_GROUP ""

add_interface_port slave slave_address address Input ADDRESS_WIDTH
add_interface_port slave slave_read read Input 1
add_interface_port slave slave_write write Input 1
add_interface_port slave slave_readdata readdata Output DATA_WIDTH
add_interface_port slave slave_writedata writedata Input DATA_WIDTH
add_interface_port slave slave_chipselect chipselect Input 1
set_interface_assignment slave embeddedsw.configuration.isFlash 0
set_interface_assignment slave embeddedsw.configuration.isMemoryDevice 1
set_interface_assignment slave embeddedsw.configuration.isNonVolatileStorage 0
set_interface_assignment slave embeddedsw.configuration.isPrintableDevice 0


# 
# connection point slv_irq
# 
add_interface slv_irq interrupt end
set_interface_property slv_irq associatedAddressablePoint slave
set_interface_property slv_irq associatedClock clock
set_interface_property slv_irq associatedReset reset
set_interface_property slv_irq bridgedReceiverOffset ""
set_interface_property slv_irq bridgesToReceiver ""
set_interface_property slv_irq ENABLED true
set_interface_property slv_irq EXPORT_OF ""
set_interface_property slv_irq PORT_NAME_MAP ""
set_interface_property slv_irq CMSIS_SVD_VARIABLES ""
set_interface_property slv_irq SVD_ADDRESS_GROUP ""

add_interface_port slv_irq slave_irq irq Output 1


# 
# connection point pins
# 
add_interface pins conduit end
set_interface_property pins associatedClock clock
set_interface_property pins associatedReset reset
set_interface_property pins ENABLED true
set_interface_property pins EXPORT_OF ""
set_interface_property pins PORT_NAME_MAP ""
set_interface_property pins CMSIS_SVD_VARIABLES ""
set_interface_property pins SVD_ADDRESS_GROUP ""

add_interface_port pins con_dataout uio_dataout Output DATA_WIDTH
add_interface_port pins con_adrout uio_address Output ADDRESS_WIDTH
add_interface_port pins con_read_out uio_read Output 1
add_interface_port pins con_chip_sel uio_chipsel Output 1
add_interface_port pins con_datain uio_datain Input DATA_WIDTH
add_interface_port pins con_write_out uio_write Output 1
add_interface_port pins con_int_in_n uio_int_in_n Input 1

