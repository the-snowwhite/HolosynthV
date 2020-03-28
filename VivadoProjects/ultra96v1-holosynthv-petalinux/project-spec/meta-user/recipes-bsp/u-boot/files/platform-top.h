#include <configs/platform-auto.h>
#define CONFIG_SYS_BOOTM_LEN 0xF000000

#define DFU_ALT_INFO_RAM \
                "dfu_ram_info=" \
        "setenv dfu_alt_info " \
        "image.ub ram $netstart 0x1e00000\0" \
        "dfu_ram=run dfu_ram_info && dfu 0 ram 0\0" \
        "thor_ram=run dfu_ram_info && thordown 0 ram 0\0"

#define DFU_ALT_INFO_MMC \
        "dfu_mmc_info=" \
        "set dfu_alt_info " \
        "${kernel_image} fat 0 1\\\\;" \
        "dfu_mmc=run dfu_mmc_info && dfu 0 mmc 0\0" \
        "thor_mmc=run dfu_mmc_info && thordown 0 mmc 0\0"

/*Required for uartless designs */
#ifndef CONFIG_BAUDRATE
#define CONFIG_BAUDRATE 115200
#ifdef CONFIG_DEBUG_UART
#undef CONFIG_DEBUG_UART
#endif
#endif

#define CONFIG_CMD_DNS

#define CONFIG_EXTRA_ENV_SETTINGS \
"autoload=yes\0" \
"hostname=holosynthv-u96\0" \
"default_bootcmd=mmcinfo && fatload mmc 0 " \
    "10000000 image.ub && bootm 10000000\0" \
"4.19tftpboot=setenv bootargs console=ttyPS0,115200 " \
    "root=/dev/mmcblk0p2 rw earlyprintk rootwait;" \
    "usb start && dhcp 8000000 design_1_wrapper.bit && " \
    "fpga load 0 8000000 $filesize && mmcinfo && " \
    "load mmc 0 10000000 Image && load mmc 0 16000000" \
    " avnet-ultra96-rev1.dtb && booti 10000000 - 16000000\0"
