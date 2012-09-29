#!/bin/sh

if [ ! -f /proc/sparkid ] ; then
	echo Please boot from SPARK, then run this program again.
	exit 1
fi

FSTYPE=yaffs2
OPT_FLASHERASEALL=
OPT_NANDWRITE="-o"

#backup
N=/mnt/neutrino
mkdir -p $N 2>/dev/null
mount -t $FSTYPE /dev/mtdblock6 $N
B=backup
mkdir $B
W=`sed -e "s/#.*//" -e "s/^\///" -e "/^ *$/ d"< $N/var/tuxbox/config/tobackup.conf`
tar -C $N -cf - $W | tar -C $B -xf -
umount $N

#install
flash_eraseall /dev/mtd5
nandwrite -a -p -m /dev/mtd5 uImage
flash_eraseall $OPT_FLASHERASEALL /dev/mtd6
nandwrite -a $OPT_NANDWRITE /dev/mtd6 e2$FSTYPE.img

#restore
mount -t $FSTYPE /dev/mtdblock6 $N
tar -C $B -cf - . | tar -C $N -xf -
umount $N

