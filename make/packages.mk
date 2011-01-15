glibc-pkg: $(TARGETPREFIX)/sbin/ldconfig
	rm -rf $(PKGPREFIX)
	mkdir -p $(PKGPREFIX)
	cd $(PKGPREFIX) && \
		mkdir lib sbin etc && \
		cp -a $(CROSS_DIR)/$(TARGET)/lib/*so* lib/ && \
		cp -a $(TARGETPREFIX)/sbin/ldconfig sbin/ &&  \
		rm lib/libnss_hesiod* lib/libnss_nis* lib/libnss_compat* \
		   lib/libmudflap* lib/libnsl*
	find $(PKGPREFIX) -type f -print0 | xargs -0 $(TARGET)-strip
	touch $(PKGPREFIX)/etc/ld.so.conf
	opkg.sh $(CONTROL_DIR)/glibc $(TARGET) "$(MAINTAINER)" $(PKGPREFIX) $(BUILD_TMP)
	mv $(PKGPREFIX)/glibc-*.opk $(PACKAGE_DIR)
	rm -rf $(PKGPREFIX)

cs-drivers-pkg:
	# we have two directories packed, the newer one determines the package version
	opkg-chksvn.sh $(CONTROL_DIR)/cs-drivers $(SOURCE_DIR)/svn/COOLSTREAM/2.6.26.8-nevis || \
	opkg-chksvn.sh $(CONTROL_DIR)/cs-drivers $(SOURCE_DIR)/svn/THIRDPARTY/lib/firmware
	rm -rf $(PKGPREFIX)
	mkdir -p $(PKGPREFIX)/lib/modules/2.6.26.8-nevis
	mkdir    $(PKGPREFIX)/lib/firmware
	cp -a $(SOURCE_DIR)/svn/COOLSTREAM/2.6.26.8-nevis/* $(PKGPREFIX)/lib/modules/2.6.26.8-nevis
	cp -a $(SOURCE_DIR)/svn/THIRDPARTY/lib/firmware/*   $(PKGPREFIX)/lib/firmware
	opkg.sh $(CONTROL_DIR)/cs-drivers $(TARGET) "$(MAINTAINER)" $(PKGPREFIX) $(BUILD_TMP)
	mv $(PKGPREFIX)/cs-drivers-*.opk $(PACKAGE_DIR)
	rm -rf $(PKGPREFIX)

cs-libs-pkg: $(SVN_TP_LIBS)/libnxp/libnxp.so $(SVN_TP_LIBS)/libcs/libcoolstream.so
	opkg-chksvn.sh $(CONTROL_DIR)/cs-libs $(SVN_TP_LIBS)/libnxp/libnxp.so || \
	opkg-chksvn.sh $(CONTROL_DIR)/cs-libs $(SVN_TP_LIBS)/libcs/libcoolstream.so
	rm -rf $(PKGPREFIX)
	mkdir -p $(PKGPREFIX)/lib
	cp -a $(SVN_TP_LIBS)/libnxp/libnxp.so $(SVN_TP_LIBS)/libcs/libcoolstream.so $(PKGPREFIX)/lib
	opkg.sh $(CONTROL_DIR)/cs-libs $(TARGET) "$(MAINTAINER)" $(PKGPREFIX) $(BUILD_TMP)
	mv $(PKGPREFIX)/cs-*.opk $(PACKAGE_DIR)
	rm -rf $(PKGPREFIX)

aaa_base-pkg:
	rm -rf $(PKGPREFIX)
	mkdir -p $(PKGPREFIX)
	cp -a skel-root/* $(PKGPREFIX)/
	find $(PKGPREFIX) -name .gitignore | xargs rm
	cd $(PKGPREFIX) && rm etc/ntpd.conf
	opkg.sh $(CONTROL_DIR)/aaa_base $(TARGET) "$(MAINTAINER)" $(PKGPREFIX) $(BUILD_TMP)
	mv $(PKGPREFIX)/*.opk $(PACKAGE_DIR)
	rm -rf $(PKGPREFIX)

install-pkgs:
	$(REMOVE)/install
	mkdir -p $(BUILD_TMP)/install/var/lib/opkg
	opkg-cl -f $(PATCHES)/opkg.conf -o $(BUILD_TMP)/install install $(PACKAGE_DIR)/*
	# postinst does not really work on cross-arch installation... TODO: make more flexible
	-test -d $(BUILD_TMP)/install/opt/pkg/lib && echo "/opt/pkg/lib" > $(BUILD_TMP)/install/etc/ld.so.conf

PHONY += glibc-pkg cs-driver-pkg cs-libs-pkg aaa_base-pkg install-pkgs
