#! /bin/sh
#
# This generates an .rbf firmware blob for u-boot from a quartus .sof file
#
# Note this points to the shell wrapper bin
#
QUARTUS_BINDIR="${HOME}/intelFPGA_lite/16.1/quartus/bin"

${QUARTUS_BINDIR}/quartus_cpf -c DE1_SOC_Linux_Audio.sof soc_system.rbf

