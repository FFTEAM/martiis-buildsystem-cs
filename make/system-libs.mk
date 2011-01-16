#Makefile to build system libs, potentially needed by neutrino and enigma

$(D)/zlib: $(ARCHIVE)/zlib-1.2.5.tar.bz2 | $(TARGETPREFIX) $(D)/opkg
	$(UNTAR)/zlib-1.2.5.tar.bz2
	cd $(BUILD_TMP)/zlib-1.2.5 && \
		CC=$(TARGET)-gcc mandir=$(BUILD_TMP)/.remove ./configure --prefix= --shared && \
		$(MAKE) && \
		ln -sf /bin/true ldconfig && \
		PATH=$(BUILD_TMP)/zlib-1.2.5:$(PATH) make install prefix=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/zlib.pc
	$(REMOVE)/zlib-1.2.5 $(PKGPREFIX)
	mkdir -p $(PKGPREFIX)/lib
	cp -a $(TARGETPREFIX)/lib/libz.so.* $(PKGPREFIX)/lib
	opkg.sh $(CONTROL_DIR)/libz $(TARGET) "$(MAINTAINER)" $(PKGPREFIX) $(BUILD_TMP)
	mv $(PKGPREFIX)/libz-*.opk $(PACKAGE_DIR)
	$(REMOVE)/.remove $(PKGPREFIX)
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

$(D)/libmad: $(ARCHIVE)/libmad-0.15.1b.tar.gz | $(TARGETPREFIX) $(D)/opkg
	$(UNTAR)/libmad-0.15.1b.tar.gz
	pushd $(BUILD_TMP)/libmad-0.15.1b && \
		patch -p1 < $(PATCHES)/libmad.diff && \
		patch -p1 < $(PATCHES)/libmad-0.15.1b-arm-buildfix.diff && \
		./configure --prefix= --build=$(BUILD) --host=$(TARGET) --enable-shared=yes --enable-speed --enable-fpm=arm --enable-sso && \
		$(MAKE) all && \
		make install DESTDIR=$(TARGETPREFIX) && \
		sed "s!^prefix=.*!prefix=$(TARGETPREFIX)!;" mad.pc > $(PKG_CONFIG_PATH)/libmad.pc
	$(REWRITE_LIBTOOL)/libmad.la
	$(REMOVE)/libmad-0.15.1b $(PKGPREFIX)
	mkdir -p $(PKGPREFIX)/lib
	cp -a $(TARGETPREFIX)/lib/libmad.so.* $(PKGPREFIX)/lib
	opkg.sh $(CONTROL_DIR)/libmad $(TARGET) "$(MAINTAINER)" $(PKGPREFIX) $(BUILD_TMP)
	mv $(PKGPREFIX)/libmad-*.opk $(PACKAGE_DIR)
	rm -rf $(PKGPREFIX)
	touch $@

$(D)/libid3tag: $(D)/zlib $(ARCHIVE)/libid3tag-0.15.1b.tar.gz | $(TARGETPREFIX) $(D)/opkg
	$(UNTAR)/libid3tag-0.15.1b.tar.gz
	pushd $(BUILD_TMP)/libid3tag-0.15.1b && \
		patch -p1 < $(PATCHES)/libid3tag.diff && \
		$(CONFIGURE) --prefix= --build=$(BUILD) --host=$(TARGET) --enable-shared=yes && \
		$(MAKE) all && \
		make install DESTDIR=$(TARGETPREFIX) && \
		sed "s!^prefix=.*!prefix=$(TARGETPREFIX)!;" id3tag.pc > $(PKG_CONFIG_PATH)/libid3tag.pc
	$(REWRITE_LIBTOOL)/libid3tag.la
	$(REMOVE)/libid3tag-0.15.1b $(PKGPREFIX)
	mkdir -p $(PKGPREFIX)/lib
	cp -a $(TARGETPREFIX)/lib/libid3tag.so.* $(PKGPREFIX)/lib
	opkg.sh $(CONTROL_DIR)/libid3tag $(TARGET) "$(MAINTAINER)" $(PKGPREFIX) $(BUILD_TMP)
	mv $(PKGPREFIX)/libid3tag-*.opk $(PACKAGE_DIR)
	rm -rf $(PKGPREFIX)
	touch $@

$(D)/libungif: $(ARCHIVE)/libungif-4.1.4.tar.bz2 | $(TARGETPREFIX) $(D)/opkg
	$(UNTAR)/libungif-4.1.4.tar.bz2
	pushd $(BUILD_TMP)/libungif-4.1.4 && \
		$(CONFIGURE) --prefix= --build=$(BUILD) --host=$(TARGET) --without-x --bindir=/.remove && \
		$(MAKE) all && \
		make install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_LIBTOOL)/libungif.la
	rm -rf $(TARGETPREFIX)/.remove
	$(REMOVE)/libungif-4.1.4 $(PKGPREFIX)
	mkdir -p $(PKGPREFIX)/lib
	cp -a $(TARGETPREFIX)/lib/libungif.so.* $(PKGPREFIX)/lib
	opkg.sh $(CONTROL_DIR)/libungif $(TARGET) "$(MAINTAINER)" $(PKGPREFIX) $(BUILD_TMP)
	mv $(PKGPREFIX)/libungif-*.opk $(PACKAGE_DIR)
	rm -rf $(PKGPREFIX)
	touch $@

$(D)/libcurl: $(ARCHIVE)/curl-7.20.0.tar.bz2 $(D)/zlib | $(TARGETPREFIX) $(D)/opkg
	$(UNTAR)/curl-7.20.0.tar.bz2
	pushd $(BUILD_TMP)/curl-7.20.0 && \
		$(CONFIGURE) --prefix= --build=$(BUILD) --host=$(TARGET) \
			--disable-manual --disable-file --disable-rtsp --disable-dict \
			--disable-imap --disable-pop3 --disable-smtp \
			--with-random --mandir=/.remove && \
		$(MAKE) all && \
		mkdir -p $(HOSTPREFIX)/bin && \
		sed -e "s,^prefix=,prefix=$(TARGETPREFIX)," < curl-config > $(HOSTPREFIX)/bin/curl-config && \
		chmod 755 $(HOSTPREFIX)/bin/curl-config && \
		make install DESTDIR=$(PKGPREFIX)
	rm $(PKGPREFIX)/bin/curl-config
	cp -a $(PKGPREFIX)/* $(TARGETPREFIX)
	mkdir $(BUILD_TMP)/pkg-lib
	cd $(PKGPREFIX) && rm -r include lib/pkgconfig lib/*.so lib/*a .remove/ && mv lib $(BUILD_TMP)/pkg-lib
	opkg.sh $(CONTROL_DIR)/curl $(TARGET) "$(MAINTAINER)" $(PKGPREFIX) $(BUILD_TMP)
	mv $(PKGPREFIX)/curl-*.opk $(PACKAGE_DIR)
	opkg.sh $(CONTROL_DIR)/libcurl $(TARGET) "$(MAINTAINER)" $(BUILD_TMP)/pkg-lib $(BUILD_TMP)
	mv $(BUILD_TMP)/pkg-lib/libcurl-*.opk $(PACKAGE_DIR)
	$(REWRITE_LIBTOOL)/libcurl.la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libcurl.pc
	rm -rf $(TARGETPREFIX)/.remove
	$(REMOVE)/curl-7.20.0 $(PKGPREFIX) $(BUILD_TMP)/pkg-lib
	touch $@

$(D)/libpng: $(ARCHIVE)/libpng-1.2.44.tar.bz2 $(D)/zlib | $(TARGETPREFIX) $(D)/opkg
	$(UNTAR)/libpng-1.2.44.tar.bz2
	pushd $(BUILD_TMP)/libpng-1.2.44 && \
		$(CONFIGURE) --prefix=$(TARGETPREFIX) --build=$(BUILD) --host=$(TARGET) --bindir=$(HOSTPREFIX)/bin --mandir=$(BUILD_TMP)/tmpman && \
		ECHO=echo $(MAKE) all && \
		make install
	$(REMOVE)/libpng-1.2.44 $(BUILD_TMP)/tmpman $(PKGPREFIX)
	mkdir -p $(PKGPREFIX)/lib
	cp -a $(TARGETPREFIX)/lib/libpng12.so.* $(PKGPREFIX)/lib
	opkg.sh $(CONTROL_DIR)/libpng12 $(TARGET) "$(MAINTAINER)" $(PKGPREFIX) $(BUILD_TMP)
	mv $(PKGPREFIX)/libpng-*.opk $(PACKAGE_DIR)
	rm -rf $(PKGPREFIX)
	touch $@

$(D)/freetype: $(D)/libpng $(ARCHIVE)/freetype-2.3.12.tar.bz2 | $(TARGETPREFIX) $(D)/opkg
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
	$(REMOVE)/freetype-2.3.12 $(PKGPREFIX)
	mkdir -p $(PKGPREFIX)/lib
	cp -a $(TARGETPREFIX)/lib/libfreetype.so.* $(PKGPREFIX)/lib
	opkg.sh $(CONTROL_DIR)/libfreetype $(TARGET) "$(MAINTAINER)" $(PKGPREFIX) $(BUILD_TMP)
	mv $(PKGPREFIX)/libfreetype-*.opk $(PACKAGE_DIR)
	rm -rf $(PKGPREFIX)
	touch $@

$(D)/libjpeg: $(ARCHIVE)/jpegsrc.v6b.tar.gz | $(TARGETPREFIX) $(D)/opkg
	$(UNTAR)/jpegsrc.v6b.tar.gz
	pushd $(BUILD_TMP) && \
		pushd jpeg-6b && \
		export CC=$(TARGET)-gcc && \
		$(CONFIGURE) --prefix= --build=$(BUILD) --host=$(TARGET) --enable-shared && \
		./ltconfig --no-verify ltmain.sh $(BUILD) && \
		$(MAKE)  && \
		make install-lib libdir=$(TARGETPREFIX)/lib includedir=$(TARGETPREFIX)/include
	$(REWRITE_LIBTOOL)/libjpeg.la
	$(REMOVE)/jpeg-6b $(PKGPREFIX)
	mkdir -p $(PKGPREFIX)/lib
	cp -a $(TARGETPREFIX)/lib/libjpeg.so.* $(PKGPREFIX)/lib
	opkg.sh $(CONTROL_DIR)/libjpeg $(TARGET) "$(MAINTAINER)" $(PKGPREFIX) $(BUILD_TMP)
	mv $(PKGPREFIX)/libjpeg-*.opk $(PACKAGE_DIR)
	rm -rf $(PKGPREFIX)
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

$(D)/ffmpeg: $(ARCHIVE)/ffmpeg-0.6.tar.bz2 | $(TARGETPREFIX) $(D)/opkg
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
		make install DESTDIR=$(PKGPREFIX)
	cp -a $(PKGPREFIX)/* $(TARGETPREFIX)
	cp $(BUILD_TMP)/ffmpeg-0.6/version.h $(TARGETPREFIX)/lib/ffmpeg-version.h
	rm -rf $(PKGPREFIX)/include $(PKGPREFIX)/lib/pkgconfig $(PKGPREFIX)/lib/*.so
	opkg.sh $(CONTROL_DIR)/ffmpeg $(TARGET) "$(MAINTAINER)" $(PKGPREFIX) $(BUILD_TMP)
	mv $(PKGPREFIX)/ffmpeg-*.opk $(PACKAGE_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libavdevice.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libavformat.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libavcodec.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libavutil.pc
	$(REMOVE)/ffmpeg-0.6 $(PKGPREFIX)
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

$(D)/libogg: $(ARCHIVE)/libogg-1.1.4.tar.gz | $(TARGETPREFIX) $(D)/opkg
	$(UNTAR)/libogg-1.1.4.tar.gz
	pushd $(BUILD_TMP)/libogg-1.1.4 && \
		patch -p1 < $(PATCHES)/libogg-1.1.4-nodoc.diff && \
		$(CONFIGURE) --prefix= --enable-shared && \
		$(MAKE) && \
		make install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/ogg.pc
	$(REWRITE_LIBTOOL)/libogg.la
	$(REMOVE)/libogg-1.1.4 $(PKGPREFIX)
	mkdir -p $(PKGPREFIX)/lib
	cp -a $(TARGETPREFIX)/lib/libogg.so.* $(PKGPREFIX)/lib
	opkg.sh $(CONTROL_DIR)/libogg $(TARGET) "$(MAINTAINER)" $(PKGPREFIX) $(BUILD_TMP)
	mv $(PKGPREFIX)/libogg-*.opk $(PACKAGE_DIR)
	rm -rf $(PKGPREFIX)
	touch $@

# for some reason, libvorbis does not work with "--prefix=/"
$(D)/libvorbis: $(D)/libogg $(ARCHIVE)/libvorbis-1.2.3.tar.bz2 | $(TARGETPREFIX) $(D)/opkg
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
	$(REMOVE)/libvorbis-1.2.3 $(PKGPREFIX)
	mkdir -p $(PKGPREFIX)/lib
	cp -a $(TARGETPREFIX)/lib/libvorbis.so.* $(PKGPREFIX)/lib
	cp -a $(TARGETPREFIX)/lib/libvorbisfile.so.* $(PKGPREFIX)/lib
	opkg.sh $(CONTROL_DIR)/libvorbis $(TARGET) "$(MAINTAINER)" $(PKGPREFIX) $(BUILD_TMP)
	mv $(PKGPREFIX)/libvorbis-*.opk $(PACKAGE_DIR)
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

$(D)/libncurses: $(ARCHIVE)/ncurses-5.6.tar.gz | ncurses-prereq $(TARGETPREFIX) $(D)/opkg
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
	$(REMOVE)/ncurses-5.6 $(PKGPREFIX)
	mkdir -p $(PKGPREFIX)/lib
	# deliberately ignore libforms and libpanel - not yet needed
	cp -a $(TARGETPREFIX)/lib/libncurses.so.* $(PKGPREFIX)/lib
	opkg.sh $(CONTROL_DIR)/libncurses $(TARGET) "$(MAINTAINER)" $(PKGPREFIX) $(BUILD_TMP)
	mv $(PKGPREFIX)/lib*.opk $(PACKAGE_DIR)
	rm -rf $(PKGPREFIX)
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

# this is butt ugly. For some reason, the old libtool in debian lenny 5.0.7
# does not put "-lz" into LDFLAGS of some subdirs, and I was not able to fix that.
# Hence the LDFLAGS="$(TARGET_LDFLAGS) -lz" hack... :-(
$(D)/directfb: $(ARCHIVE)/DirectFB-1.4.3.tar.gz $(D)/zlib $(D)/freetype $(D)/libpng $(D)/libjpeg | $(TARGETPREFIX) $(HOSTPREFIX)/bin
	$(UNTAR)/DirectFB-1.4.3.tar.gz
	cd $(BUILD_TMP)/DirectFB-1.4.3 && \
		patch -p2 -i $(PATCHES)/coolstream/directfb-1.4.3-coolstream.diff && \
		patch -p1 -i $(PATCHES)/directfb-1.4.3-cx245x-deinit-restore-fix.diff && \
		./autogen.sh fail ; \
		CFLAGS="$(TARGET_CFLAGS)" CPPFLAGS="$(TARGET_CPPFLAGS)" \
			CXXFLAGS="$(TARGET_CXXFLAGS)" PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
			LDFLAGS="$(TARGET_LDFLAGS) -lz" \
			./configure \
			--prefix=/ --mandir=/.remove --bindir=/bin/directfb \
			--build=$(BUILD) --host=$(TARGET) \
			--with-inputdrivers=linuxinput,keyboard,ps2mouse \
			--with-gfxdrivers=cx2450x --disable-video4linux \
			--disable-video4linux2 --enable-zlib --disable-x11 --disable-osx --disable-vnc \
			--enable-debug --disable-network --disable-devmem --disable-sysfs --enable-fbdev \
			--enable-jpeg --with-tests && \
		$(MAKE) && \
		$(MAKE) install DESTDIR=$(TARGETPREFIX) && \
		cp -a directfb-config $(HOSTPREFIX)/bin/
	printf 'mode "1280x720-50"\n    geometry 1280 720 1280 720 32\n    timings 0 0 0 0 0 0 0\nendmode\n' > $(TARGETPREFIX)/etc/fb.modes
	printf 'system=cx2450x\nlinux-input-devices=/dev/input/nevis_ir\nno-linux-input-grab\nmode=1280x720\npixelformat=ARGB\nbg-color=00000000\nno-debug\nautoflip-window\nno-cursor\n' > $(TARGETPREFIX)/etc/directfbrc
	rm -fr $(TARGETPREFIX)/.remove $(TARGETPREFIX)/bin/directfb/directfb-config
	$(REMOVE)/DirectFB-1.4.3
	touch $@

# the strange find | sed hack is needed for old cmake versions which
# don't obey CMAKE_INSTALL_PREFIX (e.g debian lenny 5.0.7's cmake 2.6)
$(D)/openthreads: $(SVN_TP_LIBS)/OpenThreads-svn | $(TARGETPREFIX) $(D)/opkg
	opkg-chksvn.sh $(CONTROL_DIR)/libOpenThreads $(SVN_TP_LIBS)/OpenThreads-svn
	tar -C $(SVN_TP_LIBS) -cp OpenThreads-svn --exclude=.svn | tar -C $(BUILD_TMP) -x
	cd $(BUILD_TMP)/OpenThreads-svn && \
		rm CMakeFiles/* -rf CMakeCache.txt cmake_install.cmake && \
		cmake . -DCMAKE_BUILD_TYPE=Release -DCMAKE_SYSTEM_NAME="Linux" \
			-DCMAKE_INSTALL_PREFIX="" \
			-DCMAKE_C_COMPILER="$(TARGET)-gcc" \
			-DCMAKE_CXX_COMPILER="$(TARGET)-g++" && \
		find . -name cmake_install.cmake -print0 | xargs -0 \
			sed -i 's@SET(CMAKE_INSTALL_PREFIX "/usr/local")@SET(CMAKE_INSTALL_PREFIX "")@' && \
		$(MAKE) && \
		make install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/openthreads.pc
	$(REMOVE)/OpenThreads-svn $(PKGPREFIX)
	mkdir -p $(PKGPREFIX)/lib
	cp -a $(TARGETPREFIX)/lib/libOpenThreads.so.* $(PKGPREFIX)/lib
	opkg.sh $(CONTROL_DIR)/libOpenThreads $(TARGET) "$(MAINTAINER)" $(PKGPREFIX) $(BUILD_TMP)
	mv $(PKGPREFIX)/libOpenThreads-*.opk $(PACKAGE_DIR)
	rm -rf $(PKGPREFIX)
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
