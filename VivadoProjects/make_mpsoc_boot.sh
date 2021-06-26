#!/bin/sh
set -e  # Exit immediately if a command exits with a non-zero status
set -x  # print commands

# Builds Boot files for the mpsoc HW using Petalinux. Pass in the board name
# for the project you want to build. Expects Xilinx tools to be installed in
# /opt/Xilinx like in the docker image.

usage () {
    echo "Usage: make_mpsoc_boot.sh boardname [-nobsp]"
    echo "Usage: use -nobsp to skip deletion and recreation of bsp folder"
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
    ;;

  *"fz3"*)
    cd /work/VivadoProjects/Myirtech/fz3
    ;;

  *"ultramyir"*)
    cd /work/VivadoProjects/Myirtech/ultramyir
    ;;

  *"k26-stkit"*)
    cd /work/VivadoProjects/Xilinx/k26-stkit
    ;;

  *)
    echo "cant't find board project folder"
    exit 1
    ;;
esac

# Delete any old project artifacts folder
PRJ_DIR_CREATED=./"$1"-holosynthv-"$PETALINUX_VER"
if [ "${2}" != "-nobsp" ]; then
    [ -d "$PRJ_DIR_CREATED" ] && rm -rf "$PRJ_DIR_CREATED"
    petalinux-create -t project -s "$1"-holosynthv-"$PETALINUX_VER".bsp
fi
cd "$1"-holosynthv-"$PETALINUX_VER"
petalinux-config --get-hw-description=../"$1"_Holosynth --silentconfig
petalinux-build
petalinux-package --boot --fsbl images/linux/zynqmp_fsbl.elf --u-boot=images/linux/u-boot.elf --pmufw --atf --fpga images/linux/system.bit --force
tar -xzf ./images/linux/rootfs.tar.gz ./lib/modules  && tar -czf ../lib.tar.gz ./lib && rm -r lib
