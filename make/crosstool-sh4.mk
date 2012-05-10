# makefile to build crosstool

## stlinux crosstool is pretty lame since we only install the RPMs, but why bother
## building everything for yourself if they provide a working, tested, supported
## toolchain etc?

# the mount point for the ISOs
$(STLINUX_SRC_MNT) $(STLINUX_SH4_MNT):
	mkdir -p $@

# mount the ISOs. later, we'll just download what's needed on demand, but for
# now this is less work.
stlinux-isomount: | $(STLINUX_SRC_MNT) $(STLINUX_SH4_MNT)
	test -e $(STLINUX_SRC_MNT)/stlinux24-host-filesystem-1.0-7.src.rpm || \
		sudo mount -oloop,ro $(STLINUX_SRC_ISO) $(STLINUX_SRC_MNT)
	test -e $(STLINUX_SH4_MNT)/README || \
		sudo mount -oloop,ro $(STLINUX_SH4_ISO) $(STLINUX_SH4_MNT)

crosstool-rpminstall: \
$(STL_ARCHIVE)/stlinux24-cross-sh4-binutils-$(BINUTILS_VER).i386.rpm \
$(STL_ARCHIVE)/stlinux24-cross-sh4-binutils-dev-$(BINUTILS_VER).i386.rpm \
$(STL_ARCHIVE)/stlinux24-cross-sh4-cpp-$(GCC_VER).i386.rpm \
$(STL_ARCHIVE)/stlinux24-cross-sh4-gcc-$(GCC_VER).i386.rpm \
$(STL_ARCHIVE)/stlinux24-cross-sh4-g++-$(GCC_VER).i386.rpm \
$(STL_ARCHIVE)/stlinux24-sh4-linux-kernel-headers-$(STMKERNEL_VER).noarch.rpm \
$(STL_ARCHIVE)/stlinux24-sh4-libgcc-$(LIBGCC_VER).sh4.rpm \
$(STL_ARCHIVE)/stlinux24-sh4-glibc-$(GLIBC_VER).sh4.rpm \
$(STL_ARCHIVE)/stlinux24-sh4-glibc-dev-$(GLIBC_VER).sh4.rpm \
$(STL_ARCHIVE)/stlinux24-sh4-libstdc++-$(LIBGCC_VER).sh4.rpm \
$(STL_ARCHIVE)/stlinux24-sh4-libstdc++-dev-$(LIBGCC_VER).sh4.rpm
	make $(BUILD_TMP)
	unpack-rpm.sh $(BUILD_TMP) $(STM_RELOCATE)/devkit/sh4 $(CROSS_BASE) \
		$^


# install the RPMs into CROSS_BASE
crosstool: $(STL_ARCHIVE)/host/stlinux24-host-u-boot-tools-1.3.1_stm24-9.i386.rpm \
$(HOSTPREFIX)/bin/unpack-rpm.sh \
crosstool-rpminstall
	# this puts mkimage etc. into cross/host/bin... not too nice...
	unpack-rpm.sh $(BUILD_TMP) $(STM_RELOCATE) $(CROSS_BASE) \
		$(firstword $^)
	set -e; cd $(CROSS_BASE); rm -f sh4-linux/sys-root; ln -s ../target sh4-linux/sys-root

