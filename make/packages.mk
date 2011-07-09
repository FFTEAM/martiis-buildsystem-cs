# SYSTEM_PKGS is "install enough to get a TV picture"
SYSTEM_PKGS = neutrino-pkg minimal-system-pkgs

glibc-pkg: $(TARGETPREFIX)/sbin/ldconfig
	rm -rf $(PKGPREFIX)
	mkdir -p $(PKGPREFIX)
	cd $(PKGPREFIX) && \
		mkdir lib sbin etc && \
		if test -e $(CROSS_DIR)/$(TARGET)/sys-root/lib; then \
			cp -a $(CROSS_DIR)/$(TARGET)/sys-root/lib/*.so* lib/; \
		else \
			cp -a $(CROSS_DIR)/$(TARGET)/lib/*.so* lib/; \
		fi && \
		(cp -a $(TARGETPREFIX)/sbin/ldconfig sbin/||true) &&  \
		rm -fv lib/libnss_hesiod* lib/libnss_nis* lib/libnss_compat* \
		   lib/libmudflap* lib/libc.so lib/libpthread.so \
		   lib/libcidn* lib/*.so_orig lib/*.py && \
		find lib -name '*.so' -type l -print0 | xargs -0 --no-run-if-empty rm -v
	touch $(PKGPREFIX)/etc/ld.so.conf
	$(REMOVE)/glibc-control
	cp -a $(CONTROL_DIR)/glibc $(BUILD_TMP)/glibc-control
	# two packages are built, so we are not using the PKG_VER feature of opkg.sh
	VER=`cd $(PKGPREFIX)/lib; echo ld-*.so` && VER=$${VER#ld-} && VER=$${VER%.so} && \
		sed -i "s/@VER@/$$VER/" $(BUILD_TMP)/glibc-control/control
	# lame attempt at "auto-provides" for glibc...
	PROV=`cd $(PKGPREFIX)/lib; echo *.so.[0-9]` && PROV=$${PROV// /, } && \
		sed -i "s/@PROV@/$$PROV/" $(BUILD_TMP)/glibc-control/control
	$(OPKG_SH) $(BUILD_TMP)/glibc-control
	sed -i	-e 's/^Package: glibc$$/Package: glibc-debug/' \
		-e 's/^Description:.*/Description: The GNU C library (unstripped)/' \
		 $(BUILD_TMP)/glibc-control/control
	DONT_STRIP=1 $(OPKG_SH) $(BUILD_TMP)/glibc-control
	rm -rf $(PKGPREFIX) $(BUILD_TMP)/glibc-control

ifneq ($(PLATFORM), tripledragon)
cs-drivers-pkg:
	# we have two directories packed, the newer one determines the package version
	rm -rf $(BUILD_TMP)/tmp-ctrl
	cp -a $(CONTROL_DIR)/cs-drivers $(BUILD_TMP)/tmp-ctrl
	opkg-controlver-from-svn.sh $(BUILD_TMP)/tmp-ctrl/control \
		$(SOURCE_DIR)/svn/COOLSTREAM/2.6.26.8-nevis $(SOURCE_DIR)/svn/THIRDPARTY/lib/firmware
	opkg-chksvn.sh $(BUILD_TMP)/tmp-ctrl $(SOURCE_DIR)/svn/COOLSTREAM/2.6.26.8-nevis || \
	opkg-chksvn.sh $(BUILD_TMP)/tmp-ctrl $(SOURCE_DIR)/svn/THIRDPARTY/lib/firmware
	rm -rf $(PKGPREFIX)
	mkdir -p $(PKGPREFIX)/lib/modules/2.6.26.8-nevis
	mkdir    $(PKGPREFIX)/lib/firmware
	cp -a $(SOURCE_DIR)/svn/COOLSTREAM/2.6.26.8-nevis/* $(PKGPREFIX)/lib/modules/2.6.26.8-nevis
	cp -a $(SOURCE_DIR)/svn/THIRDPARTY/lib/firmware/*   $(PKGPREFIX)/lib/firmware
	mkdir -p $(PKGPREFIX)/etc/init.d
	cp -a skel-root/$(PLATFORM)/etc/init.d/*loadmodules $(PKGPREFIX)/etc/init.d
	DONT_STRIP=1 $(OPKG_SH) $(BUILD_TMP)/tmp-ctrl
	rm -rf $(PKGPREFIX) $(BUILD_TMP)/tmp-ctrl

cs-libs-pkg: $(SVN_TP_LIBS)/libnxp/libnxp.so $(SVN_TP_LIBS)/libcs/libcoolstream.so
	rm -rf $(BUILD_TMP)/tmp-ctrl
	cp -a $(CONTROL_DIR)/cs-libs $(BUILD_TMP)/tmp-ctrl
	opkg-controlver-from-svn.sh $(BUILD_TMP)/tmp-ctrl/control \
		$(SVN_TP_LIBS)/libnxp/libnxp.so $(SVN_TP_LIBS)/libcs/libcoolstream.so
	opkg-chksvn.sh $(BUILD_TMP)/tmp-ctrl $(SVN_TP_LIBS)/libnxp/libnxp.so || \
	opkg-chksvn.sh $(BUILD_TMP)/tmp-ctrl $(SVN_TP_LIBS)/libcs/libcoolstream.so
	rm -rf $(PKGPREFIX)
	mkdir -p $(PKGPREFIX)/lib
	cp -a $(SVN_TP_LIBS)/libnxp/libnxp.so $(SVN_TP_LIBS)/libcs/libcoolstream.so $(PKGPREFIX)/lib
	$(OPKG_SH) $(BUILD_TMP)/tmp-ctrl
	rm -rf $(PKGPREFIX) $(BUILD_TMP)/tmp-ctrl

PHONY += cs-drivers-pkg cs-libs-pkg
SYSTEM_PKGS += cs-libs-pkg cs-drivers-pkg
else
td-module-pkg:
	rm -rf $(PKGPREFIX)
	mkdir -p $(PKGPREFIX)/lib
	make $(PKGPREFIX)/lib/modules/2.6.12
	mkdir -p $(PKGPREFIX)/etc/init.d
	cp -a skel-root/$(PLATFORM)/etc/init.d/*loadmodules $(PKGPREFIX)/etc/init.d
	DONT_STRIP=1 $(OPKG_SH) $(CONTROL_DIR)/td-drivers
	rm -rf $(PKGPREFIX)

td-directfb-pkg:
	rm -rf $(PKGPREFIX)
	mkdir -p $(PKGPREFIX)/etc $(PKGPREFIX)/lib
	make $(PKGPREFIX)/stb/lib/directfb-0.9.24
	cp -av $(TD_SVN)/ARMAS/filesystem-skeleton/stb/lib/libdirect* $(PKGPREFIX)/lib/
	cp -av $(TD_SVN)/ARMAS/filesystem-skeleton/stb/lib/libfusion* $(PKGPREFIX)/lib/
	cp -a $(SCRIPTS)/directfbrc-td $(PKGPREFIX)/etc/directfbrc
	DONT_STRIP=1 $(OPKG_SH) $(CONTROL_DIR)/td-directfb
	rm -rf $(PKGPREFIX)

PHONY += td-module-pkg td-directfb-pkg
SYSTEM_PKGS += td-module-pkg td-directfb-pkg
endif

aaa_base-pkg:
	rm -rf $(PKGPREFIX)
	mkdir -p $(PKGPREFIX)
	cp -a skel-root/common/* $(PKGPREFIX)/
	cp -a skel-root/$(PLATFORM)/* $(PKGPREFIX)/
	find $(PKGPREFIX) -name .gitignore | xargs rm
	cd $(PKGPREFIX) && rm etc/init.d/*loadmodules && rm etc/init.d/start_neutrino # ugly...
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
	rm -f $(BUILD_TMP)/min-root-$(PLATFORM).tar.gz
	tar -czf $(BUILD_TMP)/min-root-$(PLATFORM).tar.gz \
		--owner=0 --group=0 -C $(BUILD_TMP)/install .
	@echo
	@echo "====================================================================="
	@echo "A minimal system has been installed in $(subst $(BASE_DIR)/,,$(BUILD_TMP))/install."
	@echo "A tarball of this installation was created as"
	@echo "$(subst $(BASE_DIR)/,,$(BUILD_TMP))/min-root-$(PLATFORM).tar.gz"
	@echo "Unpack this onto an empty root fs, which will enable you to install"
	@echo "further packages via 'opkg-cl' after configuring in /etc/opkg/."
	@echo "List of installed packages:"
	@opkg-cl -f $(BUILD_TMP)/opkg.conf -o $(BUILD_TMP)/install list-installed | \
		while read a b c; do printf "\t%-15s %s\n" $$a $$c; done
	@echo
	@echo "Have a lot of fun..."
	@echo

# system-pkgs installs actually enough to get a TV picture
system-pkgs: $(SYSTEM_PKGS)
	make pkg-index
	opkg-cl -f $(BUILD_TMP)/opkg.conf -o $(BUILD_TMP)/install install \
		neutrino-hd

dist-pkgs: pkg-index
ifeq ($(PKG_DEST_DIR),)
	@printf "\ndist-pkgs needs the variable PKG_DEST_DIR set in config.\n\n"
	@false
else
	rsync -avP --exclude=.cache --exclude=.old --exclude=.gitignore --delete \
		$(PACKAGE_DIR)/. $(PKG_DEST_DIR)/.
endif

PHONY += dist-pkgs
PHONY += glibc-pkg aaa_base-pkg pkg-index install-pkgs
PHONY += prepare-pkginstall minimal-system-pkgs system-pkgs
