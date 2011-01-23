#Makefile to build NEUTRINO

NEUTRINO_DEPS  = libcurl libid3tag libmad freetype libboost libjpeg libungif libvorbis ffmpeg

N_CFLAGS  = -Wall -W -Wshadow -g -O2
N_CFLAGS += -I$(TARGETPREFIX)/include
N_CFLAGS += -I$(TARGETPREFIX)/include/freetype2
ifneq ($(PLATFORM), tripledragon)
# coolstream
N_CFLAGS += -DUSE_NEVIS_GXA
NEUTRINO_DEPS += openthreads
else
# tripledragon
N_CFLAGS += -I$(TARGETPREFIX)/include/hardware
# TODO: should we set this in a Header? Do we also need _D_LARGEFILE etc?
N_CFLAGS += -D_FILE_OFFSET_BITS=64
endif

# the original build script links against openssl, but it is not needed at all.
# N_LDFLAGS  = -L$(TARGETPREFIX)/lib -lcurl -lssl -lcrypto -ldl
N_LDFLAGS  = -L$(TARGETPREFIX)/lib -lcurl -ldl
N_LDFLAGS += -Wl,-rpath-link,$(TARGETLIB)

# finally we can build outside of the source directory
N_OBJDIR = $(BUILD_TMP)/neutrino-hd
# use this if you want to build inside the source dir - but you don't want that ;)
# N_OBJDIR = $(N_HD_SOURCE)

$(N_OBJDIR)/config.status: $(NEUTRINO_DEPS) $(MAKE_DIR)/neutrino.mk
	test -d $(N_OBJDIR) || mkdir -p $(N_OBJDIR)
	$(N_HD_SOURCE)/autogen.sh
	pushd $(N_OBJDIR) && \
		export PKG_CONFIG=$(PKG_CONFIG) && \
		export PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) && \
		CC=$(TARGET)-gcc CFLAGS="$(N_CFLAGS)" CXXFLAGS="$(N_CFLAGS)" LDFLAGS="$(N_LDFLAGS)" \
		$(N_HD_SOURCE)/configure --host=$(TARGET) --build=$(BUILD) --prefix= \
				--enable-maintainer-mode --with-target=cdk --with-boxtype=$(PLATFORM)

$(PKGPREFIX)/.version \
$(TARGETPREFIX)/.version:
	echo "version=1200`date +%Y%m%d%H%M`"	 > $@
	echo "creator=`id -un`"			>> $@
	echo "imagename=HD-Neutrino"		>> $@
	echo "homepage=http://gitorious.org/neutrino-hd"	>> $@

$(D)/neutrino: $(N_OBJDIR)/config.status
	$(MAKE) -C $(N_OBJDIR) all
	$(MAKE) -C $(N_OBJDIR) install DESTDIR=$(TARGETPREFIX)
	# make $(TARGETPREFIX)/.version
	touch $@

neutrino-pkg: $(N_OBJDIR)/config.status
	rm -rf $(PKGPREFIX)
	$(MAKE) -C $(N_OBJDIR) all
	$(MAKE) -C $(N_OBJDIR) install DESTDIR=$(PKGPREFIX)
	make $(PKGPREFIX)/.version
	$(OPKG_SH) $(CONTROL_DIR)/neutrino-hd
	rm -rf $(PKGPREFIX)

neutrino-clean:
	-make -C $(N_OBJDIR) uninstall
	-make -C $(N_OBJDIR) distclean
	-rm $(N_OBJDIR)/config.status
	-rm $(D)/neutrino

neutrino-system: $(D)/busybox $(D)/procps $(D)/rsync $(D)/gdb $(D)/strace

neutrino-system-seife: neutrino-system $(D)/autofs

PHONY += neutrino-clean neutrino-system neutrino-system-seife
