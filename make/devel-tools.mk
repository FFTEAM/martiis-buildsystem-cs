#Makefile to build devel-tools

$(D)/strace: $(ARCHIVE)/strace-$(STRACE_VER).tar.xz | $(TARGETPREFIX)
	rm -rf $(PKGPREFIX)
	$(UNTAR)/strace-$(STRACE_VER).tar.xz
ifeq ($(PLATFORM), tripledragon)
	cd $(BUILD_TMP)/strace-$(STRACE_VER) && \
		$(PATCH)/strace-add-TD-ioctls.diff
endif
	set -e; cd $(BUILD_TMP)/strace-$(STRACE_VER); \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(TARGETPREFIX)/include" \
		CXXFLAGS="$(TARGET_CXXFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure --prefix= --build=$(BUILD) --host=$(TARGET) --mandir=$(BUILD_TMP)/.remove; \
		$(MAKE) all; \
		make install prefix=$(PKGPREFIX)
	cp -a $(PKGPREFIX)/* $(TARGETPREFIX)
	rm $(PKGPREFIX)/bin/strace-graph
	PKG_VER=$(STRACE_VER) $(OPKG_SH) $(CONTROL_DIR)/strace
	$(REMOVE)/strace-$(STRACE_VER) $(PKGPREFIX)
	$(REMOVE)/.remove
	touch $@

#  NOTE:
#  gdb built for target or local-PC
$(D)/gdb: $(ARCHIVE)/gdb-$(GDB_VER).tar.bz2 libncurses zlib | $(TARGETPREFIX)
	rm -rf $(PKGPREFIX)
	$(UNTAR)/gdb-$(GDB_VER).tar.bz2
	set -e; cd $(BUILD_TMP)/gdb-$(GDB_VER); \
		$(PATCH)/gdb-7.1-remove-builddate.diff; \
		$(BUILDENV) \
		./configure \
			--nfp --disable-werror \
			--prefix=/opt/pkg \
			--mandir=$(BUILD_TMP)/.remove \
			--infodir=$(BUILD_TMP)/.remove \
			--build=$(BUILD) --host=$(TARGET); \
		$(MAKE) all-gdb; \
		make install-gdb prefix=$(PKGPREFIX)/opt/pkg
	cp -a $(PKGPREFIX)/* $(TARGETPREFIX)
	rm -fr $(PKGPREFIX)/opt/pkg/share
	rm $(PKGPREFIX)/opt/pkg/bin/gdbtui
	rm -rf $(BUILD_TMP)/gdb-tmp
	mkdir $(BUILD_TMP)/gdb-tmp
	mv $(PKGPREFIX)/opt/pkg/bin/gdbserver $(BUILD_TMP)/gdb-tmp
	PKG_VER=$(GDB_VER) $(OPKG_SH) $(CONTROL_DIR)/gdb/gdb
	rm -rf $(PKGPREFIX)
	mkdir -p $(PKGPREFIX)/bin
	mv $(BUILD_TMP)/gdb-tmp/gdbserver $(PKGPREFIX)/bin
	PKG_VER=$(GDB_VER) $(OPKG_SH) $(CONTROL_DIR)/gdb/gdbserver
	$(REMOVE)/gdb-$(GDB_VER) $(PKGPREFIX) $(BUILD_TMP)/gdb-tmp $(BUILD_TMP)/.remove
	touch $@

#  NOTE:
#  gdb-remote built for local-PC or target
$(D)/gdb-remote: $(ARCHIVE)/gdb-$(GDB_VER).tar.bz2 | $(TARGETPREFIX)
	$(UNTAR)/gdb-$(GDB_VER).tar.bz2
	set -e; cd $(BUILD_TMP)/gdb-$(GDB_VER); \
		./configure \
			--nfp --disable-werror \
			--prefix=$(HOSTPREFIX) \
			--build=$(BUILD) --host=$(BUILD) --target=$(TARGET); \
		$(MAKE) all-gdb; \
		make install-gdb; \
	$(REMOVE)/gdb-$(GDB_VER)
	touch $@

devel-tools: $(D)/strace $(D)/gdb
devel-tools-all: devel-tools $(D)/gdb-remote

PHONY += devel-tools devel-tools-all
