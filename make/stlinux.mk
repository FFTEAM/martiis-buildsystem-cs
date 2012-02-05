STLINUX     = stlinux24
STLINUX_DIR = $(BUILD_TMP)/$(STLINUX)

## not yet needed
HOST_ARCH := $(shell uname -m)

RPMS        = $(STLINUX_DIR)/RPMS
RPMS_ARCH   = $(STLINUX_DIR)/RPMS/$(HOST_ARCH)
RPMS_NOARCH = $(STLINUX_DIR)/RPMS/noarch
SPECS       = $(STLINUX_DIR)/SPECS
SOURCES     = $(STLINUX_DIR)/SOURCES
STL_PATCHES = $(PATCHES)/stlinux
STM_RELOCATE = /opt/STM/STLinux-2.4

DRPM = --macros /usr/lib/rpm/macros:$(STLINUX_DIR)/config/rpm/targets/sh4-linux:$(STLINUX_DIR)/config/rpm/common:$(STLINUX_DIR)/localmacros
DRPMBUILD = --macros /usr/lib/rpm/macros:$(STLINUX_DIR)/config/rpm/targets/sh4-linux:$(STLINUX_DIR)/config/rpm/common:$(STLINUX_DIR)/localmacros

## most of the entries are not yet needed...
$(STLINUX_DIR)/localmacros:
	rm -f $@
	echo "%_topdir $(STLINUX_DIR)" >> $@
	echo "%_specdir %_topdir/SPECS" >> $@
	echo "%_sourcedir %_topdir/SOURCES" >> $@
	echo "%_builddir %_topdir/BUILD" >> $@
	echo "%_buildrootdir %_topdir/BUILDROOT" >> $@
	echo "%buildroot %_topdir/BUILDROOT/%{name}-%{version}-%{release}.x86_64" >> $@
	echo "%_rpmdir %_topdir/RPMS" >> $@
	echo "%_srcrpmdir %_topdir/SRPMS" >> $@
	echo "%_stm_install_prefix $(STLINUX_DIR)" >> $@
	echo "%_stm_base_prefix $(STLINUX_DIR)/base" >> $@
	echo "%_stm_host_dir $(STLINUX_DIR)/host" >> $@
	echo "%_stm_cross_dir $(CROSS_DIR)" >> $@
	echo "%_stm_config_dir $(STLINUX_DIR)/config" >> $@
	echo "%_stm_devkit_dir $(STLINUX_DIR)/devkit" >> $@
	echo "%_stm_cross_target_dir $(TARGETPREFIX)" >> $@
	echo "%_stm_kernel_dir $(STLINUX_DIR)/kernel" >> $@
	echo "%_stm_sources_dir $(STLINUX_DIR)/kernel" >> $@
	echo "%_stm_host_arch `uname -m`" >> $@
	echo "%_stm_host_cpu `uname -m`" >> $@
	echo "%_stm_host_config `uname -m`-unknown-linux-gnu" >> $@
	echo "%_dbpath $(STLINUX_DIR)/cdkroot-rpmdb" >> $@
	echo "%__bzip2 /usr/bin/bzip2" >> $@
	echo "%nohostbuilddeps 1" >> $@
	echo "%_default_patch_fuzz 2" >> $@

## have your stlinux ISOs in this place...
STLINUX_ISODIR ?= /space/iso/stlinux
STLINUX_SH4_ISO = $(STLINUX_ISODIR)/STLinux-2.4-sh4-20100401.iso
STLINUX_SRC_ISO = $(STLINUX_ISODIR)/STLinux-2.4-source-20111019.iso
STLINUX_SH4_MNT = $(BUILD_TMP)/iso/sh4
STLINUX_SRC_MNT = $(BUILD_TMP)/iso/src
ST_SH4_RPMS = $(STLINUX_SH4_MNT)/STLinux/sh4

# updates / downloads
STL_ARCHIVE = $(ARCHIVE)/stlinux
STL_FTP = http://ftp.stlinux.com/pub/stlinux/2.4
STL_FTP_UPD_SRC  = $(STL_FTP)/updates/SRPMS
STL_FTP_UPD_SH4  = $(STL_FTP)/updates/RPMS/sh4
STL_FTP_UPD_HOST = $(STL_FTP)/updates/RPMS/host
STL_GET = $(WGET)/stlinux

## ordering is important here. The /host/ rule must stay before the less
## specific %.sh4/%.i386/%.noarch rule. No idea if this is portable or
## even reliable :-(
$(STL_ARCHIVE)/host/%.rpm:
	$(STL_GET)/host $(STL_FTP_UPD_HOST)/$(subst $(STL_ARCHIVE)/host/,"",$@)

$(STL_ARCHIVE)/%.src.rpm:
	$(STL_GET) $(STL_FTP_UPD_SRC)/$(subst $(STL_ARCHIVE)/,"",$@)

$(STL_ARCHIVE)/%.sh4.rpm \
$(STL_ARCHIVE)/%.i386.rpm \
$(STL_ARCHIVE)/%.noarch.rpm:
	$(STL_GET) $(STL_FTP_UPD_SH4)/$(subst $(STL_ARCHIVE)/,"",$@)

PATCH_STR = _0209

## rpm versions of packages on the STM server
# binutils 2.21.51-* segfault on linking the kernel
BINUTILS_VER	= 2.20.51.0.7-48
GCC_VER		= 4.5.3-97
STMKERNEL_VER	= 2.6.32.46-45
LIBGCC_VER	= 4.5.3-100
GLIBC_VER	= 2.10.2-34


### those patches are taken from the pingulux-git/tdt checkout
STM24_DVB_PATCH = linux-sh4-linuxdvb_stm24$(PATCH_STR).patch
COMMONPATCHES_24 = \
		$(STM24_DVB_PATCH) \
		linux-sh4-sound_stm24$(PATCH_STR).patch \
		linux-sh4-time_stm24$(PATCH_STR).patch \
		linux-sh4-init_mm_stm24$(PATCH_STR).patch \
		linux-sh4-copro_stm24$(PATCH_STR).patch \
		bpa2_procfs_stm24$(PATCH_STR).patch

SPARK_PATCHES_24 = $(COMMONPATCHES_24) \
	linux-sh4-stmmac_stm24$(PATCH_STR).patch \
	linux-sh4-lmb_stm24$(PATCH_STR).patch \
	linux-sh4-spark_setup_stm24$(PATCH_STR).patch \
	linux-sh4-linux_yaffs2_stm24_0209.patch

## temporary until I sort out the mess and find a better place...

stlinux-dfb: \
	$(STL_ARCHIVE)/stlinux24-sh4-directfb-1.4.12+STM2011.09.27-1.sh4.rpm \
	$(STL_ARCHIVE)/stlinux24-sh4-directfb-dev-1.4.12+STM2011.09.27-1.sh4.rpm
	rpm $(DRPM) --nosignature --ignorearch --force --nodeps -Uv --noscripts \
		--badreloc --relocate $(STM_RELOCATE)/devkit/sh4=$(BUILD_TMP)/dfb \
		$^
	set -e; cd $(BUILD_TMP)/dfb/target; \
		sed -i "s,/usr,$(TARGETPREFIX)/usr,g" usr/lib/*.la; \
		sed -i "s,^libdir=.*,libdir='$(TARGETPREFIX)/usr/lib'," usr/lib/*.la; \
		cp -a usr $(TARGETPREFIX);
		rm -f $(TARGETPREFIX)/include/directfb; \
		ln -s ../usr/include/directfb $(TARGETPREFIX)/include
	set -e; cd $(TARGETPREFIX)/usr/lib/pkgconfig; \
		for i in *; do \
			sed -e "s,^prefix=.*,prefix='$(TARGETPREFIX)/usr'," $$i > $(TARGETPREFIX)/lib/pkgconfig/$$i; \
			rm $$i; \
		done
