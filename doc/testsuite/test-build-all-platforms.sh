#!/bin/bash
# (bash is needed for PIPESTATUS)
#
# "testsuite" for the neutrino-mp buildsystem.
#
# builds all configured target platforms, aborts on any error
# crosstool is only built once and then stored for later reuse.
#
# (C) 2013 Stefan Seyfried
# License: WTFPL v2
#

# platforms can be specified on the command line...
PLATFORMS=""
while [ -n "$1" ]; do
	case "$1" in
		tripledragon|spark|azbox|coolstream) ;;
		*)	echo "unknown platform: $1"
			echo "	supported: tripledragon spark azbox coolstream"
			exit 1 ;;
	esac
	PLATFORMS="$PLATFORMS $1"
	shift
done
# ... if none are specified, buid all.
if [ -z "$PLATFORMS" ]; then
	# this unusual notation of the PLATFORMS variable makes it easy
	# to change the order of the targets...
	PLATFORMS="$PLATFORMS tripledragon"
	PLATFORMS="$PLATFORMS spark"
	PLATFORMS="$PLATFORMS azbox"
	PLATFORMS="$PLATFORMS coolstream"
fi

ARCHIVE_DIR=$PWD/Archive
TOOLCHAIN_TARDIR=${ARCHIVE_DIR}/toolchains
if ! test -d $TOOLCHAIN_TARDIR; then
	echo "need toolchain directory $TOOLCHAIN_TARDIR"
	exit 1
fi

# BUILDSYSTEM_SRC=git://gitorious.org/neutrino-hd/buildsystem-cs.git
BUILDSYSTEM_SRC=$PWD/gitorious/neutrino-hd/buildsystem-cs.git
NOW=$(date +%Y%m%d-%H%M)
LOGFILE=$PWD/script.log.$NOW
BUILDLOG=$PWD/build.log.$NOW

NUMCPUS=$(getconf _NPROCESSORS_ONLN)
if [ "$SMP" = "" ]; then
	SMP="-j $((NUMCPUS + 1))"
fi

# TARGETS_ALL_1 is run before platform specific targets
# TARGETS_ALL_1="bootstrap system-pkgs"
TARGETS_ALL_1="bootstrap system-pkgs"
# TARGETS_ALL_2 is run after platform specific targets
TARGETS_ALL_2="mtd-utils flashimage"

# TARGETS_spark="sparkkernel sparkdrivers"
TARGETS_azbox="azboxkernel" # should be a proper dependency in the makefile
TARGETS_coolstream="kernel-patch" # have choice: kernel-patch or kernel-git

log() {
	LOGDATE=$(date +%H:%M:%S)
	echo "${LOGDATE}: $@"
	echo "${LOGDATE}: $@" >> $LOGFILE
	echo "${LOGDATE}: $@" >> ${BUILDLOG}.$P
}

err_hook() {
	log "error building target '$T' for platform '$P'"
	exit 1
}

source_setup() {
	## additional stuff to set up sources, e.g.:
	# mkdir source
	# ln -s /local/src/neutrino-sources/neutrino-mp source/
	# ln -s /local/src/neutrino-sources/libstb-hal  source/
	## this runs before "make preqs".
	return
}

trap err_hook ERR

TOPDIR=$PWD
for P in ${PLATFORMS}; do
	cd $TOPDIR
	T="clone_bs"
	log "$P: starting build"
	test -d bs-$P || git clone $BUILDSYSTEM_SRC bs-$P
	cd bs-$P
	echo "PLATFORM=$P" > config
	echo "GITORIOUS=$TOPDIR/gitorious" >> config
	if [ -d $TOPDIR/uncool-git ]; then
		echo "COOLSTREAM_DE=$TOPDIR/uncool-git" >> config
	fi
	rm -f download
	ln -s $ARCHIVE_DIR download
	T="source_setup"
	source_setup
	T="preqs"
	make preqs
	log "$P: make preqs succeeded"
	# spark toolchain is always unpacked from RPM, no need to tar it up
	if [ "$P" != spark ]; then
		TOOL_TAR=${TOOLCHAIN_TARDIR}/toolchain-${P}.tar.xz
		if [ -e $TOOL_TAR -a -z "$CROSSTOOL_FORCE" ]; then
			T="untar_toolchain"
			log "$P: unpacking $TOOL_TAR"
			tar -xf $TOOL_TAR
		else
			T="crosstool"
			log "$P: building cross toolchain"
			make crosstool
			if [ "$P" = tripledragon ]; then
				T="kernelgcc"
				log "$P: building kernelgcc"
				make kernelgcc
			fi
			T="crosstool_tar"
			test -e $TOOL_TAR && mv $TOOL_TAR ${TOOL_TAR}.$NOW
			tar -cpJf $TOOL_TAR cross
		fi
	else
		T="crosstool"
		make crosstool
	fi
	TARGETS_PLATFORM=$(eval echo \${TARGETS_$P})
	for T in $TARGETS_ALL_1 $TARGETS_PLATFORM $TARGETS_ALL_2; do
		log "$P: building target $T"
		make $SMP $T V=0 2>&1 | tee -a ${BUILDLOG}.$P
		test ${PIPESTATUS[0]} = 0 # if != 0 this will trigger ERR trap
		log "$P: finished target $T"
	done
	cd ..
	rm -rf bs-$P
done
