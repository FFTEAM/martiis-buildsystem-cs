#!/bin/sh

if [ ! -f /proc/sparkid ] ; then
	echo Please boot from SPARK, then run this program again.
	exit 1
fi

#install
flash_eraseall /dev/mtd5
nandwrite -a -p -m /dev/mtd5 uImage
flash_eraseall /dev/mtd6
nandwrite -a -o /dev/mtd6 e2yaffs2.img

