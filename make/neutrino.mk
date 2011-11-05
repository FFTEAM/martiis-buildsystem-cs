#Makefile to build NEUTRINO

NEUTRINO_DEPS  = libcurl libid3tag libmad freetype libboost libjpeg libungif ffmpeg
NEUTRINO_DEPS += openthreads

N_CFLAGS   = -Wall -W -Wshadow -g -O2 -fno-strict-aliasing -rdynamic
N_CPPFLAGS = -I$(TARGETPREFIX)/include
ifneq ($(PLATFORM), tripledragon)
# coolstream
N_CPPFLAGS += -DUSE_NEVIS_GXA
else
# tripledragon
N_CPPFLAGS += -I$(TARGETPREFIX)/include/hardware
# TODO: should we set this in a Header? Do we also need _D_LARGEFILE etc?
N_CPPFLAGS += -D_FILE_OFFSET_BITS=64
endif

# choose between static and dynamic libtremor. As long as nothing else
# uses libtremor, static usage does not really hurt and is compatible
# with the "original" image
#N_CONFIG_OPTS = --with-tremor-static
N_CONFIG_OPTS = --with-tremor --disable-upnp
NEUTRINO_DEPS += libvorbisidec

# enable FLAC decoder in neutrino
#N_CONFIG_OPTS += --enable-flac
#NEUTRINO_DEPS += libFLAC

# the original build script links against openssl, but it is not needed at all.
# libcurl is picked up by configure anyway, so not needed here.
# N_LDFLAGS  = -L$(TARGETPREFIX)/lib -lcurl -lssl -lcrypto -ldl
N_LDFLAGS =
N_LDFLAGS += -Wl,-rpath-link,$(TARGETLIB)

# finally we can build outside of the source directory
N_OBJDIR = $(BUILD_TMP)/$(FLAVOUR)
#endif
# use this if you want to build inside the source dir - but you don't want that ;)
# N_OBJDIR = $(N_HD_SOURCE)

$(N_OBJDIR)/config.status: $(NEUTRINO_DEPS) $(MAKE_DIR)/neutrino.mk
	test -d $(N_OBJDIR) || mkdir -p $(N_OBJDIR)
	$(N_HD_SOURCE)/autogen.sh
	pushd $(N_OBJDIR) && \
		export PKG_CONFIG=$(PKG_CONFIG) && \
		export PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) && \
		CC=$(TARGET)-gcc CFLAGS="$(N_CFLAGS)" CXXFLAGS="$(N_CFLAGS)" CPPFLAGS="$(N_CPPFLAGS)" \
		LDFLAGS="$(N_LDFLAGS)" \
		$(N_HD_SOURCE)/configure --host=$(TARGET) --build=$(BUILD) --prefix= \
				--enable-silent-rules --enable-mdev \
				--enable-maintainer-mode --with-target=cdk --with-boxtype=$(PLATFORM) \
				$(N_CONFIG_OPTS)

$(PKGPREFIX)/.version \
$(TARGETPREFIX)/.version:
	echo "version=1200`date +%Y%m%d%H%M`"	 > $@
	echo "creator=$(MAINTAINER)"		>> $@
	echo "imagename=HD-Neutrino"		>> $@
	echo "builddate=`cd $(N_HD_SOURCE); git describe --always --dirty`" >> $@
	echo "homepage=http://gitorious.org/neutrino-hd"	>> $@

PHONY += $(PKGPREFIX)/.version $(TARGETPREFIX)/.version

$(D)/neutrino: $(N_OBJDIR)/config.status
	PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
	$(MAKE) -C $(N_OBJDIR) all     DESTDIR=$(TARGETPREFIX)
	$(MAKE) -C $(N_OBJDIR) install DESTDIR=$(TARGETPREFIX)
	+make $(TARGETPREFIX)/.version
	: touch $@

neutrino-pkg: $(N_OBJDIR)/config.status
	rm -rf $(PKGPREFIX) $(BUILD_TMP)/neutrino-hd-control
	PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
	$(MAKE) -C $(N_OBJDIR) all     DESTDIR=$(TARGETPREFIX)
	$(MAKE) -C $(N_OBJDIR) install DESTDIR=$(PKGPREFIX)
	install -D -m 0755 skel-root/common/etc/init.d/start_neutrino $(PKGPREFIX)/etc/init.d/start_neutrino
	make $(PKGPREFIX)/.version
	cp -a $(CONTROL_DIR)/neutrino-hd $(BUILD_TMP)/neutrino-hd-control
	DEP=`$(TARGET)-objdump -p $(PKGPREFIX)/bin/neutrino | awk '/NEEDED/{print $$2}' | sort` && \
		DEP=`echo $$DEP` && \
		DEP="$${DEP// /, }" && \
		sed -i "s/@DEP@/$$DEP/" $(BUILD_TMP)/neutrino-hd-control/control
ifeq ($(PLATFORM), coolstream)
	if grep -q libcoolstream-mt.so $(BUILD_TMP)/neutrino-hd-control/control; then \
		sed -i 's/^\(Depends:.*\)$$/\1, cs-libs (>= 1608), cs-beta-drivers/' $(BUILD_TMP)/neutrino-hd-control/control; \
	else \
		sed -i 's/^\(Depends:.*\)$$/\1, cs-libs (>= 1134), cs-drivers/' $(BUILD_TMP)/neutrino-hd-control/control; \
	fi
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
