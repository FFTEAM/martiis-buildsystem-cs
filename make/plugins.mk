# plugins...
# experimental, don't use yet until you know what you are doing
$(PLUGIN_DIR)/configure.ac: | $(PLUGIN_DIR)
$(PLUGIN_DIR)/configure: $(PLUGIN_DIR)/configure.ac
	cd $(PLUGIN_DIR) && ./autogen.sh

$(BUILD_TMP)/neutrino-hd-plugins:
	mkdir $@

PLUGINS_TO_BUILD = tuxcom tuxwetter

plugins: $(PLUGIN_DIR)/configure $(BUILD_TMP)/neutrino-hd-plugins
	set -e; cd $(BUILD_TMP)/neutrino-hd-plugins; \
		export PKG_CONFIG=$(PKG_CONFIG); \
		export PKG_CONFIG_PATH=$(PKG_CONFIG_PATH); \
		CC=$(TARGET)-gcc CFLAGS="$(N_CFLAGS)" CXXFLAGS="$(N_CFLAGS)" LDFLAGS="$(N_LDFLAGS)" \
		$(PLUGIN_DIR)/configure --host=$(TARGET) --build=$(BUILD) --prefix= \
			--enable-maintainer-mode --with-boxtype=$(PLATFORM) --with-target=cdk; \
		$(MAKE)
	set -e; for i in $(PLUGINS_TO_BUILD); do \
		rm -rf $(PKGPREFIX); \
		mkdir -p $(PKGPREFIX); \
		make -j1 -C $(BUILD_TMP)/neutrino-hd-plugins/$$i install DESTDIR=$(PKGPREFIX); \
		cp -a $(PKGPREFIX)/* $(TARGETPREFIX)/; \
		$(OPKG_SH) $(CONTROL_DIR)/plugins/$$i; \
		rm -rf $(PKGPREFIX); \
	done

PHONY += plugins
