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

#
# the embedded u-boot script does the following:
# * it checks if there is a *directory* 'spark.run' in the boot partition
#   (this will usually be sda1). If this directory is present, it boots
#   the SPARK kernel from flash
# * next, it checks if there is a directory 'enigma2.run' in the boot
#   partition. If it finds one, then the "enigma2" kernel/partition is
#   booted from flash. Of course there can be anything in the enigma2
#   partition, not only enigma2.
# * if both checks fail, it finally boots from flash.
#
# This allows to create plugin scripts for neutrino/enigma/spark that
# allow to easily switch to any of the 3 boot options (flash1 aka spark,
# flash2 aka enigma2 and USB).
# Example script for spark (put it into /var/bin/boot_usb.sh):
#
# #!/bin/sh
# ## the /storage/c might be different if an USB HDD is present...
# rmdir /storage/c/spark.run
# rmdir /storage/c/enigma2.run
#
# Example script for neutrino to switch from usb to spark:
#
# #!/bin/sh
# rmdir /media/sda1/enigma2.run
# mkdir /media/sda1/spark.run
#
rm -f build_tmp/script.img
# create the u-boot autoscript
rm -f build_tmp/script.scr
cat > build_tmp/script.scr << EOF
echo "checking if boot from FLASH is requested..."
if fatls usb 0:1 spark.run; then
	echo "...yes, booting SPARK from FLASH"
	setenv bootargs \${bootargs_spark}
	if test \${board} = pdk7105; then
		echo "SPARK7162 -> nboot.i"
		nboot.i 0x80000000 0 \${kernel_base_spark}
		bootm 0x80000000
		# does (should :-) not return
	fi
	echo "no SPARK7162 -> direct bootm"
	bootm \${kernel_base_spark}
	# we should not reach this...
	exit
fi
if fatls usb 0:1 enigma2.run; then
	echo "...yes, booting ENIGMA partition from FLASH"
	setenv bootargs \${bootargs_enigma2}
	nboot.i 0x80000000 0 \${kernel_base_enigma2}
	bootm 0x80000000
	# again, this should not return...
	exit
fi
echo "...no, booting from USB..."
if test \${board} = pdk7105; then
fatload usb 0:1 80000000 uImage-7162
else
fatload usb 0:1 80000000 uImage
fi
setenv bootargs console=ttyAS0,115200 root=/dev/sda2 rootfstype=ext3 rw coprocessor_mem=4m@0x40000000,4m@0x40400000 printk=1 printk.time=1 nwhwconf=device:eth0,hwaddr:00:80:E1:12:40:69 bigphysarea=6000 stmmaceth=msglvl:0,phyaddr:2,watchdog:5000 panic=10 rootwait usb_storage.delay_use=0
bootm 80000000
EOF

# create the u-boot image
cross/host/bin/mkimage -A sh -O linux -T script -C none -a 0 -e 0 \
	-n "autoscript" -d build_tmp/script.scr build_tmp/script.img
