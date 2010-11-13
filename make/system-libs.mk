#Makefile to build system libs, potentially needed by neutrino and enigma

$(D)/zlib: $(ARCHIVE)/zlib-1.2.5.tar.bz2 | $(TARGETPREFIX)
	$(UNTAR)/zlib-1.2.5.tar.bz2
	cd $(BUILD_TMP)/zlib-1.2.5 && \
		CC=$(TARGET)-gcc mandir=$(BUILD_TMP)/.remove ./configure --prefix= --shared && \
		$(MAKE) && \
		ln -sf /bin/true ldconfig && \
		PATH=$(BUILD_TMP)/zlib-1.2.5:$(PATH) make install prefix=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/zlib.pc
	$(REMOVE)/zlib-1.2.5
	$(REMOVE)/.remove
	touch $@

$(D)/libblkid: $(D)/libuuid
$(D)/libuuid: $(ARCHIVE)/util-linux-ng-2.18.tar.bz2 | $(TARGETPREFIX)
	$(UNTAR)/util-linux-ng-2.18.tar.bz2
	cd $(BUILD_TMP)/util-linux-ng-2.18 && \
		./configure --prefix= --build=$(BUILD) --host=$(TARGET) \
			--disable-libmount \
			--mandir=/.remove && \
		$(MAKE) -C shlibs && \
		$(MAKE) -C shlibs install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/uuid.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/blkid.pc
	rm -rf $(TARGETPREFIX)/.remove
	$(REMOVE)/util-linux-ng-2.18
	touch $(D)/libuuid $(D)/libblkid

$(D)/libmad: $(ARCHIVE)/libmad-0.15.1b.tar.gz | $(TARGETPREFIX)
	$(UNTAR)/libmad-0.15.1b.tar.gz
	pushd $(BUILD_TMP)/libmad-0.15.1b && \
		patch -p1 < $(PATCHES)/libmad.diff && \
		patch -p1 < $(PATCHES)/libmad-0.15.1b-arm-buildfix.diff && \
		./configure --prefix= --build=$(BUILD) --host=$(TARGET) --enable-shared=yes --enable-speed --enable-fpm=arm --enable-sso && \
		$(MAKE) all && \
		make install DESTDIR=$(TARGETPREFIX) && \
		sed "s!^prefix=.*!prefix=$(TARGETPREFIX)!;" mad.pc > $(PKG_CONFIG_PATH)/libmad.pc
	$(REWRITE_LIBTOOL)/libmad.la
	$(REMOVE)/libmad-0.15.1b
	touch $@

$(D)/libid3tag: $(D)/zlib $(ARCHIVE)/libid3tag-0.15.1b.tar.gz | $(TARGETPREFIX)
	$(UNTAR)/libid3tag-0.15.1b.tar.gz
	pushd $(BUILD_TMP)/libid3tag-0.15.1b && \
		patch -p1 < $(PATCHES)/libid3tag.diff && \
		$(CONFIGURE) --prefix= --build=$(BUILD) --host=$(TARGET) --enable-shared=yes && \
		$(MAKE) all && \
		make install DESTDIR=$(TARGETPREFIX) && \
		sed "s!^prefix=.*!prefix=$(TARGETPREFIX)!;" id3tag.pc > $(PKG_CONFIG_PATH)/libid3tag.pc
	$(REMOVE)/libid3tag-0.15.1b
	$(REWRITE_LIBTOOL)/libid3tag.la
	touch $@

$(D)/libungif: $(ARCHIVE)/libungif-4.1.4.tar.bz2 | $(TARGETPREFIX)
	$(UNTAR)/libungif-4.1.4.tar.bz2
	pushd $(BUILD_TMP)/libungif-4.1.4 && \
		$(CONFIGURE) --prefix= --build=$(BUILD) --host=$(TARGET) --without-x --bindir=/.remove && \
		$(MAKE) all && \
		make install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_LIBTOOL)/libungif.la
	rm -rf $(TARGETPREFIX)/.remove
	$(REMOVE)/libungif-4.1.4
	touch $@

$(D)/libcurl: $(ARCHIVE)/curl-7.20.0.tar.bz2 | $(TARGETPREFIX)
	$(UNTAR)/curl-7.20.0.tar.bz2
	pushd $(BUILD_TMP)/curl-7.20.0 && \
		$(CONFIGURE) --prefix= --build=$(BUILD) --host=$(TARGET) --with-random --mandir=/.remove && \
		$(MAKE) all && \
		mkdir -p $(HOSTPREFIX)/bin && \
		sed -e "s,^prefix=,prefix=$(TARGETPREFIX)," < curl-config > $(HOSTPREFIX)/bin/curl-config && \
		chmod 755 $(HOSTPREFIX)/bin/curl-config && \
		make install DESTDIR=$(TARGETPREFIX)
	rm $(TARGETPREFIX)/bin/curl-config
	$(REWRITE_LIBTOOL)/libcurl.la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libcurl.pc
	rm -rf $(TARGETPREFIX)/.remove
	$(REMOVE)/curl-7.20.0
	touch $@

$(D)/libpng: $(ARCHIVE)/libpng-1.2.44.tar.bz2 $(D)/zlib | $(TARGETPREFIX)
	$(UNTAR)/libpng-1.2.44.tar.bz2
	pushd $(BUILD_TMP)/libpng-1.2.44 && \
		$(CONFIGURE) --prefix=$(TARGETPREFIX) --build=$(BUILD) --host=$(TARGET) --bindir=$(HOSTPREFIX)/bin --mandir=$(BUILD_TMP)/tmpman && \
		ECHO=echo $(MAKE) all && \
		make install
	$(REMOVE)/libpng-1.2.44 $(BUILD_TMP)/tmpman
	touch $@

$(D)/freetype: $(D)/libpng $(ARCHIVE)/freetype-2.3.12.tar.bz2 | $(TARGETPREFIX)
	$(UNTAR)/freetype-2.3.12.tar.bz2
	pushd $(BUILD_TMP)/freetype-2.3.12 && \
		patch -p1 < $(PATCHES)/freetype-2.3.9-coolstream.diff && \
		$(CONFIGURE) --prefix= --build=$(BUILD) --host=$(TARGET) && \
		$(MAKE) all && \
		sed -e "s,^prefix=,prefix=$(TARGETPREFIX)," < builds/unix/freetype-config > $(HOSTPREFIX)/bin/freetype-config && \
		chmod 755 $(HOSTPREFIX)/bin/freetype-config && \
		make install libdir=$(TARGETPREFIX)/lib includedir=$(TARGETPREFIX)/include bindir=$(TARGETPREFIX)/bin prefix=$(TARGETPREFIX)
	rm $(TARGETPREFIX)/bin/freetype-config
	$(REWRITE_LIBTOOL)/libfreetype.la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/freetype2.pc
	$(REMOVE)/freetype-2.3.12
	touch $@

$(D)/libjpeg: $(ARCHIVE)/jpegsrc.v6b.tar.gz | $(TARGETPREFIX)
	$(UNTAR)/jpegsrc.v6b.tar.gz
	pushd $(BUILD_TMP) && \
		pushd jpeg-6b && \
		export CC=$(TARGET)-gcc && \
		$(CONFIGURE) --prefix= --build=$(BUILD) --host=$(TARGET) --enable-shared && \
		./ltconfig --no-verify ltmain.sh $(BUILD) && \
		$(MAKE)  && \
		make install-lib libdir=$(TARGETPREFIX)/lib includedir=$(TARGETPREFIX)/include
	$(REWRITE_LIBTOOL)/libjpeg.la
	$(REMOVE)/jpeg-6b
	touch $@

$(D)/libboost: $(ARCHIVE)/boost_1_42_0.tar.bz2 | $(TARGETPREFIX)
	pushd $(BUILD_TMP) && \
		tar xf $(ARCHIVE)/boost_1_42_0.tar.bz2 boost_1_42_0/boost && \
		rm -rf $(TARGETPREFIX)/include/boost &&\
		mv boost_1_42_0/boost $(TARGETPREFIX)/include/boost && \
		rmdir boost_1_42_0
	touch $@

# openssl seems to have problem with parallel builds, so use "make" instead of "$(MAKE)"
$(D)/openssl: $(ARCHIVE)/openssl-0.9.8m.tar.gz | $(TARGETPREFIX)
	$(UNTAR)/openssl-0.9.8m.tar.gz
	pushd $(BUILD_TMP)/openssl-0.9.8m && \
		CC=$(TARGET)-gcc \
		./Configure shared no-hw no-engine linux-generic32 --prefix=/ --openssldir=/.remove && \
		make depend && \
		make all && \
		make install_sw INSTALL_PREFIX=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/openssl.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libcrypto.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libssl.pc
	rm -r $(TARGETPREFIX)/.remove $(TARGETPREFIX)/bin/openssl $(TARGETPREFIX)/bin/c_rehash
	$(REMOVE)/openssl-0.9.8m
	chmod 0755 $(TARGETPREFIX)/lib/libcrypto.so.* $(TARGETPREFIX)/lib/libssl.so.*
	touch $@

$(D)/ffmpeg: $(ARCHIVE)/ffmpeg-0.6.tar.bz2 | $(TARGETPREFIX)
	$(UNTAR)/ffmpeg-0.6.tar.bz2
	cd $(BUILD_TMP)/ffmpeg-0.6 && \
		$(PATCH)/ffmpeg-dvbsubs.diff && \
		$(PATCH)/ffmpeg-0.6-avoid-UINT64_C.diff && \
		CFLAGS=-march=armv6 \
		./configure \
			--enable-parsers --disable-decoders --disable-encoders --enable-demuxers \
			--disable-muxers --disable-ffplay --disable-ffmpeg --disable-ffserver \
			--enable-decoder=h263 --enable-decoder=h264 --enable-decoder=mpeg4video \
			--enable-decoder=vc1 --enable-decoder=mpegvideo --enable-decoder=mpegaudio \
			--enable-decoder=aac --enable-decoder=dca --enable-decoder=ac3 \
			--enable-decoder=dvbsub --enable-decoder=iff_byterun1 --enable-demuxer=mpegps \
			--disable-devices --disable-mmx --disable-altivec --disable-iwmmxt   \
			--disable-protocols --enable-protocol=file --enable-bsfs \
			--disable-mpegaudio-hp --disable-zlib --enable-bzlib \
			--disable-network --disable-swscale --disable-ffprobe \
			--disable-static --enable-shared \
			--enable-cross-compile \
			--cross-prefix=$(TARGET)- \
			--enable-armv6 --arch=arm --target-os=linux \
			--enable-debug --enable-stripping \
			--prefix=/ && \
		$(MAKE) && \
		make install DESTDIR=$(TARGETPREFIX) && \
		cp version.h $(TARGETPREFIX)/lib/ffmpeg-version.h
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libavdevice.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libavformat.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libavcodec.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libavutil.pc
	$(REMOVE)/ffmpeg-0.6
	touch $@

# maybe put this into archive.mk?
$(BUILD_TMP)/ffmpeg:
	svn checkout -r 22733 svn://svn.ffmpeg.org/ffmpeg/trunk $(BUILD_TMP)/ffmpeg
	svn up -r 30474 $(BUILD_TMP)/ffmpeg/libswscale/
	cd $(BUILD_TMP)/ffmpeg && $(PATCH)/ffmpeg-dvbsubs.diff

$(D)/ffmpeg-snapshot: $(BUILD_TMP)/ffmpeg | $(TARGETPREFIX)
	pushd $(BUILD_TMP)/ffmpeg && \
		CFLAGS=-march=armv6 \
		./configure \
			--enable-parsers --disable-decoders --disable-encoders --enable-demuxers \
			--disable-muxers --disable-ffplay --disable-ffmpeg --disable-ffserver \
			--enable-decoder=h263 --enable-decoder=h264 --enable-decoder=mpeg4video \
			--enable-decoder=vc1 --enable-decoder=mpegvideo --enable-decoder=mpegaudio \
			--enable-decoder=aac --enable-decoder=dca --enable-decoder=ac3 \
			--enable-decoder=dvbsub --enable-decoder=iff_byterun1 --enable-demuxer=mpegps \
			--disable-devices --disable-mmx --disable-altivec --disable-iwmmxt   \
			--disable-protocols --enable-protocol=file --enable-bsfs \
			--disable-mpegaudio-hp --disable-zlib --enable-bzlib \
			--disable-network --disable-swscale --disable-ffprobe \
			--disable-static --enable-shared \
			--enable-cross-compile \
			--cross-prefix=$(TARGET)- \
			--enable-armv6 --arch=arm --target-os=linux \
			--enable-debug --enable-stripping \
			--prefix=/ && \
		$(MAKE) && \
		make install DESTDIR=$(TARGETPREFIX) && \
		./version.sh . $(TARGETPREFIX)/lib/ffmpeg-version.h
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libavdevice.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libavformat.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libavcodec.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libavutil.pc
	# don't check out everything every time...
	# $(REMOVE)/ffmpeg
	touch $@

$(D)/libogg: $(ARCHIVE)/libogg-1.1.4.tar.gz | $(TARGETPREFIX)
	$(UNTAR)/libogg-1.1.4.tar.gz
	pushd $(BUILD_TMP)/libogg-1.1.4 && \
		patch -p1 < $(PATCHES)/libogg-1.1.4-nodoc.diff && \
		$(CONFIGURE) --prefix= --enable-shared && \
		$(MAKE) && \
		make install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/ogg.pc
	$(REWRITE_LIBTOOL)/libogg.la
	$(REMOVE)/libogg-1.1.4
	touch $@

# for some reason, libvorbis does not work with "--prefix=/"
$(D)/libvorbis: $(D)/libogg $(ARCHIVE)/libvorbis-1.2.3.tar.bz2 | $(TARGETPREFIX)
	$(UNTAR)/libvorbis-1.2.3.tar.bz2
	pushd $(BUILD_TMP)/libvorbis-1.2.3 && \
		patch -p1 < $(PATCHES)/libvorbis-1.2.3-nodoc.diff && \
		patch -p1 < $(PATCHES)/libvorbis-1.2.3-smaller-chunksize.diff && \
		$(CONFIGURE) --enable-shared --prefix=$(TARGETPREFIX) LDFLAGS="-Wl,-rpath-link,$(TARGETLIB)" && \
		$(MAKE) && \
		make install
	# $(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libvorbis.pc
	# $(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libvorbisenc.pc
	# $(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libvorbisfile.pc
	$(REMOVE)/libvorbis-1.2.3
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

$(D)/libncurses: $(ARCHIVE)/ncurses-5.6.tar.gz | ncurses-prereq $(TARGETPREFIX)
	$(UNTAR)/ncurses-5.6.tar.gz && \
	pushd $(BUILD_TMP)/ncurses-5.6 && \
		$(CONFIGURE) --build=$(BUILD) --host=$(TARGET) --target=$(TARGET) \
			--prefix= --with-terminfo-dirs=/usr/share/terminfo \
			--disable-big-core --without-debug --without-progs --without-ada --with-shared \
			--without-profile --disable-rpath --without-cxx-binding \
			--with-fallbacks='linux vt100 xterm' && \
		$(MAKE) libs HOSTCC=gcc HOSTLDFLAGS="$(TARGET_LDFLAGS)" \
			HOSTCCFLAGS="$(TARGET_CFLAGS) -DHAVE_CONFIG_H -I../ncurses -DNDEBUG -D_GNU_SOURCE -I../include" && \
		make install.libs DESTDIR=$(TARGETPREFIX)
	$(REMOVE)/ncurses-5.6
	touch $@

$(D)/libiconv: $(ARCHIVE)/libiconv-1.13.1.tar.gz | $(TARGETPREFIX)
	$(UNTAR)/libiconv-1.13.1.tar.gz
	pushd $(BUILD_TMP)/libiconv-1.13.1 && \
		$(CONFIGURE) --build=$(BUILD) --host=$(TARGET) --target=$(TARGET) --prefix= --datarootdir=/.remove && \
		$(MAKE) && \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	rm -fr $(TARGETPREFIX)/.remove
	$(REMOVE)/libiconv-1.13.1
	touch $@

$(D)/directfb: $(ARCHIVE)/DirectFB-1.4.3.tar.gz | $(TARGETPREFIX)
	$(UNTAR)/DirectFB-1.4.3.tar.gz
	cd $(BUILD_TMP)/DirectFB-1.4.3 && \
		patch -p2 -i $(PATCHES)/coolstream/directfb-1.4.3-coolstream.diff && \
		$(CONFIGURE) --prefix=/ --mandir=/.remove --bindir=/bin/directfb \
			--build=$(BUILD) --host=$(TARGET) \
			--with-inputdrivers=linuxinput --with-gfxdrivers=cx2450x --disable-video4linux \
			--disable-video4linux2 --enable-zlib --disable-x11 --disable-osx --disable-vnc \
			--enable-debug --disable-network --disable-devmem --disable-sysfs --enable-fbdev \
			--enable-jpeg --with-tests && \
		$(MAKE) && \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	rm -fr $(TARGETPREFIX)/.remove
	$(REMOVE)/DirectFB-1.4.3
	touch $@


#############################################################################################
#############################################################################################
######### not yet needed and not tested #####################################################
#############################################################################################
#############################################################################################
$(D)/libvorbisidec: $(ARCHIVE)/libvorbisidec_1.0.2+svn14261.orig.tar.gz
	$(UNTAR)/libvorbisidec_1.0.2+svn14261.orig.tar.gz
	pushd $(BUILD_TMP)/libvorbisidec-1.0.2+svn14261 && \
		patch -p1 < $(PATCHES)/tremor.diff && \
		./autogen.sh && \
		$(CONFIGURE) --prefix= --build=$(BUILD) --host=$(TARGET) && \
		make all && \
		perl -pi -e "s,^prefix=.*$$,prefix=$(TARGETPREFIX)," vorbisidec.pc && \
		make install DESTDIR=$(TARGETPREFIX) && \
		install -m644 vorbisidec.pc $(TARGETPREFIX)/lib/pkgconfig
	$(REMOVE)/libvorbisidec-1.0.2+svn14261
	touch $@

$(D)/libpcap: $(ARCHIVE)/libpcap-1.0.0.tar.gz
	$(UNTAR)/libpcap-1.0.0.tar.gz
	pushd $(BUILD_TMP)/libpcap-1.0.0 && \
		echo "ac_cv_linux_vers=2" >> config.cache && \
		$(CONFIGURE) --with-pcap=linux --prefix= --cache-file=config.cache && \
		make all && \
		make install DESTDIR=$(TARGETPREFIX)
	$(REMOVE)/libpcap-1.0.0
	touch $@

# builds only static lib, needed e.g. by unfsd
$(D)/libflex: $(ARCHIVE)/flex-2.5.35.tar.gz
	$(UNTAR)/flex-2.5.35.tar.gz
	cd $(BUILD_TMP)/flex-2.5.35 && \
		echo "ac_cv_func_malloc_0_nonnull=yes" > config.cache && \
		echo "ac_cv_func_realloc_0_nonnull=yes" >> config.cache && \
		$(CONFIGURE) -C --host=$(TARGET) --target=$(TARGET) --prefix= --bindir=/.remove --mandir=/.remove --infodir=/.remove --disable-nls && \
		$(MAKE) && \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	rm -fr $(TARGETPREFIX)/.remove
	$(REMOVE)/flex-2.5.35
	touch $@

PHONY += ncurses-prereq
