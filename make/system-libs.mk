#Makefile to build system libs, potentially needed by neutrino and enigma

$(DEPDIR)/zlib: $(ARCHIVE)/zlib-1.2.3.tar.bz2
	$(UNTAR)/zlib-1.2.3.tar.bz2
	cd $(BUILD_TMP)/zlib-1.2.3 && \
		CC=$(TARGET)-gcc ./configure --prefix= --shared && \
		make && \
		ln -sf /bin/true ldconfig && \
		PATH=$(BUILD_TMP)/zlib-1.2.3:$(PATH) make install prefix=$(TARGETPREFIX)
	$(REMOVE)/zlib-1.2.3
	touch $@

$(DEPDIR)/libmad: $(ARCHIVE)/libmad-0.15.1b.tar.gz
	$(UNTAR)/libmad-0.15.1b.tar.gz
	pushd $(BUILD_TMP)/libmad-0.15.1b && \
		patch -p1 < $(PATCHES)/libmad.diff && \
		patch -p1 < $(PATCHES)/libmad-0.15.1b-arm-buildfix.diff && \
		./configure --prefix= --build=$(BUILD) --host=$(TARGET) --enable-shared=yes --enable-speed --enable-fpm=arm --enable-sso && \
		make all && \
		make install DESTDIR=$(TARGETPREFIX) && \
		sed "s!^prefix=.*!prefix=$(TARGETPREFIX)!;" mad.pc > $(PKG_CONFIG_PATH)/libmad.pc
	$(REWRITE_LIBTOOL)/libmad.la
	$(REMOVE)/libmad-0.15.1b
	touch $@

$(DEPDIR)/libid3tag: zlib $(ARCHIVE)/libid3tag-0.15.1b.tar.gz
	$(UNTAR)/libid3tag-0.15.1b.tar.gz
	pushd $(BUILD_TMP)/libid3tag-0.15.1b && \
		patch -p1 < $(PATCHES)/libid3tag.diff && \
		$(CONFIGURE) --prefix= --build=$(BUILD) --host=$(TARGET) --enable-shared=yes && \
		make all && \
		make install DESTDIR=$(TARGETPREFIX) && \
		sed "s!^prefix=.*!prefix=$(TARGETPREFIX)!;" id3tag.pc > $(PKG_CONFIG_PATH)/libid3tag.pc
	$(REMOVE)/libid3tag-0.15.1b
	$(REWRITE_LIBTOOL)/libid3tag.la
	touch $@

$(DEPDIR)/libungif: $(ARCHIVE)/libungif-4.1.3.tar.bz2
	$(UNTAR)/libungif-4.1.3.tar.bz2
	pushd $(BUILD_TMP)/libungif-4.1.3 && \
		$(CONFIGURE) --prefix= --build=$(BUILD) --host=$(TARGET) --without-x --bindir=/.remove && \
		make all && \
		make install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_LIBTOOL)/libungif.la
	rm -rf $(TARGETPREFIX)/.remove
	$(REMOVE)/libungif-4.1.3
	touch $@

$(DEPDIR)/libcurl: $(ARCHIVE)/curl-7.19.7.tar.bz2
	$(UNTAR)/curl-7.19.7.tar.bz2
	pushd $(BUILD_TMP)/curl-7.19.7 && \
		$(CONFIGURE) --prefix= --build=$(BUILD) --host=$(TARGET) --with-random --mandir=/.remove && \
		make all && \
		mkdir -p $(HOSTPREFIX)/bin && \
		sed -e "s,^prefix=,prefix=$(TARGETPREFIX)," < curl-config > $(HOSTPREFIX)/bin/curl-config && \
		chmod 755 $(HOSTPREFIX)/bin/curl-config && \
		make install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_LIBTOOL)/libcurl.la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libcurl.pc
	rm -rf $(TARGETPREFIX)/.remove
	$(REMOVE)/curl-7.19.7
	touch $@

$(DEPDIR)/libpng: $(ARCHIVE)/libpng-1.2.40.tar.bz2
	$(UNTAR)/libpng-1.2.40.tar.bz2
	pushd $(BUILD_TMP)/libpng-1.2.40 && \
		$(CONFIGURE) --prefix=$(TARGETPREFIX) --build=$(BUILD) --host=$(TARGET) --bindir=$(HOSTPREFIX)/bin --mandir=$(BUILD_TMP)/tmpman && \
		ECHO=echo make all && \
		make install
	$(REMOVE)/libpng-1.2.40 $(BUILD_TMP)/tmpman
	touch $@

$(DEPDIR)/freetype: libpng $(ARCHIVE)/freetype-2.3.9.tar.bz2
	$(UNTAR)/freetype-2.3.9.tar.bz2
	pushd $(BUILD_TMP)/freetype-2.3.9 && \
		patch -p1 < $(PATCHES)/freetype-2.3.9-coolstream.diff && \
		$(CONFIGURE) --prefix= --build=$(BUILD) --host=$(TARGET) && \
		make all && \
		sed -e "s,^prefix=,prefix=$(TARGETPREFIX)," < builds/unix/freetype-config > $(HOSTPREFIX)/bin/freetype-config && \
		chmod 755 $(HOSTPREFIX)/bin/freetype-config && \
		make install libdir=$(TARGETPREFIX)/lib includedir=$(TARGETPREFIX)/include bindir=$(TARGETPREFIX)/bin prefix=$(TARGETPREFIX)
	$(REWRITE_LIBTOOL)/libfreetype.la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/freetype2.pc
	$(REMOVE)/freetype-2.3.9
	touch $@

$(DEPDIR)/libjpeg: $(ARCHIVE)/jpegsrc.v6b.tar.gz
	$(UNTAR)/jpegsrc.v6b.tar.gz
	pushd $(BUILD_TMP) && \
		pushd jpeg-6b && \
		export CC=$(TARGET)-gcc && \
		$(CONFIGURE) --prefix= --build=$(BUILD) --host=$(TARGET) --enable-shared && \
		./ltconfig --no-verify ltmain.sh $(BUILD) && \
		make  && \
		make install-lib libdir=$(TARGETPREFIX)/lib includedir=$(TARGETPREFIX)/include
	$(REWRITE_LIBTOOL)/libjpeg.la
	$(REMOVE)/jpeg-6b
	touch $@

$(DEPDIR)/libboost: $(ARCHIVE)/boost_1_40_0.tar.bz2
	pushd $(BUILD_TMP) && \
		tar xf $(ARCHIVE)/boost_1_40_0.tar.bz2 boost_1_40_0/boost && \
		rm -rf $(TARGETPREFIX)/include/boost &&\
		mv boost_1_40_0/boost $(TARGETPREFIX)/include/boost && \
		rmdir boost_1_40_0
	touch $@

$(DEPDIR)/openssl: $(ARCHIVE)/openssl-0.9.8l.tar.gz
	$(UNTAR)/openssl-0.9.8l.tar.gz
	pushd $(BUILD_TMP)/openssl-0.9.8l && \
		CC=$(TARGET)-gcc \
		./Configure shared no-hw no-engine linux-generic32 --prefix=/ --openssldir=/.remove && \
		$(MAKE) depend && \
		$(MAKE) all && \
		$(MAKE) install_sw INSTALL_PREFIX=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/openssl.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libcrypto.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libssl.pc
	rm -r $(TARGETPREFIX)/.remove $(TARGETPREFIX)/bin/openssl $(TARGETPREFIX)/bin/c_rehash
	$(REMOVE)/openssl-0.9.8l
	chmod 0755 $(TARGETPREFIX)/lib/libcrypto.so.* $(TARGETPREFIX)/lib/libssl.so.*
	touch $@

$(DEPDIR)/ffmpeg-0.5: $(ARCHIVE)/ffmpeg-0.5.tar.bz2
	$(UNTAR)/ffmpeg-0.5.tar.bz2
	pushd $(BUILD_TMP)/ffmpeg-0.5 && \
		$(PATCH)/ffmpeg-export-missing-symbol.diff && \
		CFLAGS=-march=armv6 \
		./configure \
			--enable-parsers --disable-decoders --disable-encoders --enable-demuxers \
			--disable-muxers --disable-ffplay --disable-ffmpeg --disable-ffserver \
			--enable-decoder=h263 --enable-decoder=h264 --enable-decoder=mpeg4video \
			--enable-decoder=vc1 --enable-decoder=mpegvideo --enable-decoder=mpegaudio \
			--enable-decoder=aac --enable-decoder=dca --enable-decoder=ac3 \
			--enable-demuxer=mpegps \
			--disable-devices --disable-mmx --disable-altivec --disable-iwmmxt   \
			--disable-protocols --enable-protocol=file --enable-bsfs \
			--disable-mpegaudio-hp --disable-zlib --enable-bzlib \
			--disable-network --disable-ipv6 \
			--disable-static --enable-shared \
			--disable-vhook \
			--enable-cross-compile \
			--cross-prefix=$(TARGET)- \
			--enable-armv6 --arch=arm \
			--enable-debug --enable-stripping \
			--prefix=/ && \
		$(MAKE) && \
		make install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libavdevice.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libavformat.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libavcodec.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libavutil.pc
	$(REMOVE)/ffmpeg-0.5
	touch $@

# maybe put this into archive.mk?
$(BUILD_TMP)/ffmpeg:
	svn checkout svn://svn.ffmpeg.org/ffmpeg/trunk $(BUILD_TMP)/ffmpeg

$(DEPDIR)/ffmpeg: $(BUILD_TMP)/ffmpeg
	pushd $(BUILD_TMP)/ffmpeg && \
		CFLAGS=-march=armv6 \
		./configure \
			--enable-parsers --disable-decoders --disable-encoders --enable-demuxers \
			--disable-muxers --disable-ffplay --disable-ffmpeg --disable-ffserver \
			--enable-decoder=h263 --enable-decoder=h264 --enable-decoder=mpeg4video \
			--enable-decoder=vc1 --enable-decoder=mpegvideo --enable-decoder=mpegaudio \
			--enable-decoder=aac --enable-decoder=dca --enable-decoder=ac3 \
			--enable-demuxer=mpegps \
			--disable-devices --disable-mmx --disable-altivec --disable-iwmmxt   \
			--disable-protocols --enable-protocol=file --enable-bsfs \
			--disable-mpegaudio-hp --disable-zlib --enable-bzlib \
			--disable-network --disable-ipv6 \
			--disable-static --enable-shared \
			--enable-cross-compile \
			--cross-prefix=$(TARGET)- \
			--enable-armv6 --arch=arm \
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

$(DEPDIR)/libogg: $(ARCHIVE)/libogg-1.1.4.tar.gz
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
$(DEPDIR)/libvorbis: libogg $(ARCHIVE)/libvorbis-1.2.3.tar.bz2
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
	@if type -p tic && type -p infocmp ; then \
		true; \
	else \
		echo "**********************************************************"; \
		echo "* tic or infocmp missing, but needed to build libncurses *"; \
		echo "* install the ncurses development package on your system *"; \
		echo "**********************************************************"; \
		false; \
	fi

$(DEPDIR)/libncurses: $(ARCHIVE)/ncurses-5.6.tar.gz ncurses-prereq
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

$(DEPDIR)/libiconv: $(ARCHIVE)/libiconv-1.13.tar.gz
	$(UNTAR)/libiconv-1.13.tar.gz
	pushd $(BUILD_TMP)/libiconv-1.13 && \
		$(CONFIGURE) --build=$(BUILD) --host=$(TARGET) --target=$(TARGET) --prefix= --datarootdir=/.remove && \
		$(MAKE) && \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	rm -fr $(TARGETPREFIX)/.remove
	$(REMOVE)/libiconv-1.13
	touch $@

#############################################################################################
#############################################################################################
######### not yet needed and not tested #####################################################
#############################################################################################
#############################################################################################
$(DEPDIR)/libvorbisidec: $(ARCHIVE)/libvorbisidec_1.0.2+svn14261.orig.tar.gz
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

$(DEPDIR)/libpcap: $(ARCHIVE)/libpcap-1.0.0.tar.gz
	$(UNTAR)/libpcap-1.0.0.tar.gz
	pushd $(BUILD_TMP)/libpcap-1.0.0 && \
		echo "ac_cv_linux_vers=2" >> config.cache && \
		$(CONFIGURE) --with-pcap=linux --prefix= --cache-file=config.cache && \
		make all && \
		make install DESTDIR=$(TARGETPREFIX)
	$(REMOVE)/libpcap-1.0.0
	touch $@

