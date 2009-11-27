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
