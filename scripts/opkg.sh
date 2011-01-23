#!/bin/bash
#
# opkg.sh: script to build an opk package from an installed directory and
#          matching control files.
#
#          Copyright (C) 2011 Stefan Seyfried
#          Released under the GNU General Public License (GPL) Version 2
#
# $1 == $(CONTROL_DIR)
#
# Parameters are passed with environment variables:
# * mandatory parameters
# STRIP		- strip binary for target
# MAINTAINER	- maintainer entry, @MAINT@ in control files is replaced with it.
# ARCH		- package arch, @ARCH@ in control files is replaced with it.
# SOURCE	- targetprefix, where the files where installed.
# BUILD_TMP	- tempdir to build the package
# * non mandatory parameters
# PACKAGE_DIR	- directory to copy the built package to. If the same package
#		  version is already present there, compare and skip copying if equal
# DONT_STRIP	- if this is not empty, don't strip files
#
# This is intended to be used in Makefiles, so only ever exit with non-zero
# if there was an error.

# exit on errors. Don't cover up.
set -e
ME=${0##*/}

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
# extract package name and version from control file...
eval $(awk -F":[[:space:]*]" \
	'/^Package:/{print "PACKAGE=\""$2"\""};
	 /^Version:/{print "VERSION=\""$2"\""}' CONTROL/control)
echo "2.0" > debian-binary
if test -z "$DONT_STRIP"; then
	# || true because failure to strip is not fatal
	find root/ -type f ! -name '*.ko' -print0| xargs -0 --no-run-if-empty ${STRIP} || true
else
	echo "${ME}: DONT_STRIP is set, not stripping anything"
fi
sed -i -e "s!@MAINT@!${MAINTAINER}!" -e "s!@ARCH@!${ARCH}!" CONTROL/control
chmod 0755 CONTROL/p* || true	# prerm, postrm, preinst, postinst
if test -e CONTROL/conffiles; then
	touch CONTROL/conffiles.new
	while read a; do
		if ! test -e root/$a; then
			echo "${ME}: WARNING conffile $a does not exist, skipping"
			continue;
		fi
		echo $a >> CONTROL/conffiles.new
	done < CONTROL/conffiles
	rm CONTROL/conffiles
	test -s CONTROL/conffiles.new && mv CONTROL/conffiles.new CONTROL/conffiles
fi
echo "${ME}: root contents:"
out=$(tar -cvzf data.tar.gz    --owner=0 --group=0 -C root .)
for file in $out; do
	# skip directories, they are not that interesting
	test "${file:$((${#file}-1))}" = "/" && continue
	# mark configfiles, makes it easier to check if everything is ok in control/conffiles
	if test -e CONTROL/conffiles && grep -q "^${file#.}$" CONTROL/conffiles; then
		echo "conf $file"
	elif test -L root/$file; then
		link=$(readlink root/$file)
		ldir=${file%/*}
		stat="  WARNING: broken link, check your package setup!"
		# tricky: absolute links needs to be resolved inside chroot...
		# echo "link: '${link}' ldir: '${ldir}' file: '${file}'"
		case $link in
		/proc/*)stat="" ;; # skip links to /proc/mounts etc...
		/*)	test -e root/$link  && stat="" || true ;;
		*)	readlink -qe root/$file >/dev/null && stat="" || true ;;
		esac
		echo "link $file -> $link $stat";
	else
		echo "     $file"
	fi
done
echo "${ME}: control contents:"
tar -cvzf control.tar.gz --owner=0 --group=0 -C CONTROL .
PKG=${PACKAGE}-${VERSION}.opk
ar -r ${SOURCE}/${PKG} ./debian-binary ./data.tar.gz ./control.tar.gz

# for backwards compatibility, just exit if PACKAGE_DIR is not set
test -z "$PACKAGE_DIR" && exit 0

# check if the package already exists...
if test -e ${PACKAGE_DIR}/${PKG}; then
	EQUAL=true;
	echo "${ME}: package $PKG already exists, comparing..."
	mkdir oldroot oldCONTROL
	ar p ${PACKAGE_DIR}/${PKG} control.tar.gz | tar -xzf - -C oldCONTROL
	ar p ${PACKAGE_DIR}/${PKG} data.tar.gz    | tar -xzf - -C oldroot
	#
	# check for symlink differences, diff does not like dangling symlinks
	NEWLINKS=$(cd root && find . -type l | sort)
	OLDLINKS=$(cd oldroot && find . -type l | sort)
	if test "$NEWLINKS" != "$OLDLINKS"; then
		echo "${ME}: package content differs, overwriting..."
		EQUAL=false
	else
		for link in $NEWLINKS; do
			test $(readlink oldroot/$link) = $(readlink root/$link) && continue || true
			echo "${ME}: package content differs, overwriting..."
			EQUAL=false
			break
		done
	fi
	if $EQUAL; then
		# remove symlinks, already checked above.
		find {old,}root -type l | xargs --no-run-if-empty rm
		if ! diff -r {old,}root > /dev/null; then
			echo "${ME}: package content differs, overwriting..."
		elif ! diff -r {old,}CONTROL > /dev/null; then
			echo "${ME}: package metadata differs, overwriting..."
		else
			echo "${ME}: package content and metadata is identical, keeping old package"
			exit 0
		fi
	fi
else
	echo "$ME: package does not exist in $PACKAGE_DIR, copying..."
fi
cd $SOURCE
mv -v $PKG $PACKAGE_DIR
