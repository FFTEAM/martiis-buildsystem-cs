# makefile to build crosstool

bootstrap:	$(BUILD_TMP) $(CROSS_BASE) $(TARGETPREFIX) $(HOSTPREFIX)/bin includes-and-libs

$(TARGETPREFIX):
	mkdir -p $(TARGETPREFIX)
	mkdir -p $(TARGETPREFIX)/include
	mkdir -p $(TARGETPREFIX)/lib

$(HOSTPREFIX):
	mkdir $@

$(HOSTPREFIX)/bin: $(HOSTPREFIX)
	mkdir $@

$(BUILD_TMP):
	mkdir -p $(BUILD_TMP)

$(CROSS_BASE):
	mkdir -p $(CROSS_BASE)

$(TARGETPREFIX)/include/coolstream:
	mkdir -p $@
	cp -a $(SOURCE_DIR)/svn/CROSSENVIROMENT/coolstream/* $@/

$(TARGETPREFIX)/lib/libnxp.so:
	cp -a $(SOURCE_DIR)/svn/THIRDPARTY/libraries/libnxp/libnxp.so $@

$(TARGETPREFIX)/lib/libcoolstream.so:
	cp -a $(SOURCE_DIR)/svn/THIRDPARTY/libraries/libcs/libcoolstream.so $@

includes-and-libs:  $(TARGETPREFIX)/lib/libnxp.so $(TARGETPREFIX)/lib/libcoolstream.so $(TARGETPREFIX)/include/coolstream

crosstool: $(SOURCE_DIR)/svn/CROSSENVIROMENT/crosstool-ng-1.3.2 $(SOURCE_DIR)/svn/CROSSENVIROMENT/crosstool-ng-configs
	cp -a $(SOURCE_DIR)/svn/CROSSENVIROMENT/crosstool-ng-1.3.2 $(BUILD_TMP)
	cd $(BUILD_TMP)/crosstool-ng-1.3.2 && \
		cp $(SOURCE_DIR)/svn/CROSSENVIROMENT/crosstool-ng-configs/config-cx2450x-1.3.2 .config && \
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
