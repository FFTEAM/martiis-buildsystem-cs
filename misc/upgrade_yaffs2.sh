#!/bin/sh

if [ ! -f /proc/sparkid ] ; then
	echo Please boot from SPARK, then run this program again.
	exit 1
fi

#backup
N=/mnt/neutrino
mkdir -p $N 2>/dev/null
mount -t yaffs2 /dev/mtdblock6 $N
B=backup
mkdir $B
W=""
[ -f /root/neutrino-backup-files ] && W=`grep -v ^# /root/neutrino-backup-files`
W="$W
root
var/tuxbox/config
opt/pkg/etc/dropbear
etc/network/interfaces
etc/resolv.conf
etc/modules.extra
"
tar -C $N -cf - $W | tar -C $B -xf -
umount $N

#install
flash_eraseall /dev/mtd5
nandwrite -a -p -m /dev/mtd5 uImage
flash_eraseall /dev/mtd6
nandwrite -a -o /dev/mtd6 e2yaffs2.img

#restore
mount -t yaffs2 /dev/mtdblock6 $N
tar -C backup -cf - . | tar -C $N -xf -
umount $N

