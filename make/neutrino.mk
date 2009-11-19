#Makefile to build NEUTRINO

N_CFLAGS  = -Wall -g0 -O2 -D__KERNEL_STRICT_NAMES -DUSE_NEVIS_GXA
N_CFLAGS += -I$(TARGETPREFIX)/include
N_CFLAGS += -I$(TARGETPREFIX)/include/freetype2
N_LDFLAGS  = -L$(TARGETPREFIX)/lib -lcurl -lssl -lcrypto -ldl
N_LDFLAGS += -Wl,-rpath-link,$(TARGETLIB)
# this is needed to avoid a "av_free_packet" unresoved symbol error
N_LDFLAGS += -Wl,-u,av_free_packet

# does not yet work...
# N_OBJDIR = $(BUILD_TMP)/neutrino-hd
N_OBJDIR = $(SOURCE_DIR)/neutrino-hd

$(N_OBJDIR)/config.status:
	pushd $(SOURCE_DIR)/neutrino-hd && \
		touch README && \
		./autogen.sh
	pushd $(N_OBJDIR) && \
		export PKG_CONFIG=$(PKG_CONFIG) && \
		CC=$(TARGET)-gcc CFLAGS="$(N_CFLAGS)" CXXFLAGS="$(N_CFLAGS)" LDFLAGS="$(N_LDFLAGS)" \
		$(SOURCE_DIR)/neutrino-hd/configure --host=$(TARGET) --build=$(BUILD) --prefix=$(TARGETPREFIX) --with-target=cdk

$(TARGETPREFIX)/.version: $(TARGETPREFIX)/bin/neutrino
	echo "version=1200`date +%Y%m%d%H%M`"	 > $@
	echo "creator=`id -un`"			>> $@
	echo "imagename=HD-Neutrino"		>> $@
	echo "homepage=http://gitorious.org/neutrino-hd"	>> $@

$(DEPDIR)/neutrino: libcurl libid3tag libmad freetype libboost libjpeg libvorbis ffmpeg openssl $(N_OBJDIR)/config.status
	$(MAKE) -C $(N_OBJDIR) all
	$(MAKE) -C $(N_OBJDIR) install
	# make $(TARGETPREFIX)/.version
	touch $@

neutrino-clean:
	-make -C $(N_OBJDIR) uninstall distclean
	-rm $(DEPDIR)/neutrino

