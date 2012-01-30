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
