#!/bin/sh
# fullbackup-jffs2.sh
# (C)2012 by martii
# License: GPL, v2 or later

PATH=/usr/bin:/bin:/usr/local/bin:/var/bin:/usr/sbin:/sbin
export PATH

B=/media/sda1/enigma2-`date '+%Y%m%d%H%M%S'`
R=jffs2
U=uImage
mkdir $B
cd $B || exit

echo "Creating uImage"
set `dd if=/dev/mtd5 bs=4 skip=3 count=1 | hexdump -C | head -1`
Z=0x$2$3$4$5
Z=`printf "%d" $Z`
Z=$((64 + $Z))
Z1=$((1 + $Z / 8192))
dd if=/dev/mtd5 of=$U bs=8192 count=$Z1
# truncate may or may not be available. If not, the uImage file
# will be slightly too large, which won't pose a problem.
truncate -s $Z $U 2>/dev/null

echo "Creating JFFS2 image ... please wait."
echo "/dev/console c 0644 0 0 5 1 0 0 0" > devtable
mkdir jffs2
mount --bind / $R
mkfs.jffs2 -v -e 0x20000 -p -U -D devtable -d $R -o tmp.img
sumtool    -v -e 0x20000 -p -i tmp.img -o e2jffs2.img

rm devtable tmp.img

umount $R
rmdir $R

echo "Creating restore script"
# Create restore script
cat >> restore.sh <<EOT
#!/bin/sh
flash_eraseall /dev/mtd5
nandwrite -a -p -m /dev/mtd5 uImage
flash_eraseall -j /dev/mtd6
nandwrite -a -p -m /dev/mtd6 e2jffs2.img
EOT

chmod 755 restore.sh
echo "Done. Image is in $B"

