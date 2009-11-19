#Makefile to build system libs, potentially needed by neutrino and enigma

$(DEPDIR)/zlib:
	tar -C $(BUILD_TMP) -xf $(ARCHIVE)/zlib-1.2.3.tar.bz2
	cd $(BUILD_TMP)/zlib-1.2.3 && \
		CC=$(TARGET)-gcc ./configure --prefix= --shared && \
		make && \
		ln -sf /bin/true ldconfig && \
		PATH=$(BUILD_TMP)/zlib-1.2.3:$(PATH) make install prefix=$(TARGETPREFIX)
	rm -rf $(BUILD_TMP)/zlib-1.2.3
	touch $@

$(DEPDIR)/libmad:
	tar -C $(BUILD_TMP) -xf $(ARCHIVE)/libmad-0.15.1b.tar.gz
	pushd $(BUILD_TMP)/libmad-0.15.1b && \
		patch -p1 < $(PATCHES)/libmad.diff && \
		patch -p1 < $(PATCHES)/libmad-0.15.1b-arm-buildfix.diff && \
		./configure --prefix= --build=$(BUILD) --host=$(TARGET) --enable-shared=yes --enable-speed --enable-fpm=arm --enable-sso && \
		make all && \
		make install DESTDIR=$(TARGETPREFIX) && \
		sed "s!^prefix=.*!prefix=$(TARGETPREFIX)!;" mad.pc > $(PKG_CONFIG_PATH)/libmad.pc
	$(REWRITE_LIBTOOL) $(TARGETPREFIX)/lib/libmad.la
	rm -rf $(BUILD_TMP)/libmad-0.15.1b
	touch $@

$(DEPDIR)/libid3tag: zlib
	tar -C $(BUILD_TMP) -xf $(ARCHIVE)/libid3tag-0.15.1b.tar.gz
	pushd $(BUILD_TMP)/libid3tag-0.15.1b && \
		patch -p1 < $(PATCHES)/libid3tag.diff && \
		$(CONFIGURE) --prefix= --build=$(BUILD) --host=$(TARGET) --enable-shared=yes && \
		make all && \
		make install DESTDIR=$(TARGETPREFIX) && \
		sed "s!^prefix=.*!prefix=$(TARGETPREFIX)!;" id3tag.pc > $(PKG_CONFIG_PATH)/libid3tag.pc
	rm -rf $(BUILD_TMP)/libid3tag-0.15.1b
	$(REWRITE_LIBTOOL) $(TARGETPREFIX)/lib/libid3tag.la
	touch $@

$(DEPDIR)/libungif:
	tar -C $(BUILD_TMP) -xf $(ARCHIVE)/libungif-4.1.3.tar.bz2
	pushd $(BUILD_TMP)/libungif-4.1.3 && \
		$(CONFIGURE) --prefix= --build=$(BUILD) --host=$(TARGET) --without-x --bindir=/.remove && \
		make all && \
		make install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_LIBTOOL) $(TARGETPREFIX)/lib/libungif.la
	rm -rf $(TARGETPREFIX)/.remove
	rm -rf $(BUILD_TMP)/libungif-4.1.3
	touch $@

$(DEPDIR)/libcurl:
	tar -C $(BUILD_TMP) -xf $(ARCHIVE)/curl-7.19.7.tar.bz2
	pushd $(BUILD_TMP)/curl-7.19.7 && \
		$(CONFIGURE) --prefix= --build=$(BUILD) --host=$(TARGET) --with-random --mandir=/.remove && \
		make all && \
		mkdir -p $(HOSTPREFIX)/bin && \
		sed -e "s,^prefix=,prefix=$(TARGETPREFIX)," < curl-config > $(HOSTPREFIX)/bin/curl-config && \
		chmod 755 $(HOSTPREFIX)/bin/curl-config && \
		make install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_LIBTOOL) $(TARGETPREFIX)/lib/libcurl.la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libcurl.pc
	rm -rf $(TARGETPREFIX)/.remove
	rm -rf $(BUILD_TMP)/curl-7.19.7
	touch $@

$(DEPDIR)/libpng:
	tar -C $(BUILD_TMP) -xf $(ARCHIVE)/libpng-1.2.40.tar.bz2
	pushd $(BUILD_TMP)/libpng-1.2.40 && \
		$(CONFIGURE) --prefix=$(TARGETPREFIX) --build=$(BUILD) --host=$(TARGET) --bindir=$(HOSTPREFIX)/bin --mandir=$(BUILD_TMP)/tmpman && \
		ECHO=echo make all && \
		make install
	rm -rf $(BUILD_TMP)/libpng-1.2.40 $(BUILD_TMP)/tmpman
	touch $@

$(DEPDIR)/freetype: libpng
	tar -C $(BUILD_TMP) -xf $(ARCHIVE)/freetype-2.3.9.tar.bz2
	pushd $(BUILD_TMP)/freetype-2.3.9 && \
		$(CONFIGURE) --prefix= --build=$(BUILD) --host=$(TARGET) && \
		make all && \
		sed -e "s,^prefix=,prefix=$(TARGETPREFIX)," < builds/unix/freetype-config > $(HOSTPREFIX)/bin/freetype-config && \
		chmod 755 $(HOSTPREFIX)/bin/freetype-config && \
		make install libdir=$(TARGETPREFIX)/lib includedir=$(TARGETPREFIX)/include bindir=$(TARGETPREFIX)/bin prefix=$(TARGETPREFIX)
	$(REWRITE_LIBTOOL) $(TARGETPREFIX)/lib/libfreetype.la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/freetype2.pc
	rm -rf $(BUILD_TMP)/freetype-2.3.9
	touch $@

$(DEPDIR)/libjpeg:
	tar -C $(BUILD_TMP) -xf $(ARCHIVE)/jpegsrc.v6b.tar.gz
	pushd $(BUILD_TMP) && \
		pushd jpeg-6b && \
		export CC=$(TARGET)-gcc && \
		$(CONFIGURE) --prefix= --build=$(BUILD) --host=$(TARGET) --enable-shared && \
		./ltconfig --no-verify ltmain.sh $(BUILD) && \
		make  && \
		make install-lib libdir=$(TARGETPREFIX)/lib includedir=$(TARGETPREFIX)/include
	$(REWRITE_LIBTOOL) $(TARGETPREFIX)/lib/libjpeg.la
	rm -rf $(BUILD_TMP)/jpeg-6b
	touch $@

$(DEPDIR)/libboost:
	pushd $(BUILD_TMP) && \
		tar xf $(ARCHIVE)/boost_1_40_0.tar.bz2 boost_1_40_0/boost && \
		rm -rf $(TARGETPREFIX)/include/boost &&\
		mv boost_1_40_0/boost $(TARGETPREFIX)/include/boost && \
		rmdir boost_1_40_0
	touch $@

$(DEPDIR)/openssl:
	tar -C $(BUILD_TMP) -xf $(ARCHIVE)/openssl-0.9.8l.tar.gz
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
	rm -rf $(BUILD_TMP)/openssl-0.9.8l
	chmod 0755 $(TARGETPREFIX)/lib/libcrypto.so.* $(TARGETPREFIX)/lib/libssl.so.*
	touch $@

$(DEPDIR)/ffmpeg:
	tar -C $(BUILD_TMP) -xf $(ARCHIVE)/ffmpeg-0.5.tar.bz2
	pushd $(BUILD_TMP)/ffmpeg-0.5 && \
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
		make && \
		make install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libavdevice.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libavformat.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libavcodec.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libavutil.pc
	rm -r $(BUILD_TMP)/ffmpeg-0.5
	touch $@

$(DEPDIR)/libogg:
	tar -C $(BUILD_TMP)/ -xf $(ARCHIVE)/libogg-1.1.4.tar.gz
	pushd $(BUILD_TMP)/libogg-1.1.4 && \
		patch -p1 < $(PATCHES)/libogg-1.1.4-nodoc.diff && \
		$(CONFIGURE) --prefix= --enable-shared && \
		$(MAKE) && \
		make install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/ogg.pc
	rm -rf $(BUILD_TMP)/libogg-1.1.4
	touch $@

# for some reason, libvorbis does not work with "--prefix=/"
$(DEPDIR)/libvorbis: libogg
	tar -C $(BUILD_TMP)/ -xf $(ARCHIVE)/libvorbis-1.2.3.tar.bz2
	pushd $(BUILD_TMP)/libvorbis-1.2.3 && \
		patch -p1 < $(PATCHES)/libvorbis-1.2.3-nodoc.diff && \
		$(CONFIGURE) --enable-shared --prefix=$(TARGETPREFIX) LDFLAGS="-Wl,-rpath-link,$(TARGETLIB)" && \
		$(MAKE) && \
		make install
	# $(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libvorbis.pc
	# $(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libvorbisenc.pc
	# $(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libvorbisfile.pc
	rm -rf $(BUILD_TMP)/libvorbis-1.2.3
	touch $@

#############################################################################################
#############################################################################################
######### not yet needed and not tested #####################################################
#############################################################################################
#############################################################################################
$(DEPDIR)/libncurses:
	pushd $(BUILD_TMP) && \
		tar xpf $(ARCHIVE)/ncurses-5.6.tar.gz && \
		pushd ncurses-5.6 && \
		$(CONFIGURE) --build=$(BUILD) --host=$(TARGET) --target=$(TARGET) --prefix= --with-terminfo-dirs=/share/terminfo \
					--disable-big-core --without-debug --without-progs --without-ada --with-shared \
					--without-profile --disable-rpath --without-cxx-binding \
					--with-fallbacks='linux vt100 xterm' && \
		make libs HOSTCC=gcc HOSTLDFLAGS="$(TARGET_LDFLAGS)" HOSTCCFLAGS="$(TARGET_CFLAGS) -DHAVE_CONFIG_H -I../ncurses -DNDEBUG -D_GNU_SOURCE -I../include" && \
		make install.libs DESTDIR=$(TARGETPREFIX) && \
		$(TARGET)-ar cru $(TARGETPREFIX)/lib/libncurses_pic.a obj_s/*.o && \
		popd && \
		rm -rf ncurses-5.6
	touch $@

$(DEPDIR)/libvorbisidec:
	tar -C $(BUILD_TMP) -xpf $(ARCHIVE)/libvorbisidec_1.0.2+svn14261.orig.tar.gz
	pushd $(BUILD_TMP)/libvorbisidec-1.0.2+svn14261 && \
		patch -p1 < $(PATCHES)/tremor.diff && \
		./autogen.sh && \
		$(CONFIGURE) --prefix= --build=$(BUILD) --host=$(TARGET) && \
		make all && \
		perl -pi -e "s,^prefix=.*$$,prefix=$(TARGETPREFIX)," vorbisidec.pc && \
		make install DESTDIR=$(TARGETPREFIX) && \
		install -m644 vorbisidec.pc $(TARGETPREFIX)/lib/pkgconfig
	rm -rf $(BUILD_TMP)/libvorbisidec-1.0.2+svn14261
	touch $@

$(DEPDIR)/libpcap:
	tar -C $(BUILD_TMP) -xpf $(ARCHIVE)/libpcap-1.0.0.tar.gz
	pushd $(BUILD_TMP)/libpcap-1.0.0 && \
		echo "ac_cv_linux_vers=2" >> config.cache && \
		$(CONFIGURE) --with-pcap=linux --prefix= --cache-file=config.cache && \
		make all && \
		make install DESTDIR=$(TARGETPREFIX)
	rm -rf libpcap-1.0.0
	touch $@

