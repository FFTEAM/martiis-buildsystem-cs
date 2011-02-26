#!/bin/bash
#
# helper script to build a USB stick image
#
# (C) 2011 Stefan Seyfried
#     License: GPL v2
#
# * the kernel Image has to already exist in build_tmp
# * a rootfs (target minimal-system-pkgs or system-pkgs) has to
#   exist in build_tmp/install
#
# The image will have two partitions:
# * partition 1, fat16 ~15MB for the kernel
# * partition 2, ext3, the root fs
#
# the size in million bytes, hopefully smaller than the USB stick ;)
SIZE=500

# create the empty image (sparse, to save time)
rm -f build_tmp/usb.img
dd if=/dev/zero of=build_tmp/usb.img bs=1 count=1 seek=$(($SIZE * 1000000 - 1))

# add partitions
parted build_tmp/usb.img mklabel msdos
parted -a none build_tmp/usb.img mkpart primary fat16 0 15
parted -a none build_tmp/usb.img mkpart primary ext2 15 $SIZE

mkdir -p build_tmp/usbstick/p1 build_tmp/usbstick/p2
sudo bash << EOF
# map the image so that we can mount see the partitions in the image
kpartx -v -a -p -usbstick- build_tmp/usb.img

# create the filesystems
mkdosfs   -n KERNEL  /dev/mapper/*-usbstick-1
mkfs.ext3 -L root-fs /dev/mapper/*-usbstick-2

# mount the partitions
mount /dev/mapper/*-usbstick-1 build_tmp/usbstick/p1
mount /dev/mapper/*-usbstick-2 build_tmp/usbstick/p2

# copy kernel...
cp build_tmp/*Image.img build_tmp/usbstick/p1
# ...and rootfs
cp -a build_tmp/install/.  build_tmp/usbstick/p2
# create /dev/console for first boot
# sudo mknod -m 644 build_tmp/usbstick/p2/dev/console c 5 1

# unmount everything
umount build_tmp/usbstick/p*

# unbind the loop devices
kpartx -v -d -p -usbstick- build_tmp/usb.img
EOF

echo
echo "the usb boot image is now in build_tmp/usb.img"
echo
ls -l build_tmp/usb.img
echo
