#!/bin/bash
#
# USB Stick boot enabler for Coolstream HD1 with newer U-Boot
# (HD1 neo and zee)
#
# (C) 2011 Stefan Seyfried
#     License: GPL v2
#
# create a U-Boot autoscript that can boot from USB
# the USB stick needs 2 partitions:
# * sda1: ext3 with the target partition
# * sda2: fat with the kernel zimage.img
#   tested working: mkdosfs version 3.0.10 with no further options
#
# The USB stick should be known working with the coolstream U-Boot.
#
# The nifty trick is that we put the autoscr into the FLASH partition
# which also holds the bootlogo. The downside is that the bootlogo
# must not be bigger than 126k...
#
# After flashing the splash.img that comes out of this script into
# /dev/mtd1, do the following in the U-Boot prompt:
#
# HDx> setenv bootcmd autoscr 0xf007f800\; bootm 0xf0080000
# HDx> saveenv
#
# (no typos please ;)
# After that, if the USB stick is present, it is used for booting,
# if not, the machine boots from FLASH.

if ! test -e bootlogo.bmp.gz; then
	echo "no bootlogo.bmp.gz"
	echo "if you really want no bootlogo, do 'touch bootlogo.bmp.gz'"
	echo "you can extract the bootlogo on your box with:"
	echo
	echo "zcat /dev/mtd1 | gzip -9 > /tmp/bootlogo.bmp.gz"
	echo
	exit 1
fi
if test $(wc -c < bootlogo.bmp.gz) -gt $((126*1024)); then
	echo "bootlogo.bmp.gz too big (max 126k)"
	exit 1
fi

rm -f build_tmp/splash.img build_tmp/script.img
# conv=sync pads the output to ibs size
dd bs=126k conv=sync if=bootlogo.bmp.gz of=build_tmp/splash.img

# create the u-boot autoscript
rm -f build_tmp/script.scr
# reset the psychedelic u-boot colors early
printf "setenv resetattr \033[0m\n" > build_tmp/script.scr
cat >> build_tmp/script.scr << EOF
printenv resetattr
usb start
fatload usb 0:1 0x08000000 zimage.img
setenv bootargs console=ttyRI0 mtdparts=cx2450xflash:384k(U-Boot)ro,128k(Splash),4096k(kernel),28160k(systemFS) mem=384M panic=5 root=/dev/sda2 rootfstype=ext3 rootdelay=6 rw
bootm 0x08000000
EOF

# create the u-boot image
host/bin/mkimage -A arm -O linux -T script -C none -a 0 -e 0 \
	-n "autoscript" -d build_tmp/script.scr build_tmp/script.img

# append the script image to the splash.img
dd bs=2k if=build_tmp/script.img conv=sync >> build_tmp/splash.img

rm build_tmp/script.img

echo
echo "image to flash:"
ls -l build_tmp/splash.img
echo "copy this onto the box and run 'flashcp splash.img /dev/mtd1'"
echo "(only on neo or zee)!"
echo
