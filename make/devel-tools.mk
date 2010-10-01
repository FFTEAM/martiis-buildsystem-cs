#Makefile to build devel-tools

$(D)/strace: $(ARCHIVE)/strace-4.5.20.tar.bz2 | $(TARGETPREFIX)
	$(UNTAR)/strace-4.5.20.tar.bz2
	pushd $(BUILD_TMP)/strace-4.5.20 && \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(TARGETPREFIX)/include" \
		CXXFLAGS="$(TARGET_CXXFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure --prefix= --build=$(BUILD) --host=$(TARGET) --mandir=$(BUILD_TMP)/.remove && \
		$(MAKE) all && \
		make install prefix=$(TARGETPREFIX)
	$(REMOVE)/strace-4.5.20
	$(REMOVE)/.remove
	touch $@

#  NOTE:
#  gdb built for target or local-PC
$(D)/gdb: $(ARCHIVE)/gdb-7.1.tar.bz2 | $(TARGETPREFIX)
	$(UNTAR)/gdb-7.1.tar.bz2
	pushd $(BUILD_TMP)/gdb-7.1 && \
		$(BUILDENV) \
		./configure \
			--nfp --disable-werror \
			--prefix= \
			--mandir=$(BUILD_TMP)/.remove \
			--infodir=$(BUILD_TMP)/.remove \
			--build=$(BUILD) --host=$(TARGET) && \
		$(MAKE) all-gdb && \
		make install-gdb prefix=$(TARGETPREFIX) && \
	$(REMOVE)/gdb-7.1
	$(REMOVE)/.remove
	touch $@

#  NOTE:
#  gdb-remote built for local-PC or target
$(D)/gdb-remote: $(ARCHIVE)/gdb-7.1.tar.bz2 | $(TARGETPREFIX)
	$(UNTAR)/gdb-7.1.tar.bz2
	pushd $(BUILD_TMP)/gdb-7.1 && \
		./configure \
			--nfp --disable-werror \
			--prefix=$(HOSTPREFIX) \
			--build=$(BUILD) --host=$(BUILD) --target=$(TARGET) && \
		$(MAKE) all-gdb && \
		make install-gdb && \
	$(REMOVE)/gdb-7.1
	touch $@

devel-tools: $(D)/strace $(D)/gdb
devel-tools-all: devel-tools $(D)/gdb-remote

PHONY += devel-tools devel-tools-all