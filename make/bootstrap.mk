# makefile to build crosstool

BOOTSTRAP  = targetprefix $(BUILD_TMP) $(CROSS_BASE) $(HOSTPREFIX)/bin includes-and-libs
BOOTSTRAP += $(TARGETPREFIX)/lib/libc.so.6
BOOTSTRAP += $(HOSTPREFIX)/bin/opkg.sh $(HOSTPREFIX)/bin/opkg-chksvn.sh

ifeq ($(PLATFORM), tripledragon)
BOOTSTRAP += directfb-includes-and-libs td-modules
PLAT_INCS  = $(TARGETPREFIX)/include/hardware/xp/xp_osd_user.h
else
BOOTSTRAP += $(HOSTPREFIX)/bin/opkg-controlver-from-svn.sh
BOOTSTRAP += cs-modules $(TARGETPREFIX)/sbin/ldconfig
PLAT_LIBS  = $(TARGETPREFIX)/lib/libnxp.so $(TARGETPREFIX)/lib/libcoolstream.so $(TARGETPREFIX)/lib/libcoolstream-mt.so
PLAT_INCS  = $(TARGETPREFIX)/lib/firmware $(TARGETPREFIX)/include/coolstream
endif

bootstrap: $(BOOTSTRAP)

targetprefix:
	mkdir -p $(TARGETPREFIX)
	mkdir -p $(TARGETPREFIX)/bin
	mkdir -p $(TARGETPREFIX)/include
	mkdir -p $(PKG_CONFIG_PATH)
	make skeleton

$(TARGETPREFIX):
	@echo "**********************************************************************"
	@echo "TARGETPREFIX does not exist. You probably need to run 'make bootstrap'"
	@echo "**********************************************************************"
	@echo ""
	@false

$(HOSTPREFIX):
	mkdir $@

$(HOSTPREFIX)/bin: $(HOSTPREFIX)
	mkdir $@

$(HOSTPREFIX)/bin/opk%.sh: $(HOSTPREFIX)/bin
	ln -sf $(BASE_DIR)/scripts/$(shell basename $@) $(HOSTPREFIX)/bin

$(BUILD_TMP):
	mkdir -p $(BUILD_TMP)

$(CROSS_BASE):
	mkdir -p $(CROSS_BASE)

$(TARGETPREFIX)/include/coolstream: $(SOURCE_DIR)/svn/CROSSENVIROMENT/coolstream | $(TARGETPREFIX)
	mkdir -p $@
	cp -a $(SOURCE_DIR)/svn/CROSSENVIROMENT/coolstream/* $@/

$(TARGETPREFIX)/lib/libnxp.so: $(SVN_TP_LIBS)/libnxp/libnxp.so | $(TARGETPREFIX)
	cp -a $(SVN_TP_LIBS)/libnxp/libnxp.so $@

$(TARGETPREFIX)/lib/libcoolstream%.so: $(SVN_TP_LIBS)/libcs/libcoolstream%.so | $(TARGETPREFIX)
	cp -a $(SVN_TP_LIBS)/libcs/$(shell basename $@) $@

$(TARGETPREFIX)/lib/firmware: | $(TARGETPREFIX)
	mkdir -p $@
	cp -a $(SOURCE_DIR)/svn/THIRDPARTY/lib/firmware/* $@/

$(TARGETPREFIX)/lib/modules/2.6.26.8-nevis: | $(TARGETPREFIX)
	mkdir -p $@
	cp -a $(SOURCE_DIR)/svn/COOLSTREAM/2.6.26.8-nevis/* $@/

$(PKGPREFIX)/lib/modules/2.6.12 \
$(TARGETPREFIX)/lib/modules/2.6.12: | $(TARGETPREFIX)
	mkdir $(subst /2.6.12,,$@) # fail if no bootstrap has been done
	cp -a "$(TD_SVN)/ARMAS/filesystem-skeleton/lib/modules/2.6.12" $(subst 2.6.12,,$@)
	find $@ -name .svn -type d -print0 | xargs --no-run-if-empty -0 rm -rf

$(TARGETPREFIX)/lib/libc.so.6: $(TARGETPREFIX)
	if test -e $(CROSS_DIR)/$(TARGET)/sys-root/lib; then \
		cp -a $(CROSS_DIR)/$(TARGET)/sys-root/lib/*so* $(TARGETPREFIX)/lib; \
	else \
		cp -a $(CROSS_DIR)/$(TARGET)/lib/*so* $(TARGETPREFIX)/lib; \
	fi

crosstool: $(CROSS_DIR)/bin/$(TARGET)-gcc
includes-and-libs: $(PLAT_LIBS) $(PLAT_INCS)

ifneq ($(PLATFORM), tripledragon)
cs-modules: $(TARGETPREFIX)/lib/modules/2.6.26.8-nevis

$(CROSS_DIR)/bin/$(TARGET)-gcc:
	@echo
	@echo "====================================================="
	@echo "old crosstool is hard to maintain and likely to break"
	@echo " consider using 'make crosstool-new' which also gets"
	@echo "  you a shiny new(er) gcc 4.5.2 and eglibc 2.12 ;-)"
	@echo "====================================================="
	@echo
	@echo "sleeping for 10 seconds before continuing..."
	@echo
	@sleep 10
	$(MAKE) crosstool-old

crosstool-old: | $(SOURCE_DIR)/svn/CROSSENVIROMENT/crosstool-ng-1.3.2 $(SOURCE_DIR)/svn/CROSSENVIROMENT/crosstool-ng-configs $(ARCHIVE)/linux-2.6.26.8.tar.bz2 $(ARCHIVE)/binutils-2.19.50.0.1.tar.bz2
	make $(BUILD_TMP)
	tar --exclude='*/.svn' -cC $(SOURCE_DIR)/svn/CROSSENVIROMENT/ crosstool-ng-1.3.2 | tar -xC $(BUILD_TMP)
	set -e; unset CONFIG_SITE; cd $(BUILD_TMP)/crosstool-ng-1.3.2; \
		test "$(GIT_PROTOCOL)" = http && \
			sed -i 's#svn://svn.eglibc.org#http://www.eglibc.org/svn#' \
				scripts/build/libc/eglibc.sh || \
			true; \
		$(PATCH)/crosstool-132-bash4.diff; \
		mkdir -p patches/linux/2.6.26.8; \
		cp $(PATCHES)/linux-2.6.26.8-rename-getline.patch patches/linux/2.6.26.8; \
		cp $(PATCHES)/linux-2.6.26.8-new-make.patch       patches/linux/2.6.26.8; \
		cp $(PATCHES)/eglibc-2_8-new-make.patch           patches/eglibc/2_8/; \
		cp -a $(PATCHES)/crosstool-ng-1.3.2-newconfig .config; \
		sed -i -e 's#^CT_LOCAL_TARBALLS_DIR=.*#CT_LOCAL_TARBALLS_DIR="$(BASE_DIR)/download"#' \
		       -e 's#^CT_PREFIX_DIR=.*#CT_PREFIX_DIR="$(CROSS_BASE)"#' .config; \
		./configure --local; make; chmod 0755 ct-ng; \
		./ct-ng oldconfig; ./ct-ng build.2

crosstool-new: $(ARCHIVE)/crosstool-ng-1.10.0.tar.bz2 $(ARCHIVE)/linux-2.6.26.8.tar.bz2
	make $(BUILD_TMP)
	$(UNTAR)/crosstool-ng-1.10.0.tar.bz2
	set -e; unset CONFIG_SITE; cd $(BUILD_TMP)/crosstool-ng-1.10.0 \
		test "$(GIT_PROTOCOL)" = http && \
			sed -i 's#svn://svn.eglibc.org#http://www.eglibc.org/svn#' \
				scripts/build/libc/eglibc.sh || \
			true; \
		mkdir -p targets/src/; \
		tar -C targets/src/ -xf $(ARCHIVE)/linux-2.6.26.8.tar.bz2; \
		(cd targets/src/linux-2.6.26.8 && \
			patch -p1 -i $(PATCHES)/linux-2.6.26.8-new-make.patch && \
			patch -p1 -i $(PATCHES)/linux-2.6.26.8-rename-getline.patch); \
		ln -sf linux-2.6.26.8 targets/src/linux-custom; \
		touch targets/src/.linux-custom.extracted; \
		cp -a $(PATCHES)/crosstool-ng-coolstreamnew.config .config; \
		NUM_CPUS=$$(expr `grep -c ^processor /proc/cpuinfo` \* 2); \
		sed -i "s@^CT_PARALLEL_JOBS=.*@CT_PARALLEL_JOBS=$$NUM_CPUS@" .config; \
		export TD_BASE_DIR=$(BASE_DIR); \
		export TD_BUILD_TMP=$(BUILD_TMP); \
		./configure --local; make; chmod 0755 ct-ng; \
		./ct-ng oldconfig; \
		./ct-ng build
	ln -sf sys-root/lib $(CROSS_BASE)/$(TARGET)/
	$(REMOVE)/crosstool-ng-1.10.0

else
# TRIPLEDRAGON
td-modules: $(TARGETPREFIX)/lib/modules/2.6.12

ifneq ($(TD_COMPILER), new)
$(CROSS_DIR)/bin/$(TARGET)-gcc: $(ARCHIVE)/crosstool-0.43.tar.gz | $(BUILD_TMP)
	@echo ' ============================================================================== '
	@echo "                       Preparing to Build crosstool"
	@echo ' ============================================================================== '
	@echo ' '
	@if test "$(shell basename $(shell readlink /bin/sh))" != bash; then \
		echo "crosstool needs bash as /bin/sh!. Please fix."; false; fi
	tar -C $(BUILD_TMP) -xzf $(ARCHIVE)/crosstool-0.43.tar.gz
	cp $(PATCHES)/glibc-2.3.6-allow-binutils-2.20+.patch $(BUILD_TMP)/crosstool-0.43/patches/glibc-2.3.6
	cp $(PATCHES)/glibc-2.3.6-new_make.patch             $(BUILD_TMP)/crosstool-0.43/patches/glibc-2.3.6
	set -e; unset CONFIG_SITE; cd $(BUILD_TMP)/crosstool-0.43; \
		$(PATCH)/crosstool-0.43-fix-build-with-FORTIFY_SOURCE-default.diff; \
		export TARBALLS_DIR=$(ARCHIVE); \
		export RESULT_TOP=$(CROSS_BASE); \
		export GCC_LANGUAGES="c,c++"; \
		export PARALLELMFLAGS="-s -j 3"; \
		export QUIET_EXTRACTIONS=y; \
		eval `cat powerpc-405.dat $(CROSS_BUILD_VER).dat` LINUX_DIR=linux-2.6.12 bash all.sh --notest; \
		echo done
	# crosstool should do that, but it doesnt
	if [ ! -e $(CROSS_DIR)/$(TARGET)/include/mtd ]; then \
		cp -a $(BUILD_TMP)/crosstool-0.43/build/$(TARGET)/$(CROSS_BUILD_DIR)/linux-2.6.12/include/mtd $(CROSS_DIR)/$(TARGET)/include/;\
	fi

else
#
# $(TD_COMPILER) == new
$(CROSS_DIR)/bin/$(TARGET)-gcc: $(ARCHIVE)/crosstool-ng-1.10.0.tar.bz2 $(ARCHIVE)/linux-libc-headers-2.6.12.0.tar.bz2
	make $(BUILD_TMP)
	$(UNTAR)/crosstool-ng-1.10.0.tar.bz2
	$(UNTAR)/linux-libc-headers-2.6.12.0.tar.bz2
	ln -sf asm-ppc $(BUILD_TMP)//linux-libc-headers-2.6.12.0/include/asm
	set -e; unset CONFIG_SITE; cd $(BUILD_TMP)/crosstool-ng-1.10.0; \
		test "$(GIT_PROTOCOL)" = http && \
			sed -i 's#svn://svn.eglibc.org#http://www.eglibc.org/svn#' \
				scripts/build/libc/eglibc.sh || \
			true; \
		cp -a $(PATCHES)/crosstool-ng-tripledragon.config .config; \
		NUM_CPUS=$$(expr `grep -c ^processor /proc/cpuinfo` \* 2); \
		sed -i "s@^CT_PARALLEL_JOBS=.*@CT_PARALLEL_JOBS=$$NUM_CPUS@" .config; \
		export TD_BASE_DIR=$(BASE_DIR); \
		export TD_BUILD_TMP=$(BUILD_TMP); \
		./configure --local; make; chmod 0755 ct-ng; \
		./ct-ng oldconfig; \
		./ct-ng build
	$(REMOVE)/crosstool-ng-1.10.0

endif

$(TARGETPREFIX)/include/hardware/xp/xp_osd_user.h: $(TARGETPREFIX)
	@echo ' ============================================================================== '
	@echo "    Preparing to copy crosstool and supporting files to required directories"
	@echo ' ============================================================================== '
	tar --exclude='*/.svn' -cC $(TD_SVN)/ARMAS/cross-enivroment-build/stb/include/ hardware | \
		tar -vxC $(TARGETPREFIX)/include/
	cp -a $(PATCHES)/xp_osd_user.h			$(TARGETPREFIX)/include/hardware/xp/

$(PKGPREFIX)/stb/lib/directfb-0.9.24 \
$(TARGETPREFIX)/stb/lib/directfb-0.9.24: $(TARGETPREFIX)
	tar --exclude='*/.svn' -cC $(TD_SVN)/ARMAS/filesystem-skeleton stb/lib/directfb-0.9.24 | \
		tar -vxC $(subst /stb/lib/directfb-0.9.24,,$@)
	ln -sf ../../lib/libjpeg.so.62 $(subst /directfb-0.9.24,,$@)/libjpeg.so.62

$(TARGETPREFIX)/include/directfb: $(TARGETPREFIX)
	tar --exclude='*/.svn' -cC $(TD_SVN)/ARMAS/cross-enivroment-build/stb include/directfb | \
		tar -vxC $(TARGETPREFIX)/

directfb-includes-and-libs: preqs-directfb-td $(TARGETPREFIX)/stb/lib/directfb-0.9.24 $(TARGETPREFIX)/include/directfb
	cp -a $(TD_SVN)/ARMAS/cross-enivroment-build/stb/lib/pkgconfig/directfb.pc $(PKG_CONFIG_PATH)/
	cp -a $(TD_SVN)/ARMAS/cross-enivroment-build/stb/lib/pkgconfig/direct.pc   $(PKG_CONFIG_PATH)/
	cp -a $(TD_SVN)/ARMAS/cross-enivroment-build/stb/lib/pkgconfig/fusion.pc   $(PKG_CONFIG_PATH)/
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/directfb.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/direct.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/fusion.pc
	cp -av $(TD_SVN)/ARMAS/filesystem-skeleton/stb/lib/libdirect* $(TARGETPREFIX)/lib/
	cp -av $(TD_SVN)/ARMAS/filesystem-skeleton/stb/lib/libfusion* $(TARGETPREFIX)/lib/
	ln -sf libdirect-0.9.so.24   $(TARGETPREFIX)/lib/libdirect.so
	ln -sf libfusion-0.9.so.24   $(TARGETPREFIX)/lib/libfusion.so
	ln -sf libdirectfb-0.9.so.24 $(TARGETPREFIX)/lib/libdirectfb.so
	mkdir -p $(TARGETPREFIX)/etc
	cp -a $(SCRIPTS)/directfbrc-td $(TARGETPREFIX)/etc/directfbrc


# PLATFORM = tripledagon
endif

# helper target to create ccache links (make sure to have ccache installed in /usr/bin ;)
ccache: $(HOSTPREFIX)/bin
	ln -s /usr/bin/ccache $(HOSTPREFIX)/bin/cc
	ln -s /usr/bin/ccache $(HOSTPREFIX)/bin/gcc
	ln -s /usr/bin/ccache $(HOSTPREFIX)/bin/g++
	ln -s /usr/bin/ccache $(HOSTPREFIX)/bin/$(TARGET)-gcc
	ln -s /usr/bin/ccache $(HOSTPREFIX)/bin/$(TARGET)-g++

ldconfig: $(TARGETPREFIX)/sbin/ldconfig
$(TARGETPREFIX)/sbin/ldconfig: | $(TARGETPREFIX)
	@if test -e $(CROSS_DIR)/$(TARGET)/sys-root/sbin/ldconfig; then \
		cp -a $(CROSS_DIR)/$(TARGET)/sys-root/sbin/ldconfig $@; \
		mkdir -p $(TARGETPREFIX)/etc; \
		touch $(TARGETPREFIX)/etc/ld.so.conf; \
	elif test -e $(CROSS_DIR)/$(TARGET)/sbin/ldconfig; then \
		cp -a $(CROSS_DIR)/$(TARGET)/sbin/ldconfig $@; \
		mkdir -p $(TARGETPREFIX)/etc; \
		touch $(TARGETPREFIX)/etc/ld.so.conf; \
	else \
		# triggers on crosstool-0.43 built Tripledragon toolchain ; \
		echo "====================================================="; \
		echo "Your toolchain did not build ldconfig for the target."; \
		echo "This is not an error, just a hint."; \
		echo "====================================================="; \
	fi

pkg-config: $(HOSTPREFIX)/bin/pkg-config
$(HOSTPREFIX)/bin/pkg-config: $(ARCHIVE)/pkg-config-0.25.tar.gz | $(HOSTPREFIX)/bin
	$(UNTAR)/pkg-config-0.25.tar.gz
	cd $(BUILD_TMP)/pkg-config-0.25 && \
		./configure --with-pc_path=$(PKG_CONFIG_PATH) --with-installed-glib && \
		$(MAKE) && \
		cp -a pkg-config $(HOSTPREFIX)/bin
	ln -s pkg-config $(HOSTPREFIX)/bin/$(TARGET)-pkg-config

# hack to make sure they are always copied
PHONY += $(TARGETPREFIX)/lib/modules/2.6.26.8-nevis
PHONY += $(TARGETPREFIX)/include/coolstream
PHONY += $(TARGETPREFIX)/lib/libnxp.so
PHONY += $(TARGETPREFIX)/lib/libcoolstream.so
PHONY += $(TARGETPREFIX)/lib/firmware
PHONY += ccache crosstool includes-and-libs cs-modules targetprefix bootstrap
