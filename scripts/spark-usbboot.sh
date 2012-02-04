#!/bin/bash
#
# USB Stick boot enabler for fulan SPARK box (tested with
# GoldenMedia GM990)
#
# (C) 2012 Stefan Seyfried
#     License: GPL v2 or later
#
# Note: to get the GM990 to enable the serial console in u-boot,
#       you need to boot the box with "Menu" key pressed until "UP"
#       is displayed on the LEDs.
#
# create a U-Boot autoscript that can boot from USB
# the USB stick needs 2 partitions:
# * sda1: fat with the kernel uImage
# * sda2: ext2 with the target partition
#
# this autoscript is put into the fat partition, together with
# the kernel.
#
# then change your bootargs like the following:
#
# first copy your original bootcmd:
# MB618> setenv bootcmd_fromflash ${bootcmd}
# MB618> saveenv
#
# then set the new bootcmd:
# MB618> setenv bootcmd usb start\;fatload usb 0 81000000 script.img\;autoscr 81000000\;run bootcmd_fromflash
#
# do not yet saveenv! first boot once manually without a plugged
# USB stick to verify the fallback:
#
# MB618> boot
#
# the box now must boot the previously configured image.
# if this works, reboot into u-boot, attach the USB stick,
#
# MB618> setenv bootcmd usb start\;fatload usb 0 81000000 script.img\;autoscr 81000000\;run bootcmd_fromflash
# MB618> boot
#
# now it should boot from the USB stick. If this worked as well,
# you can "saveenv" the new bootcmd.
#
# Good luck. And have a lot of fun...

rm -f build_tmp/script.img
# create the u-boot autoscript
rm -f build_tmp/script.scr
cat > build_tmp/script.scr << EOF
fatload usb 0:1 80000000 uImage
setenv bootargs console=ttyAS0,115200 root=/dev/sda2 rootfstype=ext2 rw coprocessor_mem=4m@0x40000000,4m@0x40400000 printk=1 nwhwconf=device:eth0,hwaddr:00:80:E1:12:40:69 bigphysarea=6000 stmmaceth=msglvl:0,phyaddr:2,watchdog:5000 panic=10 rootwait
bootm 80000000
EOF

# create the u-boot image
cross/host/bin/mkimage -A sh -O linux -T script -C none -a 0 -e 0 \
	-n "autoscript" -d build_tmp/script.scr build_tmp/script.img
