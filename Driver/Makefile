snd-soc-socsynth-objs := socsynth.o
obj-m += snd-soc-socsynth.o

snd-soc-hsynth-soc-pcm-midi-objs := hsynth-soc-pcm-midi.o
obj-m += snd-soc-hsynth-soc-pcm-midi.o

KERNEL_SRC_DIR="/home/mib/Development/HolosynthV-Image-gen/arm-linux-4.9.33-gnueabifh-kernel/linux-4.9.33"
#KERNEL_SRC_DIR="/home/mib/Development/HolosynthV-Image-gen/arm-linux-4.1.22-gnueabifh-kernel/linux"
PWD=$(shell pwd)
#CROSS_C="/home/mib/Development/Beta3_Project/gcc-linaro-arm-linux-gnueabihf-4.9-2014.09_linux/bin/arm-linux-gnueabihf-"
CROSS_C="/home/mib/bin/gcc-linaro-5.2-2015.11-1-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-"
//NCORES=`nproc`
NCORES=1

all:
	make -j$(NCORES) -C $(KERNEL_SRC_DIR) ARCH=arm CROSS_COMPILE=$(CROSS_C) M=$(PWD) modules

clean:
	make -j$(NCORES) ARCH=arm CROSS_COMPILE=$(CROSS_C) -C $(KERNEL_SRC_DIR) M=$(PWD) clean
