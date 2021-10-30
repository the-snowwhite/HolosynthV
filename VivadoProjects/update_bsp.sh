#!/bin/sh
set -e  # Exit immediately if a command exits with a non-zero status
set -x  # print commands

# Builds Boot files for the mpsoc HW using Petalinux. Pass in the board name
# for the project you want to build. Expects Xilinx tools to be installed in
# /opt/Xilinx like in the docker image.

usage () {
    echo "Usage: update_bsp.sh boardname"
    exit 1
}

if [ -z "$1" ]; then
    usage
fi

CUR_DIR=`realpath .`

case $1 in

  *"ultra96"*)
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

cd "$1"-holosynthv-"$PETALINUX_VER"
petalinux-package --prebuilt --clean
petalinux-package --prebuilt
cd ./pre-built/linux/images/
rm bl31.* config 
rm *.elf rootfs.* u-boot.bin u-boot-dtb.bin vmlinux zynqmp-qemu*.* 
rm -r  pxelinux.cfg ../etc ../implementation
cd ../../..
petalinux-build -x distclean
petalinux-build -x mrproper
petalinux-package --bsp --force --output ../"$1"-holosynthv-"$PETALINUX_VER".bsp -p ./
cd ..
tar cfS "$1"-holosynthv-"$PETALINUX_VER".tar.bz2 ./"$1"-holosynthv-"$PETALINUX_VER" --use-compress-program lbzip2
