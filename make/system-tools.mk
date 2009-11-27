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

