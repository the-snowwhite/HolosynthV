#!/bin/sh
set -e  # Exit immediately if a command exits with a non-zero status
set -x  # print commands

# Builds Boot files for the mpsoc HW using Petalinux. Pass in the board name
# for the project you want to build. Expects Xilinx tools to be installed in
# /opt/Xilinx like in the docker image.

usage () {
    echo "Usage: make_mpsoc_boot.sh boardname"
    exit 1
}

if [ -z "$1" ]; then
    usage
fi

CUR_DIR=`realpath .`

case $1 in

  *"ultra96"*)
#    cd /work/HW/VivadoProjects/avnet/ultra96
    cd /work/VivadoProjects/Avnet
    BOARD_PART="xczu3eg"
    ;;

  *"fz3"*)
    cd /work/VivadoProjects/Myirtech/fz3
    BOARD_PART="xczu3eg"
    ;;

  *"ultramyir"*)
    cd /work/VivadoProjects/Myirtech/ultramyir
    BOARD_PART="xczu3eg"
    ;;

  *)
    echo "cant't find board project folder"
    exit 1
    ;;
esac

# Delete any old project artifacts folder
PRJ_DIR_CREATED=./"$1"-holosynthv-"$PETALINUX_VER"
[ -d "$PRJ_DIR_CREATED" ] && rm -rf "$PRJ_DIR_CREATED"

petalinux-create -t project -s "$1"-holosynthv-"$PETALINUX_VER".bsp
cd "$1"-holosynthv-"$PETALINUX_VER"
#time petalinux-config --get-hw-description=../"$1"_"$BOARD_PART"_created/"$1"_"$BOARD_PART".sdk --silentconfig
time petalinux-config --get-hw-description=../"$1"_Holosynth --silentconfig
time petalinux-build
petalinux-package --boot --fsbl images/linux/zynqmp_fsbl.elf --u-boot=images/linux/u-boot.elf --pmufw --atf --fpga images/linux/system.bit --force
tar -xzf ./images/linux/rootfs.tar.gz ./lib/modules  && tar -czf ../lib.tar.gz ./lib && rm -r lib
