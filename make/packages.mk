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

PHONY += glibc-pkg
