#Makefile to build Extras

$(D)/links: $(ARCHIVE)/links-2.3pre1.tar.bz2 $(D)/directfb | $(TARGETPREFIX)
	$(UNTAR)/links-2.3pre1.tar.bz2
	cd $(BUILD_TMP)/links-2.3pre1 && \
		$(PATCH)/links-2.3pre1.diff && \
		export CC=$(TARGET)-gcc && \
		export SYSROOT=$(TARGETPREFIX) && \
		$(CONFIGURE) \
			--host=$(TARGET) \
			--build=$(BUILD) \
			--prefix= \
			--mandir=$(BUILD_TMP)/.remove \
			--without-svgalib \
			--without-x \
			--without-libtiff \
			--enable-graphics \
			--enable-javascript && \
		make && \
		DESTDIR=$(TARGETPREFIX) make install prefix=$(TARGETPREFIX)
	mkdir -p $(TARGETPREFIX)/lib/tuxbox/plugins
	cp -f $(TARGETPREFIX)/bin/links $(TARGETPREFIX)/lib/tuxbox/plugins/links.so
	rm -f $(TARGETPREFIX)/bin/links
	echo "name=Links web browser"	 > $(TARGETPREFIX)/lib/tuxbox/plugins/links.cfg
	echo "desc=Web Browser"		>> $(TARGETPREFIX)/lib/tuxbox/plugins/links.cfg
	echo "type=2"			>> $(TARGETPREFIX)/lib/tuxbox/plugins/links.cfg
	echo "needfb=1"			>> $(TARGETPREFIX)/lib/tuxbox/plugins/links.cfg
	echo "needrc=1"			>> $(TARGETPREFIX)/lib/tuxbox/plugins/links.cfg
	echo "needoffsets=1"		>> $(TARGETPREFIX)/lib/tuxbox/plugins/links.cfg
	echo "bookmarkcount=0"		 > $(TARGETPREFIX)/var/tuxbox/config/bookmarks
	mkdir -p $(TARGETPREFIX)/var/tuxbox/config/links
	touch $(TARGETPREFIX)/var/tuxbox/config/links/links.his
	cp -a $(PATCHES)/bookmarks.html $(PATCHES)/tables.tar.gz $(TARGETPREFIX)/var/tuxbox/config/links
	$(REMOVE)/links-2.3pre1
	touch $@

QT_BUILD = $(BUILD_TMP)/qt-everywhere-opensource-src-4.6.3
QT_CONF = $(QT_BUILD)/mkspecs/qws/linux-cx2450x-g++/
$(D)/qt: $(ARCHIVE)/qt-everywhere-opensource-src-4.6.3.tar.gz $(D)/directfb | $(TARGETPREFIX)
	$(UNTAR)/qt-everywhere-opensource-src-4.6.3.tar.gz
	-mkdir $(QT_CONF)
	echo "include(../../common/g++.conf)"		 > $(QT_CONF)/qmake.conf
	echo "include(../../common/linux.conf)"		>> $(QT_CONF)/qmake.conf
	echo "include(../../common/qws.conf)"		>> $(QT_CONF)/qmake.conf
	echo "# modifications to g++.conf"		>> $(QT_CONF)/qmake.conf
	echo "QMAKE_CC         = $(TARGET)-gcc"		>> $(QT_CONF)/qmake.conf
	echo "QMAKE_CXX        = $(TARGET)-g++"		>> $(QT_CONF)/qmake.conf
	echo "QMAKE_LINK       = $(TARGET)-g++"		>> $(QT_CONF)/qmake.conf
	echo "QMAKE_LINK_SHLIB = $(TARGET)-g++"		>> $(QT_CONF)/qmake.conf
	echo "# modifications to linux.conf"		>> $(QT_CONF)/qmake.conf
	echo "QMAKE_AR         = $(TARGET)-ar cqs"	>> $(QT_CONF)/qmake.conf
	echo "QMAKE_OBJCOPY    = $(TARGET)-objcopy"	>> $(QT_CONF)/qmake.conf
	echo "QMAKE_STRIP      = $(TARGET)-strip"	>> $(QT_CONF)/qmake.conf
	echo "# for directfb"				>> $(QT_CONF)/qmake.conf
	echo "QT_CFLAGS_DIRECTFB = -I$(TARGETPREFIX)/include/directfb -D_REENTRANT"	>> $(QT_CONF)/qmake.conf
	echo "QT_LIBS_DIRECTFB   = -L$(TARGETPREFIX)/lib/ -ldirect -ldirectfb -lfusion"	>> $(QT_CONF)/qmake.conf
	echo "QT_DEFINES_DIRECTFB = QT_NO_DIRECTFB_PREALLOCATED"			>> $(QT_CONF)/qmake.conf
	echo ""						>> $(QT_CONF)/qmake.conf
	echo "load(qt_config)"				>> $(QT_CONF)/qmake.conf
	echo '#include "../../linux-g++/qplatformdefs.h"' > $(QT_CONF)/qplatformdefs.h
	cd $(QT_BUILD) && \
		sed -i 's/OPT_CONFIRM_LICENSE=no/OPT_CONFIRM_LICENSE=yes/' configure && \
		./configure \
			-embedded arm \
			-silent \
			-platform qws/linux-x86-g++ \
			-xplatform qws/linux-cx2450x-g++ \
			-prefix /opt/qt \
			-no-rpath \
			-release \
			-shared \
			-no-fast \
			-largefile \
			-exceptions \
			-no-accessibility \
			-no-stl \
			-qt-sql-sqlite \
			-no-qt3support \
			-qt-zlib \
			-qt-gif \
			-no-libtiff \
			-qt-libpng \
			-no-libmng \
			-qt-libjpeg \
			-qt-freetype \
			-continue \
			-no-nis \
			-no-cups \
			-no-iconv \
			-no-pch \
			-no-dbus \
			-no-separate-debug-info \
			-no-mmx \
			-no-3dnow \
			-no-sse \
			-no-sse2 \
			-optimized-qmake \
			-no-xmlpatterns \
			-multimedia \
			-audio-backend \
			-no-phonon \
			-no-phonon-backend \
			-no-openssl \
			-no-gtkstyle \
			-svg \
			-webkit \
			-no-javascript-jit \
			-no-script \
			-no-scripttools \
			-no-declarative \
			-opensource \
			-no-opengl \
			-no-openvg \
			-no-xshape \
			-no-xsync \
			-no-xinerama \
			-no-xcursor \
			-no-xfixes \
			-no-xrandr \
			-no-xrender \
			-no-mitshm \
			-no-fontconfig \
			-no-xinput \
			-no-xkb \
			-qt-kbd-linuxinput \
			-qt-mouse-pc \
			-qt-gfx-linuxfb \
			-plugin-gfx-directfb \
			-no-glib && \
		$(MAKE) && \
		$(MAKE) INSTALL_ROOT=$(TARGETPREFIX) install
	mv $(TARGETPREFIX)/opt/qt/bin/* $(HOSTPREFIX)/bin/
	install -m 0755 -D $(PATCHES)/browser.sh $(TARGETPREFIX)/bin/browser.sh
	touch $@

$(DEPDIR)/nbench: $(ARCHIVE)/nbench-byte-2.2.3.tar.gz | $(TARGETPREFIX)
	$(UNTAR)/nbench-byte-2.2.3.tar.gz
	cd $(BUILD_TMP)/nbench-byte-2.2.3 && \
		$(PATCH)/nbench-byte-2.2.3-crossfix.diff && \
		printf "#!/bin/sh\necho 4\n" > pointer && chmod 0755 pointer && \
		$(BUILDENV) make CC=$(TARGET)-gcc && \
		mkdir -p $(TARGETPREFIX)/opt/nbench-byte && \
		printf '#!/bin/sh\ncd /opt/nbench-byte\n./nbench $$@\n' > nbench-run.sh && \
		chmod 0755 nbench-run.sh && \
		cp -a nbench nbench-run.sh *DAT $(TARGETPREFIX)/opt/nbench-byte
	$(REMOVE)/nbench-byte-2.2.3
	touch $@

$(D)/libupnp: $(ARCHIVE)/libupnp-1.6.10.tar.bz2 | $(TARGETPREFIX)
	$(UNTAR)/libupnp-1.6.10.tar.bz2
	cd $(BUILD_TMP)/libupnp-1.6.10 && \
		$(CONFIGURE) --prefix=/opt/common && \
		$(MAKE) && \
		$(MAKE) install DESTDIR=$(PKGPREFIX)
	mv $(PKGPREFIX)/opt/common/lib/pkgconfig/libupnp.pc $(PKG_CONFIG_PATH)/
	cp -a $(PKGPREFIX)/* $(TARGETPREFIX)
	$(REWRITE_PKGCONF_OPT_C) $(PKG_CONFIG_PATH)/libupnp.pc
	$(REWRITE_LIBTOOL_OPT_C)/libixml.la
	$(REWRITE_LIBTOOL_OPT_C)/libthreadutil.la
	$(REWRITE_LIBTOOL_OPT_C)/libupnp.la
	cd $(PKGPREFIX)/opt/common && \
		rm -r include lib/pkgconfig lib/*a lib/*.so
	opkg.sh $(CONTROL_DIR)/libupnp $(TARGET) "$(MAINTAINER)" $(PKGPREFIX) $(BUILD_TMP)
	mv $(PKGPREFIX)/libupnp-*.opk $(PACKAGE_DIR)
	$(REMOVE)/libupnp-1.6.10 $(PKGPREFIX)
	touch $@

$(ARCHIVE)/libdlna-hg.tar.bz2: | find-hg
	cd $(BUILD_TMP) && \
		hg clone http://hg.geexbox.org/libdlna libdlna-hg && \
		tar cvpjf $@ --exclude='*/.hg' libdlna-hg
	$(REMOVE)/libdlna-hg

$(D)/libdlna: $(ARCHIVE)/libdlna-hg.tar.bz2 $(D)/ffmpeg $(D)/libupnp | $(TARGETPREFIX)
	$(UNTAR)/libdlna-hg.tar.bz2
	cd $(BUILD_TMP)/libdlna-hg && \
		$(PATCH)/libdlna-fix-build.diff && \
		$(BUILDENV) \
		./configure --cross-compile --cross-prefix=$(TARGET)- \
			--disable-sqlite --prefix=/opt/common && \
		touch src/TAGS src/tags && \
		$(MAKE) && \
		$(MAKE) install DESTDIR=$(PKGPREFIX)
	mv $(PKGPREFIX)/opt/common/lib/pkgconfig/libdlna.pc $(PKG_CONFIG_PATH)/
	cp -a $(PKGPREFIX)/* $(TARGETPREFIX)
	sed -i 's/PREFIX/prefix/g' $(PKG_CONFIG_PATH)/libdlna.pc
	$(REWRITE_PKGCONF_OPT_C) $(PKG_CONFIG_PATH)/libdlna.pc
	cd $(PKGPREFIX)/opt/common && \
		rm -r include lib/pkgconfig lib/*.so
	opkg.sh $(CONTROL_DIR)/libdlna $(TARGET) "$(MAINTAINER)" $(PKGPREFIX) $(BUILD_TMP)
	mv $(PKGPREFIX)/libdlna-*.opk $(PACKAGE_DIR)
	$(REMOVE)/libdlna-hg $(PKGPREFIX)
	touch $@

$(ARCHIVE)/ushare-hg.tar.bz2: | find-hg
	cd $(BUILD_TMP) && \
		hg clone http://hg.geexbox.org/ushare ushare-hg && \
		tar cvpjf $@ --exclude='*/.hg' ushare-hg
	$(REMOVE)/ushare-hg

$(D)/ushare: $(ARCHIVE)/ushare-hg.tar.bz2 $(D)/libdlna
	$(UNTAR)/ushare-hg.tar.bz2
	cd $(BUILD_TMP)/ushare-hg && \
		$(PATCH)/ushare-fix-build.diff && \
		$(BUILDENV) \
		./configure --cross-compile --cross-prefix=$(TARGET)- \
			--prefix=/opt/ushare && \
		echo "mandir=/.remove" >> config.mak && \
		test -e src/config.h || ln -s ../config.h src/ && \
		$(MAKE) && \
		$(MAKE) install DESTDIR=$(PKGPREFIX)
	install -D -m 0755 $(PATCHES)/ushare.init $(PKGPREFIX)/opt/ushare/etc/init.d/ushare
	ln -s ushare $(PKGPREFIX)/opt/ushare/etc/init.d/S99ushare # start late, so that drives are mounted
	ln -s ushare $(PKGPREFIX)/opt/ushare/etc/init.d/K01ushare # stop early...
	rm -rf $(PKGPREFIX)/.remove
	cp -a $(PKGPREFIX)/* $(TARGETPREFIX)
	opkg.sh $(CONTROL_DIR)/ushare $(TARGET) "$(MAINTAINER)" $(PKGPREFIX) $(BUILD_TMP)
	mv $(PKGPREFIX)/ushare-*.opk $(PACKAGE_DIR)
	$(REMOVE)/ushare-hg $(PKGPREFIX)
	touch $@

$(D)/dropbear: $(ARCHIVE)/dropbear-0.52.tar.bz2
	$(UNTAR)/dropbear-0.52.tar.bz2
	cd $(BUILD_TMP)/dropbear-0.52 && \
		$(PATCH)/dropbear-0.52-allow-empty-password-for-key-login.diff && \
		$(BUILDENV) CFLAGS="$(TARGET_CFLAGS) -DDSS_PRIV_FILENAME=\"\\\"/opt/dropbear/etc/dropbear/dropbear_dss_host_key\\\"\" -DRSA_PRIV_FILENAME=\"\\\"/opt/dropbear/etc/dropbear/dropbear_rsa_host_key\\\"\"" \
			 ./configure $(CONFIGURE_OPTS) --prefix=/opt/dropbear && \
		$(MAKE) && \
		$(MAKE) install DESTDIR=$(PKGPREFIX)
	install -D -m 0755 $(PATCHES)/dropbear.init $(PKGPREFIX)/opt/dropbear/etc/init.d/dropbear
	install -d -m 0755 $(PKGPREFIX)/opt/dropbear/etc/dropbear
	ln -sf dropbear $(PKGPREFIX)/opt/dropbear/etc/init.d/S60dropbear
	ln -sf dropbear $(PKGPREFIX)/opt/dropbear/etc/init.d/K60dropbear
	cp -a $(PKGPREFIX)/* $(TARGETPREFIX)
	opkg.sh $(CONTROL_DIR)/dropbear $(TARGET) "$(MAINTAINER)" $(PKGPREFIX) $(BUILD_TMP)
	mv $(PKGPREFIX)/dropbear-*.opk $(PACKAGE_DIR)
	$(REMOVE)/dropbear-0.52 $(PKGPREFIX)
	touch $@

$(DEPDIR)/opkg: $(ARCHIVE)/opkg-0.1.8.tar.gz | $(TARGETPREFIX)
	$(UNTAR)/opkg-0.1.8.tar.gz
	cd $(BUILD_TMP)/opkg-0.1.8 && \
		echo ac_cv_func_realloc_0_nonnull=yes >> config.cache && \
		$(CONFIGURE) \
		--prefix= \
		--build=$(BUILD) \
		--host=$(TARGET) \
		--disable-curl \
		--disable-gpg \
		--config-cache \
		--with-opkglibdir=/var/lib \
		--mandir=$(BUILD_TMP)/.remove && \
		$(MAKE) all exec_prefix= && \
		make install prefix=$(TARGETPREFIX)
	install -d -m 0755 $(TARGETPREFIX)/var/lib/opkg
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libopkg.pc
	$(REMOVE)/opkg-0.1.8
	$(REMOVE)/.remove
	touch $@
