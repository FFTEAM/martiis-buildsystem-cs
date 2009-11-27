#Makefile to build system tools

$(DEPDIR)/rsync:
	$(UNTAR)/rsync-3.0.6.tar.gz
	pushd $(BUILD_TMP)/rsync-3.0.6 && \
		$(CONFIGURE) --prefix= --build=$(BUILD) --host=$(TARGET) --mandir=$(BUILD_TMP)/.remove && \
		$(MAKE) all && \
		make install prefix=$(TARGETPREFIX)
	$(REMOVE)/rsync-3.0.6
	$(REMOVE)/.remove
	touch $@

$(DEPDIR)/procps: libncurses
	$(UNTAR)/procps-3.2.7.tar.gz
	pushd $(BUILD_TMP)/procps-3.2.7 && \
		$(PATCH)/procps-3.2.7-avoid-ICE-with-gcc-4.3.2-arm.diff && \
		make CC=$(TARGET)-gcc LDFLAGS="$(LD_FLAGS)" \
			CPPFLAGS="-pipe -O2 -g -I$(TARGETPREFIX)/include -I$(TARGETPREFIX)/include/ncurses -D__GNU_LIBRARY__" \
			top ps/ps && \
		rm -f $(TARGETPREFIX)/bin/ps && \
		mkdir -p $(TARGETPREFIX)/bin && \
		install -m 755 top ps/ps $(TARGETPREFIX)/bin && \
		install -m 755 proc/libproc-3.2.7.so $(TARGETPREFIX)/lib
	$(REMOVE)/procps-3.2.7
	touch $@

$(DEPDIR)/busybox:
	$(UNTAR)/busybox-1.15.2.tar.bz2
	pushd $(BUILD_TMP)/busybox-1.15.2 && \
		cp $(PATCHES)/busybox-hd1.config .config && \
		sed -i -e 's#^CONFIG_PREFIX.*#CONFIG_PREFIX="$(TARGETPREFIX)"#' .config && \
		$(MAKE) all  CROSS_COMPILE=$(TARGET)- CFLAGS_EXTRA="$(TARGET_CFLAGS)" && \
		make install CROSS_COMPILE=$(TARGET)- CFLAGS_EXTRA="$(TARGET_CFLAGS)"
	$(REMOVE)/busybox-1.15.2
	touch $@

$(DEPDIR)/strace:
	$(UNTAR)/strace-4.5.19.tar.bz2
	pushd $(BUILD_TMP)/strace-4.5.19 && \
		CFLAGS="-W -Wall $(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(TARGETPREFIX)/include" \
		CXXFLAGS="-W -Wall $(TARGET_CXXFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure --prefix= --build=$(BUILD) --host=$(TARGET) --mandir=$(BUILD_TMP)/.remove && \
		$(MAKE) all && \
		make install prefix=$(TARGETPREFIX)
	$(REMOVE)/strace-4.5.19
	$(REMOVE)/.remove
	touch $@

