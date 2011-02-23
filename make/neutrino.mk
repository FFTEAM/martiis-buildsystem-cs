#Makefile to build NEUTRINO

NEUTRINO_DEPS  = libcurl libid3tag libmad freetype libboost libjpeg libungif ffmpeg

N_CFLAGS  = -Wall -W -Wshadow -g -O2 -fno-strict-aliasing
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

# if you really want slow libvorbis, leave N_CONFIG_OPTS empty and use
# NEUTRINO_DEPS += libvorbis
N_CONFIG_OPTS = --with-tremor
NEUTRINO_DEPS += libvorbisidec

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
				--enable-silent-rules --enable-mdev \
				--enable-maintainer-mode --with-target=cdk --with-boxtype=$(PLATFORM) \
				$(N_CONFIG_OPTS)

$(PKGPREFIX)/.version \
$(TARGETPREFIX)/.version:
	echo "version=1200`date +%Y%m%d%H%M`"	 > $@
	echo "creator=`id -un`"			>> $@
	echo "imagename=HD-Neutrino"		>> $@
	echo "homepage=http://gitorious.org/neutrino-hd"	>> $@

$(D)/neutrino: $(N_OBJDIR)/config.status
	PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
	$(MAKE) -C $(N_OBJDIR) all     DESTDIR=$(TARGETPREFIX)
	$(MAKE) -C $(N_OBJDIR) install DESTDIR=$(TARGETPREFIX)
	# make $(TARGETPREFIX)/.version
	touch $@

neutrino-pkg: $(N_OBJDIR)/config.status
	rm -rf $(PKGPREFIX) $(BUILD_TMP)/neutrino-hd-control
	PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
	$(MAKE) -C $(N_OBJDIR) all     DESTDIR=$(TARGETPREFIX)
	$(MAKE) -C $(N_OBJDIR) install DESTDIR=$(PKGPREFIX)
	install -D -m 0755 skel-root/common/etc/init.d/start_neutrino $(PKGPREFIX)/etc/init.d/start_neutrino
	make $(PKGPREFIX)/.version
	cp -a $(CONTROL_DIR)/neutrino-hd $(BUILD_TMP)/neutrino-hd-control
ifeq ($(PLATFORM), tripledragon)
	# ugly: tripledragon neutrino has different requirements...
	sed -i 's/libOpenThreads.so.12.*/directfb, td-drivers/' $(BUILD_TMP)/neutrino-hd-control/control
endif
ifneq ($(findstring --with-tremor, $(N_CONFIG_OPTS)),)
	# replace libvorbis/libogg with libvorbisidec...
	sed -i 's/libvorbisf.*ogg.so.0,/libvorbisidec.so.1,/' $(BUILD_TMP)/neutrino-hd-control/control
endif
	# ignore the .version file for package  comparison
	CMP_IGNORE="/.version" $(OPKG_SH) $(BUILD_TMP)/neutrino-hd-control
	rm -rf $(PKGPREFIX)

neutrino-clean:
	-make -C $(N_OBJDIR) uninstall
	-make -C $(N_OBJDIR) distclean
	-rm $(N_OBJDIR)/config.status
	-rm $(D)/neutrino

PHONY += neutrino-clean neutrino-system neutrino-system-seife
