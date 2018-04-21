## Switch-Linux 
It's Linux for Switch.

![It's Linux for Switch](https://pbs.twimg.com/media/DbPteKUU8AAFzQY.jpg)

### Requirements
- u-boot running from either TrustZone takeover or bootrom hax. Neither is provided currently, however Switch-compatible u-boot can be found [here](https://github.com/shinyquagsire23/u-boot)
- A properly-formatted SD card. Instructions can be found below in **Compiling, Installation and Setup**

### Notes on PSCI
- Nintendo's Horizon OS TrustZone component can provide PSCI calls which work for Linux (given patches provided on the repo). By default, the device tree is configured for Linux running from u-boot packaged in Nintendo's package2, with all PSCI calls being sent to SMC #1 instead of SMC #0.
- Use of other trusted firmwares with PSCI on SMC #0 should be able to remove the need for these patches, however it is untested currently.

### Notes on debugging
- By default, the right Joy-Con rail is used for UART logging output, with pin 5 being the console's TX, and pin 8 being the console's RX. See [here](https://github.com/dekuNukem/Nintendo_Switch_Reverse_Engineering) for details.

### Compiling, Installation and Setup

Installation of u-boot will depend on loading methods used. However once u-boot is installed, the following instructions can be used:

- Make sure your SD card is formatted with MBR partitioning, with the first partition being FAT32/exFAT and a second for ext3/ext4. If ext4 has issues booting, try ext3.
- Download the generic ALARM image [here](https://archlinuxarm.org/platforms/armv8/generic) and follow the instructions provided to install the filesystem to the ext3/ext4 filesystem on your SD card. You may need a Linux box to do these steps.
- Clone linux-next using `git clone git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git`
- `cd linux-next && git checkout v4.15`
- Apply the provided patches in the repo using `git am -3 -k <patch file>`
- NVIDIA has microcode required for their host1x/DRM subsystems. This should be compiled into the kernel or initramfs for early screen init.
    - Download the linux-firmware package from [here](https://archlinuxarm.org/packages/any/linux-firmware)
    - `mkdir extra_firmware`
    - Copy `nvidia/tegra210/vic04_ucode.bin` and `nvidia/tegra210/xusb.bin` from the package to `linux-next/extra_firmware/nvidia/tegra210/vic04_ucode.bin` and `linux-next/extra_firmware/nvidia/tegra210/xusb.bin`
    - It should be noted that while this may be useful for easy debugging, generated kernel images will be dirty and not strictly GPL compliant. It is recommended that, for image-based releases, that these files be installed to the initramfs.
    - TODO: It might be better to just not have an initramfs and have these pulled from the actual root partition, with linux-firmware installed to it.
- Ensure that you have an AArch64 cross-compiler installed.
- `export ARCH=arm64`
- `export CROSS_COMPILE=aarch64-linux-gnu-`
- `mkdir -p build/hac-001/`
- `make O=build/hac-001/ hac_defconfig`
- `make O=build/hac-001/ -j4 Image`
- Copy the Image file from `build/hac-001/arch/arm64/boot/Image` to the `boot/` folder on your SD card's FAT partition.
- In this repo, `mkimage -A arm -T script -O linux -d u-boot/boot.txt u-boot/boot.scr` and copy `boot.scr` to the `boot/` directory on the FAT partition of your SD card.
- `make O=build/hac-001/ -j4 modules`
- `make O=build/hac-001/ modules_install INSTALL_MOD_PATH=/path/to/ALARM/rootfs/`, you may need to run as root (with environment variables set again).
- ALARM has a default initramfs which needs to be wrapped for u-boot. `mkimage -T ramdisk -C gzip -d /path/to/initramfs-linux.img /path/to/FAT/boot/initramfs.uImage`
- In the repo, `cd device-tree && sh build.sh && cp tegra210-hac-001.dtb /path/to/FAT/boot/`
- Your FAT `boot/` directory should have `Image`, `initramfs.uImage`, and `tegra210-hac-001.dtb`
- Boot through u-boot. If an error has occurred, it will open a USB mass storage device for the SD card.

### TODO
- Get USB working
- Get WiFi/BT(?) working
- Get nouveau working
- Get audio working
- Get touchscreen working
- DVFS work?
- DisplayPort? Switch dock drivers?
- Probably a lot more stuff.
