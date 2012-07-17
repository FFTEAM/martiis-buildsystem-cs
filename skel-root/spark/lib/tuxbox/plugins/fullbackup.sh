#!/bin/sh
# fullbackup.sh
# (C)2012 by martii
# License: GPL, v2 or later

PATH=/usr/bin:/bin:/usr/local/bin:/var/bin:/usr/sbin:/sbin
export PATH

grep -q "^/dev/root.*yaffs" /proc/mounts && exec ${0/\./-yaffs2.}
grep -q "^/dev/root.*jffs" /proc/mounts && exec ${0/\./-jffs2.}
echo "Neither jffs2 nor yaffs2 file system detected"
