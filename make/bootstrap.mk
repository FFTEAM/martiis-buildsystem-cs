# makefile to build crosstool



bootstrap: targetprefix $(BUILD_TMP) $(CROSS_BASE) $(HOSTPREFIX)/bin includes-and-libs cs-modules $(TARGETPREFIX)/lib/libc.so.6

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

$(BUILD_TMP):
	mkdir -p $(BUILD_TMP)

$(CROSS_BASE):
	mkdir -p $(CROSS_BASE)

$(TARGETPREFIX)/include/coolstream: $(SOURCE_DIR)/svn/CROSSENVIROMENT/coolstream | $(TARGETPREFIX)
	mkdir -p $@
	cp -a $(SOURCE_DIR)/svn/CROSSENVIROMENT/coolstream/* $@/

$(TARGETPREFIX)/lib/libnxp.so: $(SOURCE_DIR)/svn/THIRDPARTY/libraries/libnxp/libnxp.so | $(TARGETPREFIX)
	cp -a $(SOURCE_DIR)/svn/THIRDPARTY/libraries/libnxp/libnxp.so $@

$(TARGETPREFIX)/lib/libcoolstream.so: $(SOURCE_DIR)/svn/THIRDPARTY/libraries/libcs/libcoolstream.so | $(TARGETPREFIX)
	cp -a $(SOURCE_DIR)/svn/THIRDPARTY/libraries/libcs/libcoolstream.so $@

$(TARGETPREFIX)/lib/modules/2.6.26.8-nevis: | $(TARGETPREFIX)
	mkdir -p $@
	cp -a $(SOURCE_DIR)/svn/COOLSTREAM/2.6.26.8-nevis/* $@/

$(TARGETPREFIX)/lib/libc.so.6: $(TARGETPREFIX)
	cp -a $(CROSS_DIR)/$(TARGET)/lib/*so* $(TARGETPREFIX)/lib

cs-modules: $(TARGETPREFIX)/lib/modules/2.6.26.8-nevis
includes-and-libs:  $(TARGETPREFIX)/lib/libnxp.so $(TARGETPREFIX)/lib/libcoolstream.so $(TARGETPREFIX)/include/coolstream

crosstool: $(SOURCE_DIR)/svn/CROSSENVIROMENT/crosstool-ng-1.3.2 $(SOURCE_DIR)/svn/CROSSENVIROMENT/crosstool-ng-configs
	make $(BUILD_TMP)
	cp -a $(SOURCE_DIR)/svn/CROSSENVIROMENT/crosstool-ng-1.3.2 $(BUILD_TMP)/
	cd $(BUILD_TMP)/crosstool-ng-1.3.2 && \
		$(PATCH)/crosstool-132-bash4.diff && \
		mkdir -p patches/linux/2.6.26.8 && \
		cp $(PATCHES)/linux-2.6.26.8-rename-getline.patch patches/linux/2.6.26.8 && \
		cp -a $(PATCHES)/crosstool-ng-1.3.2-newconfig .config && \
		sed -i -e 's#^CT_LOCAL_TARBALLS_DIR=.*#CT_LOCAL_TARBALLS_DIR="$(BASE_DIR)/download"#' \
		       -e 's#^CT_PREFIX_DIR=.*#CT_PREFIX_DIR="$(CROSS_BASE)"#' .config && \
		./configure --local &&  make && chmod 0755 ct-ng && \
		./ct-ng oldconfig && ./ct-ng build.2

# helper target to create ccache links (make sure to have ccache installed in /usr/bin ;)
ccache:
	ln -s /usr/bin/ccache $(HOSTPREFIX)/bin/cc
	ln -s /usr/bin/ccache $(HOSTPREFIX)/bin/gcc
	ln -s /usr/bin/ccache $(HOSTPREFIX)/bin/g++
	ln -s /usr/bin/ccache $(HOSTPREFIX)/bin/$(TARGET)-gcc
	ln -s /usr/bin/ccache $(HOSTPREFIX)/bin/$(TARGET)-g++

# hack to make sure they are always copied
PHONY += $(TARGETPREFIX)/lib/modules/2.6.26.8-nevis
PHONY += ccache crosstool includes-and-libs cs-modules targetprefix bootstrap
