# Makefile to build system libs, potentially needed by neutrino and enigma

$(D)/zlib: $(ARCHIVE)/zlib-$(ZLIB-VER).tar.bz2 | $(TARGETPREFIX)
	$(UNTAR)/zlib-$(ZLIB-VER).tar.bz2
	set -e; cd $(BUILD_TMP)/zlib-$(ZLIB-VER); \
		CC=$(TARGET)-gcc mandir=$(BUILD_TMP)/.remove ./configure --prefix= --shared; \
		$(MAKE); \
		ln -sf /bin/true ldconfig; \
		PATH=$(BUILD_TMP)/zlib-$(ZLIB-VER):$(PATH) make install prefix=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/zlib.pc
	$(REMOVE)/zlib-$(ZLIB-VER) $(PKGPREFIX)
	mkdir -p $(PKGPREFIX)/lib
	cp -a $(TARGETPREFIX)/lib/libz.so.* $(PKGPREFIX)/lib
	PKG_VER=$(ZLIB-VER) $(OPKG_SH) $(CONTROL_DIR)/libz
	$(REMOVE)/.remove $(PKGPREFIX)
	touch $@

$(D)/libblkid: $(D)/libuuid
$(D)/libuuid: $(ARCHIVE)/util-linux-ng-$(UTIL_LINUX_NG-VER).tar.bz2 | $(TARGETPREFIX)
	$(UNTAR)/util-linux-ng-$(UTIL_LINUX_NG-VER).tar.bz2
	set -e; cd $(BUILD_TMP)/util-linux-ng-$(UTIL_LINUX_NG-VER); \
		$(CONFIGURE) --prefix= \
			--disable-libmount \
			--disable-static \
			--without-ncurses \
			--mandir=/.remove; \
		$(MAKE) -C shlibs; \
		$(MAKE) -C shlibs install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/uuid.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/blkid.pc
	rm -rf $(TARGETPREFIX)/.remove
	$(REMOVE)/util-linux-ng-$(UTIL_LINUX_NG-VER)
	rm -fr $(PKGPREFIX)
	mkdir -p $(PKGPREFIX)/lib
	cp -a $(TARGETPREFIX)/lib/libblkid.so.{1,1.1.0} $(PKGPREFIX)/lib
	$(OPKG_SH) $(CONTROL_DIR)/util-linux/libblkid
	rm $(PKGPREFIX)/lib/*
	cp -a $(TARGETPREFIX)/lib/libuuid.so.{1,1.3.0} $(PKGPREFIX)/lib
	$(OPKG_SH) $(CONTROL_DIR)/util-linux/libuuid
	rm -rf $(PKGPREFIX)
	touch $(D)/libuuid $(D)/libblkid

ifeq ($(BOXARCH), arm)
MAD_FPM = arm
else
ifeq ($(BOXARCH), powerpc)
MAD_FPM = ppc
else
MAD_FPM = default
endif
endif
$(D)/libmad: $(ARCHIVE)/libmad-$(MAD-VER).tar.gz | $(TARGETPREFIX)
	$(UNTAR)/libmad-$(MAD-VER).tar.gz
	set -e; cd $(BUILD_TMP)/libmad-$(MAD-VER); \
		patch -p1 < $(PATCHES)/libmad.diff; \
		patch -p1 < $(PATCHES)/libmad-$(MAD-VER)-arm-buildfix.diff; \
		touch NEWS AUTHORS ChangeLog; \
		autoreconf -fi; \
		$(CONFIGURE) --prefix= --enable-shared=yes --enable-speed --enable-fpm=$(MAD_FPM) --enable-sso; \
		$(MAKE) all; \
		make install DESTDIR=$(TARGETPREFIX); \
		sed "s!^prefix=.*!prefix=$(TARGETPREFIX)!;" mad.pc > $(PKG_CONFIG_PATH)/libmad.pc
	$(REWRITE_LIBTOOL)/libmad.la
	$(REMOVE)/libmad-$(MAD-VER) $(PKGPREFIX)
	mkdir -p $(PKGPREFIX)/lib
	cp -a $(TARGETPREFIX)/lib/libmad.so.* $(PKGPREFIX)/lib
	$(OPKG_SH) $(CONTROL_DIR)/libmad
	rm -rf $(PKGPREFIX)
	touch $@

$(D)/libid3tag: $(D)/zlib $(ARCHIVE)/libid3tag-$(ID3TAG-VER)$(ID3TAG-SUBVER).tar.gz | $(TARGETPREFIX)
	$(UNTAR)/libid3tag-$(ID3TAG-VER)$(ID3TAG-SUBVER).tar.gz
	set -e; cd $(BUILD_TMP)/libid3tag-$(ID3TAG-VER)$(ID3TAG-SUBVER); \
		patch -p1 < $(PATCHES)/libid3tag.diff; \
		$(CONFIGURE) --prefix= --build=$(BUILD) --host=$(TARGET) --enable-shared=yes; \
		$(MAKE) all; \
		make install DESTDIR=$(TARGETPREFIX); \
		sed "s!^prefix=.*!prefix=$(TARGETPREFIX)!;" id3tag.pc > $(PKG_CONFIG_PATH)/libid3tag.pc
	$(REWRITE_LIBTOOL)/libid3tag.la
	$(REMOVE)/libid3tag-$(ID3TAG-VER)$(ID3TAG-SUBVER) $(PKGPREFIX)
	mkdir -p $(PKGPREFIX)/lib
	cp -a $(TARGETPREFIX)/lib/libid3tag.so.* $(PKGPREFIX)/lib
	$(OPKG_SH) $(CONTROL_DIR)/libid3tag
	rm -rf $(PKGPREFIX)
	touch $@

$(D)/libungif: $(ARCHIVE)/libungif-$(UNGIF-VER).tar.bz2 | $(TARGETPREFIX)
	$(UNTAR)/libungif-$(UNGIF-VER).tar.bz2
	set -e; cd $(BUILD_TMP)/libungif-$(UNGIF-VER); \
		$(CONFIGURE) --prefix= --build=$(BUILD) --host=$(TARGET) --without-x --bindir=/.remove; \
		$(MAKE) all; \
		make install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_LIBTOOL)/libungif.la
	rm -rf $(TARGETPREFIX)/.remove
	$(REMOVE)/libungif-$(UNGIF-VER) $(PKGPREFIX)
	mkdir -p $(PKGPREFIX)/lib
	cp -a $(TARGETPREFIX)/lib/libungif.so.* $(PKGPREFIX)/lib
	$(OPKG_SH) $(CONTROL_DIR)/libungif
	rm -rf $(PKGPREFIX)
	touch $@

$(D)/libcurl: $(ARCHIVE)/curl-$(CURL-VER).tar.bz2 $(D)/zlib | $(TARGETPREFIX)
	$(UNTAR)/curl-$(CURL-VER).tar.bz2
	set -e; cd $(BUILD_TMP)/curl-$(CURL-VER); \
		$(CONFIGURE) --prefix= --build=$(BUILD) --host=$(TARGET) \
			--disable-manual --disable-file --disable-rtsp --disable-dict \
			--disable-imap --disable-pop3 --disable-smtp --without-ssl \
			--with-random --mandir=/.remove; \
		$(MAKE) all; \
		mkdir -p $(HOSTPREFIX)/bin; \
		sed -e "s,^prefix=,prefix=$(TARGETPREFIX)," < curl-config > $(HOSTPREFIX)/bin/curl-config; \
		chmod 755 $(HOSTPREFIX)/bin/curl-config; \
		make install DESTDIR=$(PKGPREFIX)
	rm $(PKGPREFIX)/bin/curl-config
	cp -a $(PKGPREFIX)/* $(TARGETPREFIX)
	$(REMOVE)/pkg-lib; mkdir $(BUILD_TMP)/pkg-lib
	cd $(PKGPREFIX) && rm -r include lib/pkgconfig lib/*.so lib/*a .remove/ && mv lib $(BUILD_TMP)/pkg-lib
	$(OPKG_SH) $(CONTROL_DIR)/curl/curl
	rm -rf $(PKGPREFIX)/*
	mv $(BUILD_TMP)/pkg-lib/* $(PKGPREFIX)/
	$(OPKG_SH) $(CONTROL_DIR)/curl/libcurl
	$(REWRITE_LIBTOOL)/libcurl.la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libcurl.pc
	rm -rf $(TARGETPREFIX)/.remove
	$(REMOVE)/curl-$(CURL-VER) $(PKGPREFIX) $(BUILD_TMP)/pkg-lib
	touch $@

# no Package, since it's only linked statically for now also only install static lib
$(D)/libFLAC: $(ARCHIVE)/flac-1.2.1.tar.gz | $(TARGETPREFIX)
	$(UNTAR)/flac-1.2.1.tar.gz
	set -e; cd $(BUILD_TMP)/flac-1.2.1; \
		$(PATCH)/flac-1.2.1-noencoder.diff; \
		$(CONFIGURE) --prefix= --build=$(BUILD) --host=$(TARGET) \
			--disable-ogg --disable-altivec; \
		$(MAKE) -C src/libFLAC; \
		: make -C src/libFLAC  install DESTDIR=$(TARGETPREFIX); \
		cp -a src/libFLAC/.libs/libFLAC.a $(TARGETPREFIX)/lib/; \
		make -C include/FLAC install DESTDIR=$(TARGETPREFIX)
	$(REMOVE)/flac-1.2.1
	touch $@

$(D)/libpng: $(ARCHIVE)/libpng-$(PNG-VER).tar.bz2 $(D)/zlib | $(TARGETPREFIX)
	$(UNTAR)/libpng-$(PNG-VER).tar.bz2
	set -e; cd $(BUILD_TMP)/libpng-$(PNG-VER); \
		$(CONFIGURE) --prefix=$(TARGETPREFIX) --build=$(BUILD) --host=$(TARGET) --bindir=$(HOSTPREFIX)/bin --mandir=$(BUILD_TMP)/tmpman; \
		ECHO=echo $(MAKE) all; \
		make install
	$(REMOVE)/libpng-$(PNG-VER) $(BUILD_TMP)/tmpman $(PKGPREFIX)
	mkdir -p $(PKGPREFIX)/lib
	cp -a $(TARGETPREFIX)/lib/libpng12.so.* $(PKGPREFIX)/lib
	$(OPKG_SH) $(CONTROL_DIR)/libpng12
	rm -rf $(PKGPREFIX)
	touch $@

$(D)/freetype: $(D)/libpng $(ARCHIVE)/freetype-$(FREETYPE-VER).tar.bz2 | $(TARGETPREFIX)
	$(UNTAR)/freetype-$(FREETYPE-VER).tar.bz2
	set -e; cd $(BUILD_TMP)/freetype-$(FREETYPE-VER); \
		patch -p1 < $(PATCHES)/freetype-2.3.9-coolstream.diff; \
		$(CONFIGURE) --prefix= --build=$(BUILD) --host=$(TARGET); \
		$(MAKE) all; \
		sed -e "s,^prefix=,prefix=$(TARGETPREFIX)," < builds/unix/freetype-config > $(HOSTPREFIX)/bin/freetype-config; \
		chmod 755 $(HOSTPREFIX)/bin/freetype-config; \
		make install libdir=$(TARGETPREFIX)/lib includedir=$(TARGETPREFIX)/include bindir=$(TARGETPREFIX)/bin prefix=$(TARGETPREFIX)
	rm $(TARGETPREFIX)/bin/freetype-config
	$(REWRITE_LIBTOOL)/libfreetype.la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/freetype2.pc
	$(REMOVE)/freetype-$(FREETYPE-VER) $(PKGPREFIX)
	mkdir -p $(PKGPREFIX)/lib
	cp -a $(TARGETPREFIX)/lib/libfreetype.so.* $(PKGPREFIX)/lib
	$(OPKG_SH) $(CONTROL_DIR)/libfreetype
	rm -rf $(PKGPREFIX)
	touch $@

## build both libjpeg.so.62 and libjpeg.so.8
## use only libjpeg.so.62 for our own build, but keep libjpeg8 for
## compatibility to third party binaries
$(D)/libjpeg: $(ARCHIVE)/libjpeg-turbo-$(JPEG_TURBO-VER).tar.gz | $(TARGETPREFIX)
	$(UNTAR)/libjpeg-turbo-$(JPEG_TURBO-VER).tar.gz
	set -e; cd $(BUILD_TMP)/libjpeg-turbo-$(JPEG_TURBO-VER); \
		export CC=$(TARGET)-gcc; \
		$(CONFIGURE) --prefix= --build=$(BUILD) --host=$(TARGET) --enable-shared \
			--mandir=/.remove --bindir=/.remove \
			--with-jpeg8 --disable-static --includedir=/.remove ; \
		$(MAKE) ; \
		make install DESTDIR=$(TARGETPREFIX); \
		make clean; \
		$(CONFIGURE) --prefix= --build=$(BUILD) --host=$(TARGET) --enable-shared \
			--mandir=/.remove --bindir=/.remove ; \
		$(MAKE) ; \
		make install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_LIBTOOL)/libjpeg.la
	rm -f $(TARGETPREFIX)/lib/libturbojpeg* $(TARGETPREFIX)/include/turbojpeg.h
	$(REMOVE)/libjpeg-turbo-$(JPEG_TURBO-VER) $(TARGETPREFIX)/.remove $(PKGPREFIX)
	mkdir -p $(PKGPREFIX)/lib
	cp -a $(TARGETPREFIX)/lib/libjpeg.so.* $(PKGPREFIX)/lib
	PKG_PROV=`opkg-find-provides.sh $(PKGPREFIX)` \
		PKG_VER=$(JPEG_TURBO-VER) $(OPKG_SH) $(CONTROL_DIR)/libjpeg
	rm -rf $(PKGPREFIX)
	touch $@

$(D)/libboost: $(ARCHIVE)/boost_$(BOOST-VER).tar.bz2 | $(TARGETPREFIX)
	set -e; cd $(BUILD_TMP); \
		tar xf $(ARCHIVE)/boost_$(BOOST-VER).tar.bz2 boost_$(BOOST-VER)/boost; \
		rm -rf $(TARGETPREFIX)/include/boost;\
		mv boost_$(BOOST-VER)/boost $(TARGETPREFIX)/include/boost; \
		rmdir boost_$(BOOST-VER)
	touch $@

# openssl seems to have problem with parallel builds, so use "make" instead of "$(MAKE)"
$(D)/openssl: $(ARCHIVE)/openssl-$(OPENSSL-VER)$(OPENSSL-SUBVER).tar.gz | $(TARGETPREFIX)
	$(UNTAR)/openssl-$(OPENSSL-VER)$(OPENSSL-SUBVER).tar.gz
	set -e; cd $(BUILD_TMP)/openssl-$(OPENSSL-VER)$(OPENSSL-SUBVER); \
		sed -i 's/#define DATE.*/#define DATE \\"($(PLATFORM))\\""; \\/' crypto/Makefile; \
		CC=$(TARGET)-gcc \
		./Configure shared no-hw no-engine linux-generic32 --prefix=/ --openssldir=/.remove; \
		make depend; \
		make all; \
		make install_sw INSTALL_PREFIX=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/openssl.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libcrypto.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libssl.pc
	rm -r $(TARGETPREFIX)/.remove $(TARGETPREFIX)/bin/openssl $(TARGETPREFIX)/bin/c_rehash
	$(REMOVE)/openssl-$(OPENSSL-VER)$(OPENSSL-SUBVER)
	chmod 0755 $(TARGETPREFIX)/lib/libcrypto.so.* $(TARGETPREFIX)/lib/libssl.so.*
	rm -rf $(PKGPREFIX)
	mkdir -p $(PKGPREFIX)/lib
	cp -a $(TARGETPREFIX)/lib/lib{crypto,ssl}.so.$(OPENSSL-VER) $(PKGPREFIX)/lib
	$(OPKG_SH) $(CONTROL_DIR)/openssl-libs
	rm -rf $(PKGPREFIX)
	touch $@

ifeq ($(BOXARCH), arm)
FFMPEG_ENV = CFLAGS=-march=armv6
FFMPEG_CONFIGURE  = --enable-armv6 --arch=arm
FFMPEG_CONFIGURE += --enable-parsers --enable-demuxers --disable-ffmpeg --disable-swscale
FFMPEG_CONFIGURE += --enable-decoder=h263 --enable-decoder=h264 --enable-decoder=mpeg4video
FFMPEG_CONFIGURE += --enable-decoder=vc1 --enable-decoder=mpegvideo --enable-decoder=mpegaudio
FFMPEG_CONFIGURE += --enable-decoder=aac --enable-decoder=dca --enable-decoder=ac3 --enable-decoder=iff_byterun1
FFMPEG_CONFIGURE += --enable-bsfs
endif
ifeq ($(BOXARCH), powerpc)
FFMPEG_CONFIGURE  = --arch=ppc
FFMPEG_CONFIGURE += --disable-parsers --disable-demuxers --enable-ffmpeg --disable-filters
FFMPEG_CONFIGURE += --enable-parser=mjpeg --enable-demuxer=mjpeg --enable-decoder=mjpeg
FFMPEG_CONFIGURE += --enable-encoder=mpeg2video --enable-muxer=mpeg2video
FFMPEG_CONFIGURE += --disable-bsfs
endif
## todo: check. this is a plain copy of tripledragon configure...
ifeq ($(BOXARCH), sh4)
FFMPEG_CONFIGURE  = --arch=sh4
FFMPEG_CONFIGURE += --enable-ffmpeg
FFMPEG_CONFIGURE += --enable-parser=mjpeg --enable-demuxer=mjpeg --enable-decoder=mjpeg
FFMPEG_CONFIGURE += --enable-encoder=mpeg2video --enable-muxer=mpeg2video
FFMPEG_CONFIGURE += --disable-bsfs
endif
$(D)/ffmpeg: $(ARCHIVE)/ffmpeg-$(FFMPEG-VER).tar.bz2 | $(TARGETPREFIX)
	$(UNTAR)/ffmpeg-$(FFMPEG-VER).tar.bz2
	set -e; cd $(BUILD_TMP)/ffmpeg-$(FFMPEG-VER); \
		: $(PATCH)/ffmpeg-dvbsubs.diff; \
		$(PATCH)/ffmpeg-0.6-avoid-UINT64_C.diff; \
		$(PATCH)/ffmpeg-0.10-remove-buildtime.diff; \
		$(FFMPEG_ENV) \
		./configure \
			--disable-decoders --disable-encoders \
			--disable-muxers --disable-ffplay --disable-ffserver \
			$(FFMPEG_CONFIGURE) \
			--enable-decoder=dvbsub --enable-demuxer=mpegps \
			--disable-devices --disable-mmx --disable-altivec --disable-iwmmxt   \
			--disable-protocols --enable-protocol=file \
			--disable-zlib --enable-bzlib \
			--disable-network --disable-ffprobe \
			--disable-static --enable-shared \
			--enable-cross-compile \
			--cross-prefix=$(TARGET)- \
			--target-os=linux \
			--enable-debug --enable-stripping \
			--mandir=/.remove \
			--prefix=/; \
		$(MAKE); \
		make install DESTDIR=$(PKGPREFIX)
	rm -rf $(PKGPREFIX)/share/ffmpeg
	cp -a $(PKGPREFIX)/* $(TARGETPREFIX)
	cp $(BUILD_TMP)/ffmpeg-$(FFMPEG-VER)/version.h $(TARGETPREFIX)/lib/ffmpeg-version.h
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libavdevice.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libavformat.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libavcodec.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libavutil.pc
	rm -rf $(PKGPREFIX)/include $(PKGPREFIX)/lib/pkgconfig $(PKGPREFIX)/lib/*.so $(PKGPREFIX)/.remove
	PKG_VER=$(FFMPEG-VER) PKG_PROV=`opkg-find-provides.sh $(PKGPREFIX)` \
		$(OPKG_SH) $(CONTROL_DIR)/ffmpeg
	$(REMOVE)/ffmpeg-$(FFMPEG-VER) $(PKGPREFIX)
	touch $@

$(D)/libass: $(ARCHIVE)/libass-$(LIBASS_VER).tar.gz | $(TARGETPREFIX)
	$(UNTAR)/libass-$(LIBASS_VER).tar.gz
	set -e; cd $(BUILD_TMP)/libass-$(LIBASS_VER); \
		$(CONFIGURE) --disable-fontconfig --prefix= --disable-shared; \
		$(MAKE); \
		make install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_LIBTOOL)/libass.la
	touch $@

$(D)/libogg: $(ARCHIVE)/libogg-$(OGG-VER).tar.gz | $(TARGETPREFIX)
	$(UNTAR)/libogg-$(OGG-VER).tar.gz
	set -e; cd $(BUILD_TMP)/libogg-$(OGG-VER); \
		patch -p1 < $(PATCHES)/libogg-1.1.4-nodoc.diff; \
		$(CONFIGURE) --prefix= --enable-shared; \
		$(MAKE); \
		make install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/ogg.pc
	$(REWRITE_LIBTOOL)/libogg.la
	$(REMOVE)/libogg-$(OGG-VER) $(PKGPREFIX)
	mkdir -p $(PKGPREFIX)/lib
	cp -a $(TARGETPREFIX)/lib/libogg.so.* $(PKGPREFIX)/lib
	$(OPKG_SH) $(CONTROL_DIR)/libogg
	rm -rf $(PKGPREFIX)
	touch $@

# for some reason, libvorbis does not work with "--prefix=/"
$(D)/libvorbis: $(D)/libogg $(ARCHIVE)/libvorbis-$(VORBIS-VER).tar.bz2 | $(TARGETPREFIX)
	$(UNTAR)/libvorbis-$(VORBIS-VER).tar.bz2
	set -e; cd $(BUILD_TMP)/libvorbis-$(VORBIS-VER); \
		patch -p1 < $(PATCHES)/libvorbis-1.2.3-nodoc.diff; \
		patch -p1 < $(PATCHES)/libvorbis-1.2.3-smaller-chunksize.diff; \
		$(CONFIGURE) --enable-shared --prefix=$(TARGETPREFIX) LDFLAGS="-Wl,-rpath-link,$(TARGETLIB)"; \
		$(MAKE); \
		make install
	# $(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libvorbis.pc
	# $(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libvorbisenc.pc
	# $(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libvorbisfile.pc
	$(REMOVE)/libvorbis-$(VORBIS-VER) $(PKGPREFIX)
	mkdir -p $(PKGPREFIX)/lib
	cp -a $(TARGETPREFIX)/lib/libvorbis.so.* $(PKGPREFIX)/lib
	cp -a $(TARGETPREFIX)/lib/libvorbisfile.so.* $(PKGPREFIX)/lib
	$(OPKG_SH) $(CONTROL_DIR)/libvorbis
	rm -rf $(PKGPREFIX)
	touch $@

ncurses-prereq:
	@if $(MAKE) find-tic find-infocmp ; then \
		true; \
	else \
		echo "**********************************************************"; \
		echo "* tic or infocmp missing, but needed to build libncurses *"; \
		echo "* install the ncurses development package on your system *"; \
		echo "**********************************************************"; \
		false; \
	fi

$(D)/libncurses: $(ARCHIVE)/ncurses-$(NCURSES-VER).tar.gz | ncurses-prereq $(TARGETPREFIX)
	$(UNTAR)/ncurses-$(NCURSES-VER).tar.gz
	set -e; cd $(BUILD_TMP)/ncurses-$(NCURSES-VER); \
		$(CONFIGURE) --build=$(BUILD) --host=$(TARGET) --target=$(TARGET) \
			--prefix= --with-terminfo-dirs=/usr/share/terminfo \
			--disable-big-core --without-debug --without-progs --without-ada --with-shared \
			--without-profile --disable-rpath --without-cxx-binding \
			--with-fallbacks='linux vt100 xterm'; \
		$(MAKE) libs HOSTCC=gcc HOSTLDFLAGS="$(TARGET_LDFLAGS)" \
			HOSTCCFLAGS="$(TARGET_CFLAGS) -DHAVE_CONFIG_H -I../ncurses -DNDEBUG -D_GNU_SOURCE -I../include"; \
		make install.libs DESTDIR=$(TARGETPREFIX)
	$(REMOVE)/ncurses-$(NCURSES-VER) $(PKGPREFIX)
	mkdir -p $(PKGPREFIX)/lib
	# deliberately ignore libforms and libpanel - not yet needed
	cp -a $(TARGETPREFIX)/lib/libncurses.so.* $(PKGPREFIX)/lib
	$(OPKG_SH) $(CONTROL_DIR)/libncurses
	rm -rf $(PKGPREFIX)
	touch $@

# this is butt ugly. For some reason, the old libtool in debian lenny 5.0.7
# does not put "-lz" into LDFLAGS of some subdirs, and I was not able to fix that.
# Hence the LDFLAGS="$(TARGET_LDFLAGS) -lz" hack... :-(
$(D)/directfb: $(ARCHIVE)/DirectFB-$(DIRECTFB-VER).tar.gz $(D)/zlib $(D)/freetype $(D)/libpng $(D)/libjpeg | $(TARGETPREFIX) $(HOSTPREFIX)/bin
	rm -rf $(PKGPREFIX)
	$(UNTAR)/DirectFB-$(DIRECTFB-VER).tar.gz
	set -e; cd $(BUILD_TMP)/DirectFB-$(DIRECTFB-VER); \
		gzip -dc $(PATCHES)/coolstream/directfb-1.4.3-coolstream.diff | patch -p2; \
		patch -p1 -i $(PATCHES)/directfb-1.4.3-cx245x-deinit-restore-fix.diff; \
		sed -i 's/"-DBUILDTIME=.*/"-DBUILDTIME=\\"($(PLATFORM))\\""/' src/core/Makefile.am; \
		./autogen.sh fail || true ; \
		CFLAGS="$(TARGET_CFLAGS)" CPPFLAGS="$(TARGET_CPPFLAGS)" \
			CXXFLAGS="$(TARGET_CXXFLAGS)" PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
			LDFLAGS="$(TARGET_LDFLAGS) -lz" \
			./configure \
			--prefix=/ --mandir=/.remove --bindir=/opt/pkg/bin \
			--build=$(BUILD) --host=$(TARGET) \
			--with-inputdrivers=linuxinput,keyboard,ps2mouse \
			--with-gfxdrivers=cx2450x --disable-video4linux \
			--disable-video4linux2 --enable-zlib --disable-x11 --disable-osx --disable-vnc \
			--enable-debug --disable-network --disable-devmem --disable-sysfs --enable-fbdev \
			--enable-jpeg --with-tests; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(PKGPREFIX); \
		cp -a directfb-config $(HOSTPREFIX)/bin/
	mkdir $(PKGPREFIX)/etc
	printf 'mode "1280x720-50"\n    geometry 1280 720 1280 720 32\n    timings 0 0 0 0 0 0 0\nendmode\n' > $(PKGPREFIX)/etc/fb.modes
	printf 'system=cx2450x\nlinux-input-devices=/dev/input/nevis_ir\nno-linux-input-grab\nmode=1280x720\npixelformat=ARGB\nbg-color=00000000\nno-debug\nautoflip-window\nno-cursor\n' > $(PKGPREFIX)/etc/directfbrc
	rm -fr $(PKGPREFIX)/.remove $(PKGPREFIX)/opt/pkg/bin/directfb-config
	cp -a $(PKGPREFIX)/* $(TARGETPREFIX)/
	find $(PKGPREFIX) -name '*.la' | xargs --no-run-if-empty rm
	rm -fr $(PKGPREFIX)/include $(PKGPREFIX)/lib/pkgconfig $(PKGPREFIX)/lib/*.so
	$(REMOVE)/dfb-tmp
	mkdir $(BUILD_TMP)/dfb-tmp
	mv $(PKGPREFIX)/opt $(BUILD_TMP)/dfb-tmp
	$(OPKG_SH) $(CONTROL_DIR)/cs-directfb/libdirectfb
	rm -rf $(PKGPREFIX)/*
	mv $(BUILD_TMP)/dfb-tmp/opt $(PKGPREFIX)
	rmdir $(BUILD_TMP)/dfb-tmp
	$(OPKG_SH) $(CONTROL_DIR)/cs-directfb/directfb-tools
	$(REMOVE)/DirectFB-$(DIRECTFB-VER) $(PKGPREFIX)
	touch $@

# the strange find | sed hack is needed for old cmake versions which
# don't obey CMAKE_INSTALL_PREFIX (e.g. debian lenny 5.0.7's cmake 2.6)
$(D)/openthreads: $(SVN_TP_LIBS)/OpenThreads-svn | $(TARGETPREFIX)
	opkg-chksvn.sh $(CONTROL_DIR)/libOpenThreads $(SVN_TP_LIBS)/OpenThreads-svn
	tar -C $(SVN_TP_LIBS) -cp OpenThreads-svn --exclude=.svn | tar -C $(BUILD_TMP) -x
	set -e; cd $(BUILD_TMP)/OpenThreads-svn; \
		rm CMakeFiles/* -rf CMakeCache.txt cmake_install.cmake; \
		cmake . -DCMAKE_BUILD_TYPE=Release -DCMAKE_SYSTEM_NAME="Linux" \
			-DCMAKE_INSTALL_PREFIX="" \
			-DCMAKE_C_COMPILER="$(TARGET)-gcc" \
			-DCMAKE_CXX_COMPILER="$(TARGET)-g++" \
			-D_OPENTHREADS_ATOMIC_USE_GCC_BUILTINS_EXITCODE=1; \
		find . -name cmake_install.cmake -print0 | xargs -0 \
			sed -i 's@SET(CMAKE_INSTALL_PREFIX "/usr/local")@SET(CMAKE_INSTALL_PREFIX "")@'; \
		$(MAKE); \
		make install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/openthreads.pc
	$(REMOVE)/OpenThreads-svn $(PKGPREFIX)
	mkdir -p $(PKGPREFIX)/lib
	cp -a $(TARGETPREFIX)/lib/libOpenThreads.so.* $(PKGPREFIX)/lib
	$(OPKG_SH) $(CONTROL_DIR)/libOpenThreads
	rm -rf $(PKGPREFIX)
	touch $@

$(D)/libvorbisidec: $(ARCHIVE)/libvorbisidec_$(VORBISIDEC-VER)$(VORBISIDEC-VER_APPEND).tar.gz
	$(UNTAR)/libvorbisidec_$(VORBISIDEC-VER)$(VORBISIDEC-VER_APPEND).tar.gz
	set -e; cd $(BUILD_TMP)/libvorbisidec-$(VORBISIDEC-VER); \
		patch -p1 < $(PATCHES)/tremor.diff; \
		./autogen.sh; \
		$(CONFIGURE) --prefix= --build=$(BUILD) --host=$(TARGET); \
		make all; \
		perl -pi -e "s,^prefix=.*$$,prefix=$(TARGETPREFIX)," vorbisidec.pc; \
		make install DESTDIR=$(TARGETPREFIX); \
		install -m644 vorbisidec.pc $(TARGETPREFIX)/lib/pkgconfig
	$(REMOVE)/libvorbisidec-$(VORBISIDEC-VER) $(PKGPREFIX)
	$(REWRITE_LIBTOOL)/libvorbisidec.la
	mkdir -p $(PKGPREFIX)/lib
	cp -a $(TARGETPREFIX)/lib/libvorbisidec.so.1* $(PKGPREFIX)/lib
	$(OPKG_SH) $(CONTROL_DIR)/libvorbisidec
	rm -rf $(PKGPREFIX)
	touch $@

$(D)/fuse: $(ARCHIVE)/fuse-$(FUSE-VER).tar.gz | $(TARGETPREFIX)
	rm -rf $(PKGPREFIX)
	$(UNTAR)/fuse-$(FUSE-VER).tar.gz
	set -e; cd $(BUILD_TMP)/fuse-$(FUSE-VER); \
		$(CONFIGURE) --prefix= ; \
		$(MAKE) all; \
		make install DESTDIR=$(TARGETPREFIX) ;\
		make install DESTDIR=$(PKGPREFIX)
	$(REWRITE_LIBTOOL)/libfuse.la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/fuse.pc
	set -e; cd $(PKGPREFIX); \
		rm -rf dev etc lib/pkgconfig include; \
		rm lib/*.so lib/*.la lib/*.a
	install -m 755 -D $(SCRIPTS)/load-fuse.init \
		$(PKGPREFIX)/etc/init.d/load-fuse
	ln -s load-fuse $(PKGPREFIX)/etc/init.d/S56load-fuse
	PKG_VER=$(FUSE-VER) $(OPKG_SH) $(CONTROL_DIR)/fuse
	$(REMOVE)/fuse-$(FUSE-VER) $(PKGPREFIX)
	touch $@

# build only static lib - just needed by tcpdump
$(D)/libpcap: $(ARCHIVE)/libpcap-$(PCAP-VER).tar.gz
	rm -rf $(PKGPREFIX)
	$(UNTAR)/libpcap-$(PCAP-VER).tar.gz
	set -e; cd $(BUILD_TMP)/libpcap-$(PCAP-VER); \
		echo "ac_cv_linux_vers=2" >> config.cache; \
		$(CONFIGURE) --with-pcap=linux --prefix= --mandir=/.remove -C; \
		$(MAKE) all ; \
		make install DESTDIR=$(TARGETPREFIX); \
		: make install DESTDIR=$(PKGPREFIX)
	rm -rf $(TARGETPREFIX)/.remove $(PKGPREFIX)/.remove \
		$(PKGPREFIX)/bin $(PKGPREFIX)/include $(PKGPREFIX)/lib/*.a
	rm -rf $(TARGETPREFIX)/lib/libpcap.s*
	$(REMOVE)/libpcap-$(PCAP-VER)
	touch $@

#############################################################################################
#############################################################################################
######### not yet needed and not tested #####################################################
#############################################################################################
#############################################################################################

# builds only static lib, needed e.g. by unfsd
$(D)/libflex: $(ARCHIVE)/flex-$(FLEX-VER).tar.gz
	$(UNTAR)/flex-$(FLEX-VER).tar.gz
	set -e; cd $(BUILD_TMP)/flex-$(FLEX-VER); \
		echo "ac_cv_func_malloc_0_nonnull=yes" > config.cache; \
		echo "ac_cv_func_realloc_0_nonnull=yes" >> config.cache; \
		$(CONFIGURE) -C --host=$(TARGET) --target=$(TARGET) --prefix= --bindir=/.remove --mandir=/.remove --infodir=/.remove --disable-nls; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	rm -fr $(TARGETPREFIX)/.remove
	$(REMOVE)/flex-$(FLEX-VER)
	touch $@

$(D)/libexpat: $(ARCHIVE)/expat-$(EXPAT-VER).tar.gz
	$(UNTAR)/expat-$(EXPAT-VER).tar.gz
	set -e; cd $(BUILD_TMP)/expat-$(EXPAT-VER); \
		$(CONFIGURE) -C --host=$(TARGET) --target=$(TARGET) --prefix= --bindir=/.remove --mandir=/.remove --infodir=/.remove --disable-nls; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	rm -fr $(TARGETPREFIX)/.remove
	$(REWRITE_LIBTOOL)/libexpat.la
	$(REMOVE)/expat-$(EXPAT-VER)
	touch $@


# !!! libcap != libpcap !!!
# only the libs will be installed!
$(D)/libcap: $(ARCHIVE)/libcap-$(LIBCAP2-VER).tar.gz $(D)/libattr1
	$(UNTAR)/libcap-$(LIBCAP2-VER).tar.gz
	set -e; cd $(BUILD_TMP)/libcap-$(LIBCAP2-VER); \
		patch -p1 < $(PATCHES)/libcap-$(LIBCAP2-VER).patch;\
		CROSS_BASE=$(CROSS_BASE) TARGET=$(TARGET) TARGETPREFIX=$(TARGETPREFIX)\
		$(MAKE);\
		$(MAKE) -C libcap INCDIR=$(TARGETPREFIX)/include LIBDIR=$(TARGETPREFIX)/lib  install
	$(REMOVE)/libcap-$(LIBCAP2-VER)
	touch $@

$(D)/libattr1: $(ARCHIVE)/attr-$(ATTR-VER).src.tar.gz
	$(UNTAR)/attr-$(ATTR-VER).src.tar.gz
	set -e; cd $(BUILD_TMP)/attr-$(ATTR-VER); \
		$(CONFIGURE) \
			--prefix= \
			--enable-gettext=no \
			--mandir=/.remove \
			--datadir=/.remove; \
		$(MAKE); \
		make install-lib install-dev DIST_ROOT=$(TARGETPREFIX)
	$(REMOVE)/attr-$(ATTR-VER) $(TARGETPREFIX)/.remove
	rm $(TARGETPREFIX)/lib/libattr.*a $(TARGETPREFIX)/libexec/libattr.so
	mv $(TARGETPREFIX)/libexec/libattr* $(TARGETPREFIX)/lib/
	$(REWRITE_LIBTOOL)/libattr.la
	touch $@

PHONY += ncurses-prereq
