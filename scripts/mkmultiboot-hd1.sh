#!/bin/bash
#
# USB Stick boot enabler for Coolstream HD1 with old U-Boot
# HD1, HD1 BSE and HD1 C
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
# which also holds the kernel. The downside is that the kernel
# must not be bigger than 4094k...
#
# After flashing the splash.img that comes out of this script into
# /dev/mtd1, do the following in the U-Boot prompt:
#
# HDx> setenv bootcmd autoscr 0xf047f800\; bootm 0xf0080000
# HDx> saveenv
#
# (no typos please ;)
# After that, if the USB stick is present, it is used for booting,
# if not, the machine boots from FLASH.

IN=mtd1-hd1.img
OUT=build_tmp/kernel-autoscr-mtd1.img

if ! test -e $IN; then
	echo "no $IN, but we need it."
	echo "you can extract the mtd1 on your box:"
	echo
	echo "cat /dev/mtd1 > /tmp/mtd1-hd1.img"
	echo
	exit 1
fi

# find out the payload size of the kernel image...
KSIZE=$(dd if=$IN bs=4 skip=3 count=1 2>/dev/null|hexdump -e '4 1 "%x"')
KSIZE=$((0x$KSIZE + 64))
echo "Kernel image size: $KSIZE"
if test $KSIZE -gt $((4094*1024)); then
	echo "Kernel image size too big."
	echo "Maximum size is 4094kB ($((4094*1024)))"
	echo
	exit 1
fi

rm -f build_tmp/script.img $OUT
# conv=sync pads the output to ibs size
dd bs=4094k conv=sync if=$IN of=$OUT count=1

# create the u-boot autoscript
rm -f build_tmp/script.scr
# reset the psychedelic u-boot colors early
printf "setenv resetattr \033[0m\n" > build_tmp/script.scr
cat >> build_tmp/script.scr << EOF
printenv resetattr
usb start
fatload usb 0:1 0x08000000 zimage.img
setenv bootargs console=ttyRI0 mtdparts=cx2450xflash:512k(U-Boot)ro,4096k(kernel),28160k(systemFS) mem=384M panic=5 root=/dev/sda2 rootfstype=ext3 rootwait rw printk.time=1
bootm 0x08000000
EOF

# create the u-boot image
host/bin/mkimage -A arm -O linux -T script -C none -a 0 -e 0 \
	-n "autoscript" -d build_tmp/script.scr build_tmp/script.img

# append the script image to the splash.img
dd bs=2k if=build_tmp/script.img conv=sync >> $OUT

rm build_tmp/script.img

echo
echo "image to flash:"
ls -l $OUT
echo "copy this onto the box and run 'flashcp $(basename $OUT) /dev/mtd1'"
echo "(only on hd1!)"
echo
