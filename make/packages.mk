glibc-pkg: $(TARGETPREFIX)/sbin/ldconfig
	rm -rf $(PKGPREFIX)
	mkdir -p $(PKGPREFIX)
	cd $(PKGPREFIX) && \
		mkdir lib sbin etc && \
		cp -a $(CROSS_DIR)/$(TARGET)/lib/*.so* lib/ && \
		(cp -a $(TARGETPREFIX)/sbin/ldconfig sbin/||true) &&  \
		rm -fv lib/libnss_hesiod* lib/libnss_nis* lib/libnss_compat* \
		   lib/libmudflap* lib/libnsl* lib/libc.so lib/libpthread.so \
		   lib/libcidn* lib/*.so_orig && \
		find lib -name '*.so' -type l -print0 | xargs -0 --no-run-if-empty rm -v
	find $(PKGPREFIX) -type f -print0 | xargs -0 $(TARGET)-strip
	touch $(PKGPREFIX)/etc/ld.so.conf
	$(REMOVE)/control
	cp -a $(CONTROL_DIR)/glibc $(BUILD_TMP)/glibc-control
	VER=`cd $(PKGPREFIX)/lib; echo ld-*.so` && VER=$${VER#ld-} && VER=$${VER%.so} && \
		sed -i "s/@VER@/$$VER/" $(BUILD_TMP)/glibc-control/control
	$(OPKG_SH) $(BUILD_TMP)/glibc-control
	rm -rf $(PKGPREFIX) $(BUILD_TMP)/glibc-control

cs-drivers-pkg:
	# we have two directories packed, the newer one determines the package version
	opkg-chksvn.sh $(CONTROL_DIR)/cs-drivers $(SOURCE_DIR)/svn/COOLSTREAM/2.6.26.8-nevis || \
	opkg-chksvn.sh $(CONTROL_DIR)/cs-drivers $(SOURCE_DIR)/svn/THIRDPARTY/lib/firmware
	rm -rf $(PKGPREFIX)
	mkdir -p $(PKGPREFIX)/lib/modules/2.6.26.8-nevis
	mkdir    $(PKGPREFIX)/lib/firmware
	cp -a $(SOURCE_DIR)/svn/COOLSTREAM/2.6.26.8-nevis/* $(PKGPREFIX)/lib/modules/2.6.26.8-nevis
	cp -a $(SOURCE_DIR)/svn/THIRDPARTY/lib/firmware/*   $(PKGPREFIX)/lib/firmware
	$(OPKG_SH) $(CONTROL_DIR)/cs-drivers
	rm -rf $(PKGPREFIX)

cs-libs-pkg: $(SVN_TP_LIBS)/libnxp/libnxp.so $(SVN_TP_LIBS)/libcs/libcoolstream.so
	opkg-chksvn.sh $(CONTROL_DIR)/cs-libs $(SVN_TP_LIBS)/libnxp/libnxp.so || \
	opkg-chksvn.sh $(CONTROL_DIR)/cs-libs $(SVN_TP_LIBS)/libcs/libcoolstream.so
	rm -rf $(PKGPREFIX)
	mkdir -p $(PKGPREFIX)/lib
	cp -a $(SVN_TP_LIBS)/libnxp/libnxp.so $(SVN_TP_LIBS)/libcs/libcoolstream.so $(PKGPREFIX)/lib
	$(OPKG_SH) $(CONTROL_DIR)/cs-libs
	rm -rf $(PKGPREFIX)

aaa_base-pkg:
	rm -rf $(PKGPREFIX)
	mkdir -p $(PKGPREFIX)
	cp -a skel-root/common/* $(PKGPREFIX)/
	cp -a skel-root/$(PLATFORM)/* $(PKGPREFIX)/
	find $(PKGPREFIX) -name .gitignore | xargs rm
	cd $(PKGPREFIX) && rm etc/init.d/*loadmodules # ugly...
	DONT_STRIP=1 $(OPKG_SH) $(CONTROL_DIR)/aaa_base
	rm -rf $(PKGPREFIX)

pkg-index: $(HOSTPREFIX)/bin/opkg-make-index.sh
	cd $(PACKAGE_DIR) && opkg-make-index.sh . > Packages

prepare-pkginstall: pkg-index
	$(REMOVE)/install $(BUILD_TMP)/opkg.conf
	mkdir -p $(BUILD_TMP)/install/var/lib/opkg
	printf "arch all 1\narch noarch 1\narch $(BOXARCH) 10\n" > $(BUILD_TMP)/opkg.conf
	printf "src local file:/$(PACKAGE_DIR)\n" >> $(BUILD_TMP)/opkg.conf
	opkg-cl -f $(BUILD_TMP)/opkg.conf -o $(BUILD_TMP)/install update

# install-pkgs installs everything the hard way, just to check dependencies...
install-pkgs: prepare-pkginstall
	opkg-cl -f $(PATCHES)/opkg.conf -o $(BUILD_TMP)/install install $(PACKAGE_DIR)/*
	# postinst does not really work on cross-arch installation... TODO: make more flexible
	test -d $(BUILD_TMP)/install/opt/pkg/lib && \
		echo "/opt/pkg/lib" > $(BUILD_TMP)/install/etc/ld.so.conf || true

# minimal-system-pkgs allows booting, not much else
minimal-system-pkgs: glibc-pkg aaa_base-pkg busybox procps opkg prepare-pkginstall
	opkg-cl -f $(BUILD_TMP)/opkg.conf -o $(BUILD_TMP)/install install \
		aaa_base busybox opkg procps

# system-pkgs installs actually enough to get a TV picture
system-pkgs: neutrino-pkg cs-libs-pkg cs-drivers-pkg minimal-system-pkgs
	opkg-cl -f $(BUILD_TMP)/opkg.conf -o $(BUILD_TMP)/install install \
		neutrino-hd

PHONY += glibc-pkg cs-drivers-pkg cs-libs-pkg aaa_base-pkg pkg-index install-pkgs
PHONY += prepare-pkginstall minimal-system-pkgs system-pkgs
