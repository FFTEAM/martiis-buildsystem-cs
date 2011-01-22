#!/bin/bash
#
# $1 == $(CONTROL_DIR)
#
# Parameters that are passed with environment variables:
# STRIP		- strip binary for target
# MAINTAINER	- maintainer entry
# ARCH		- package arch
# SOURCE	- targetprefix, where the files where installed.
# BUILD_TMP	- tempdir to build the package
set -e

CONTROL_DIR="$1"

test -n "$STRIP"
test -n "$MAINTAINER"
test -n "$ARCH"
test -n "$SOURCE"
test -n "$BUILD_TMP"

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
find root/ -type f ! -name '*.ko' -print0| xargs -0 --no-run-if-empty ${STRIP} || true
sed -i -e "s!@MAINT@!${MAINTAINER}!" -e "s!@ARCH@!${ARCH}!" CONTROL/control
chmod 0755 CONTROL/p* || true	# prerm, postrm, preinst, postinst
tar -cvzf data.tar.gz    --owner=0 --group=0 -C root .
tar -cvzf control.tar.gz --owner=0 --group=0 -C CONTROL . && \
ar -r ${SOURCE}/${PACKAGE}-${VERSION}.opk ./debian-binary ./data.tar.gz ./control.tar.gz
