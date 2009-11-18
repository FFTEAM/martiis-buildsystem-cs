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

# helper target to create ccache links (make sure to have ccache installed in /usr/bin ;)
ccache:
	ln -s /usr/bin/ccache $(HOSTPREFIX)/bin/cc
	ln -s /usr/bin/ccache $(HOSTPREFIX)/bin/gcc
	ln -s /usr/bin/ccache $(HOSTPREFIX)/bin/g++
	ln -s /usr/bin/ccache $(HOSTPREFIX)/bin/$(TARGET)-gcc
	ln -s /usr/bin/ccache $(HOSTPREFIX)/bin/$(TARGET)-g++
