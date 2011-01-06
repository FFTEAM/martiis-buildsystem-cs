#!/bin/bash
#
# $1 == $(CONTROL_DIR)
# $2 == $(TARGET) (for strip)
# $3 == $(MAINTAINER)
# $4 == targetprefix, where the files where installed.
# $5 == $(BUILD_TMP)
set -e

CONTROL_DIR="$1"
TARGET="$2"
MAINTAINER="$3"
SOURCE="$4"
BUILD_TMP="$5"

cd $BUILD_TMP/
rm -rf .opkg
mkdir .opkg
cd .opkg
mkdir root
cp -a $SOURCE/. root/.

cp -a ${CONTROL_DIR} CONTROL
eval $(awk -F":[[:space:]*]" \
	'/^Package:/{print "PACKAGE=\""$2"\""};
	 /^Version:/{print "VERSION=\""$2"\""}' CONTROL/control)
echo "2.0" > debian-binary
find root/ -type f -print0 | xargs -0 --no-run-if-empty ${TARGET}-strip || true
sed -i 's!@MAINT@!$(MAINTAINER)!' CONTROL/control
tar -cvzf data.tar.gz    --owner=0 --group=0 -C root .
tar -cvzf control.tar.gz --owner=0 --group=0 -C CONTROL . && \
ar -r ${SOURCE}/${PACKAGE}-${VERSION}.opk ./debian-binary ./data.tar.gz ./control.tar.gz
