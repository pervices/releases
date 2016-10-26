Per Vices Crimson TNG Testing Release
==========================

## MCU
The files in this directory contains the utility and the latest code that
are used to flash the MCU

## FPGA
The code here is the FPGA binary. Copy it into the boot partition of the
SD Card.

## SD Card
The files here are used to generate the SD Card image. This includes uboot image,
preloader image, device tree blob, Linux kernel configuration file for Crimson TNG. A single important binary is _missing_.
Please visit the [PV servers]() for pervices-sd-image-arria5.tar.gz
as that is a larger file. Execute the following to build.
```
mkdir rootfs
sudo tar -xzf pervices-sd-image-arria5.tar.gz -C rootfs
sudo ./make_sdimage.py -f -P preloader-mkpimage.bin,u-boot-arria5.img,num=3,format=raw,size=50M,type=A2 -P rootfs/*,num=2,format=ext3,size=3000M -P zImage,u-boot.scr,soc_system.rbf,socfpga.dtb,num=1,format=vfat,size=500M -s 4G -n sdcard.img
```
