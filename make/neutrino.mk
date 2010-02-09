#Makefile to build NEUTRINO

N_CFLAGS  = -Wall -W -Wshadow -g -O2 -D__KERNEL_STRICT_NAMES -DUSE_NEVIS_GXA
N_CFLAGS += -I$(TARGETPREFIX)/include
N_CFLAGS += -I$(TARGETPREFIX)/include/freetype2
# the original build script links against openssl, but it is not needed at all.
# N_LDFLAGS  = -L$(TARGETPREFIX)/lib -lcurl -lssl -lcrypto -ldl
N_LDFLAGS  = -L$(TARGETPREFIX)/lib -lcurl -ldl
N_LDFLAGS += -Wl,-rpath-link,$(TARGETLIB)

# finally we can build outside of the source directory
N_OBJDIR = $(BUILD_TMP)/neutrino-hd
# use this if you want to build inside the source dir - but you don't want that ;)
# N_OBJDIR = $(SOURCE_DIR)/neutrino-hd

$(N_OBJDIR):
	mkdir -p $(N_OBJDIR)

$(N_OBJDIR)/config.status: $(D)/libcurl $(D)/libid3tag $(D)/libmad $(D)/freetype $(D)/libboost $(D)/libjpeg $(D)/libungif $(D)/libvorbis $(D)/ffmpeg
	make $(N_OBJDIR)
	$(SOURCE_DIR)/neutrino-hd/autogen.sh
	pushd $(N_OBJDIR) && \
		export PKG_CONFIG=$(PKG_CONFIG) && \
		CC=$(TARGET)-gcc CFLAGS="$(N_CFLAGS)" CXXFLAGS="$(N_CFLAGS)" LDFLAGS="$(N_LDFLAGS)" \
		$(SOURCE_DIR)/neutrino-hd/configure --host=$(TARGET) --build=$(BUILD) --prefix=$(TARGETPREFIX) \
				--enable-maintainer-mode --with-target=cdk

$(TARGETPREFIX)/.version: $(TARGETPREFIX)/bin/neutrino
	echo "version=1200`date +%Y%m%d%H%M`"	 > $@
	echo "creator=`id -un`"			>> $@
	echo "imagename=HD-Neutrino"		>> $@
	echo "homepage=http://gitorious.org/neutrino-hd"	>> $@

$(D)/neutrino: $(N_OBJDIR)/config.status
	$(MAKE) check-repo
	$(MAKE) -C $(N_OBJDIR) all
	$(MAKE) -C $(N_OBJDIR) install
	# make $(TARGETPREFIX)/.version
	touch $@

neutrino-clean:
	-make -C $(N_OBJDIR) uninstall distclean
	-rm $(D)/neutrino
