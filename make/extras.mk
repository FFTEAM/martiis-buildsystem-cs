# Makefile to build Extras

$(D)/cdparanoia: $(ARCHIVE)/cdparanoia-III-10.2.src.tgz | $(TARGETPREFIX)
	rm -rf $(PKGPREFIX)
	$(UNTAR)/cdparanoia-III-10.2.src.tgz
	set -e; cd $(BUILD_TMP)/cdparanoia-III-10.2; \
		$(CONFIGURE) \
			--host=$(TARGET) \
			--build=$(BUILD) \
			--prefix= \
			--exec-prefix=$(PKGPREFIX) \
			--includedir=$(TARGETPREFIX)/include \
			--mandir=$(BUILD_TMP)/.remove \
			; \
		# parallel make yields different binaries for every build, so disable it \
		$(MAKE) -j 1 ; \
		make install
	cp -a $(PKGPREFIX)/* $(TARGETPREFIX)
	rm $(PKGPREFIX)/lib/*.a $(PKGPREFIX)/lib/*.so
	PKG_VER=10.2 $(OPKG_SH) $(CONTROL_DIR)/cdparanoia
	$(REMOVE)/cdparanoia-III-10.2 $(BUILD_TMP)/.remove $(PKGPREFIX)
	touch $@

$(D)/cddfs: $(ARCHIVE)/cddfs-0.2.tar.gz fuse cdparanoia | $(TARGETPREFIX)
	rm -rf $(PKGPREFIX)
	$(UNTAR)/cddfs-0.2.tar.gz
	mkdir $(PKGPREFIX) $(PKGPREFIX)/bin
	$(TARGET)-gcc \
		$(TARGET_CFLAGS) -g -Wall -D_FILE_OFFSET_BITS=64 -D_REENTRANT -DFUSE_USE_VERSION=22 \
		$(TARGET_LDFLAGS) -lpthread -lfuse -lcdda_paranoia -lcdda_interface \
		-fsigned-char \
		-o $(PKGPREFIX)/bin/cddfs $(BUILD_TMP)/cddfs-0.2/cddfs.c
	PKG_VER=0.2 $(OPKG_SH) $(CONTROL_DIR)/cddfs
	$(REMOVE)/cddfs-0.2 $(PKGPREFIX)
	touch $@

$(D)/dvdreadfs: $(ARCHIVE)/dvdreadfs.tar fuse libdvdread | $(TARGETPREFIX)
	rm -rf $(PKGPREFIX)
	mkdir -p $(BUILD_TMP)/dvdreadfs $(PKGPREFIX)/bin
	tar -C $(BUILD_TMP)/dvdreadfs -xf $(ARCHIVE)/dvdreadfs.tar
	cd $(BUILD_TMP)/dvdreadfs && $(PATCH)/dvdreadfs-seife.diff
	$(TARGET)-gcc \
		$(TARGET_CFLAGS) -DFUSE_USE_VERSION=26 -D_FILE_OFFSET_BITS=64 -DFORCE_SINGLE_THREAD=1 \
		$(TARGET_LDFLAGS) -lfuse -ldvdread \
		-o $(PKGPREFIX)/bin/dvdreadfs $(BUILD_TMP)/dvdreadfs/dvdreadfs.c
	install -D -m 755 $(SCRIPTS)/dvdreadfs.init $(PKGPREFIX)/etc/init.d/dvdreadfs
	ln -sf dvdreadfs $(PKGPREFIX)/etc/init.d/S80dvdreadfs
	ln -sf dvdreadfs $(PKGPREFIX)/etc/init.d/K20dvdreadfs
	cp -a $(PKGPREFIX)/* $(TARGETPREFIX)
	PKG_VER=0.0 $(OPKG_SH) $(CONTROL_DIR)/dvdreadfs
	$(REMOVE)/dvdreadfs $(PKGPREFIX)
	touch $@

$(D)/djmount: $(ARCHIVE)/djmount-0.71.tar.gz fuse | $(TARGETPREFIX)
	rm -rf $(PKGPREFIX)
	$(UNTAR)/djmount-0.71.tar.gz
	set -e; cd $(BUILD_TMP)/djmount-0.71; \
		$(CONFIGURE) -C \
			--host=$(TARGET) \
			--build=$(BUILD) \
			--prefix=/opt/pkg \
			; \
		$(MAKE); \
		make install DESTDIR=$(PKGPREFIX)
	install -D -m 755 $(SCRIPTS)/djmount.init $(PKGPREFIX)/opt/pkg/etc/init.d/djmount
	ln -sf djmount $(PKGPREFIX)/opt/pkg/etc/init.d/S80djmount
	ln -sf djmount $(PKGPREFIX)/opt/pkg/etc/init.d/K20djmount
	cp -a $(PKGPREFIX)/* $(TARGETPREFIX)
	PKG_VER=0.71 $(OPKG_SH) $(CONTROL_DIR)/djmount
	$(REMOVE)/djmount-0.71 $(PKGPREFIX)
	touch $@

$(D)/evtest: $(ARCHIVE)/evtest_1.29.orig.tar.bz2
	$(UNTAR)/evtest_1.29.orig.tar.bz2
	set -e; cd $(BUILD_TMP)/evtest-1.29; \
		$(PATCH)/evtest-1.29-old-kernel.diff; \
		$(CONFIGURE) --prefix= \
			; \
		$(MAKE); \
		make install DESTDIR=$(TARGETPREFIX)
	$(REMOVE)/evtest-1.29
	touch $@

$(D)/libdvdcss: $(ARCHIVE)/libdvdcss-$(DVDCSS_VER).tar.bz2 | $(TARGETPREFIX)
	rm -rf $(PKGPREFIX)
	$(UNTAR)/libdvdcss-$(DVDCSS_VER).tar.bz2
	set -e; cd $(BUILD_TMP)/libdvdcss-$(DVDCSS_VER); \
		$(CONFIGURE) \
			--host=$(TARGET) \
			--build=$(BUILD) \
			--prefix= \
			; \
		$(MAKE) ; \
		make install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libdvdcss.pc
	$(REWRITE_LIBTOOL)/libdvdcss.la
	mkdir -p $(PKGPREFIX)/lib
	cp -a $(TARGETPREFIX)/lib/libdvdcss.so.* $(PKGPREFIX)/lib
	PKG_VER=$(DVDCSS_VER) $(OPKG_SH) $(CONTROL_DIR)/libdvdcss
	$(REMOVE)/libdvdcss-$(DVDCSS_VER) $(PKGPREFIX)
	touch $@

$(D)/libdvdread: $(ARCHIVE)/libdvdread-4.1.3.tar.bz2 | $(TARGETPREFIX)
	rm -rf $(PKGPREFIX)
	$(UNTAR)/libdvdread-4.1.3.tar.bz2
	set -e; cd $(BUILD_TMP)/libdvdread-4.1.3; \
		$(CONFIGURE) \
			--host=$(TARGET) \
			--build=$(BUILD) \
			--prefix= \
			; \
		$(MAKE) ; \
		make install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/dvdread.pc
	$(REWRITE_LIBTOOL)/libdvdread.la
	mkdir -p $(PKGPREFIX)/lib
	cp -a $(TARGETPREFIX)/lib/libdvdread.so.* $(PKGPREFIX)/lib
	PKG_VER=4.1.3 $(OPKG_SH) $(CONTROL_DIR)/libdvdread
	$(REMOVE)/libdvdread-4.1.3 $(PKGPREFIX)
	touch $@

# this rule is ugly, but will do for now
arduino-serlcd: | $(TARGETPREFIX)
	set -e; if [ -d $(BUILD_TMP)/arduino-serlcd ]; \
		then cd $(BUILD_TMP)/arduino-serlcd; git pull; \
		else cd $(BUILD_TMP); git clone $(GITORIOUS)/seife/arduino-serlcd.git; \
		fi
	set -e; cd $(BUILD_TMP)/arduino-serlcd; \
		make CC=$(TARGET)-gcc; \
		cp arduino_serlcd_test $(TARGETPREFIX)/bin


$(D)/links: $(ARCHIVE)/links-$(LINKS-VER).tar.bz2 $(D)/directfb | $(TARGETPREFIX)
	rm -rf $(PKGPREFIX)
	$(UNTAR)/links-$(LINKS-VER).tar.bz2
	set -e; cd $(BUILD_TMP)/links-$(LINKS-VER); \
		$(PATCH)/links-2.3pre1.diff; \
		export CC=$(TARGET)-gcc; \
		export SYSROOT=$(TARGETPREFIX); \
		$(CONFIGURE) \
			--host=$(TARGET) \
			--build=$(BUILD) \
			--prefix= \
			--mandir=$(BUILD_TMP)/.remove \
			--without-svgalib \
			--without-x \
			--without-libtiff \
			--enable-graphics \
			--enable-javascript; \
		$(MAKE); \
		DESTDIR=$(PKGPREFIX) make install prefix=$(PKGPREFIX)
	mkdir -p $(PKGPREFIX)/lib/tuxbox/plugins $(PKGPREFIX)/var/tuxbox/config/links
	mv $(PKGPREFIX)/bin/links $(PKGPREFIX)/lib/tuxbox/plugins/links.so
	rmdir $(PKGPREFIX)/bin
	echo "name=Links web browser"	 > $(PKGPREFIX)/lib/tuxbox/plugins/links.cfg
	echo "desc=Web Browser"		>> $(PKGPREFIX)/lib/tuxbox/plugins/links.cfg
	echo "type=2"			>> $(PKGPREFIX)/lib/tuxbox/plugins/links.cfg
	echo "needfb=1"			>> $(PKGPREFIX)/lib/tuxbox/plugins/links.cfg
	echo "needrc=1"			>> $(PKGPREFIX)/lib/tuxbox/plugins/links.cfg
	echo "needoffsets=1"		>> $(PKGPREFIX)/lib/tuxbox/plugins/links.cfg
	echo "bookmarkcount=0"		 > $(PKGPREFIX)/var/tuxbox/config/bookmarks
	touch $(PKGPREFIX)/var/tuxbox/config/links/links.his
	cp -a $(SCRIPTS)/bookmarks.html $(SCRIPTS)/tables.tar.gz $(PKGPREFIX)/var/tuxbox/config/links
	cp -a $(PKGPREFIX)/* $(TARGETPREFIX)
	$(OPKG_SH) $(CONTROL_DIR)/links
	$(REMOVE)/links-$(LINKS-VER) $(BUILD_TMP)/.remove $(PKGPREFIX)
	touch $@

QT_BUILD = $(BUILD_TMP)/qt-everywhere-opensource-src-$(QT-VER)
QT_CONF = $(QT_BUILD)/mkspecs/qws/linux-cx2450x-g++/
$(D)/qt: $(ARCHIVE)/qt-everywhere-opensource-src-$(QT-VER).tar.gz $(D)/directfb | $(TARGETPREFIX)
	$(UNTAR)/qt-everywhere-opensource-src-$(QT-VER).tar.gz
	mkdir $(QT_CONF)
	echo "include(../../common/g++.conf)"		 > $(QT_CONF)/qmake.conf
	echo "include(../../common/linux.conf)"		>> $(QT_CONF)/qmake.conf
	echo "include(../../common/qws.conf)"		>> $(QT_CONF)/qmake.conf
	echo "# modifications to g++.conf"			>> $(QT_CONF)/qmake.conf
	echo "QMAKE_CC         = $(TARGET)-gcc"		>> $(QT_CONF)/qmake.conf
	echo "QMAKE_CXX        = $(TARGET)-g++"		>> $(QT_CONF)/qmake.conf
	echo "QMAKE_LINK       = $(TARGET)-g++"		>> $(QT_CONF)/qmake.conf
	echo "QMAKE_LINK_SHLIB = $(TARGET)-g++"		>> $(QT_CONF)/qmake.conf
	echo "# modifications to linux.conf"		>> $(QT_CONF)/qmake.conf
	echo "QMAKE_AR         = $(TARGET)-ar cqs"	>> $(QT_CONF)/qmake.conf
	echo "QMAKE_OBJCOPY    = $(TARGET)-objcopy"	>> $(QT_CONF)/qmake.conf
	echo "QMAKE_STRIP      = $(TARGET)-strip"	>> $(QT_CONF)/qmake.conf
	echo "# for directfb"						>> $(QT_CONF)/qmake.conf
	echo "QT_CFLAGS_DIRECTFB = -I$(TARGETPREFIX)/include/directfb -D_REENTRANT"		>> $(QT_CONF)/qmake.conf
	echo "QT_LIBS_DIRECTFB   = -L$(TARGETPREFIX)/lib/ -ldirect -ldirectfb -lfusion"	>> $(QT_CONF)/qmake.conf
	echo "QT_DEFINES_DIRECTFB = QT_NO_DIRECTFB_PREALLOCATED"						>> $(QT_CONF)/qmake.conf
	echo ""												>> $(QT_CONF)/qmake.conf
	echo "load(qt_config)"								>> $(QT_CONF)/qmake.conf
	echo '#include "../../linux-g++/qplatformdefs.h"'	> $(QT_CONF)/qplatformdefs.h
	set -e; cd $(QT_BUILD); \
		sed -i 's/OPT_CONFIRM_LICENSE=no/OPT_CONFIRM_LICENSE=yes/' configure; \
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
			-no-glib; \
		$(MAKE); \
		$(MAKE) INSTALL_ROOT=$(TARGETPREFIX) install
	mv $(TARGETPREFIX)/opt/qt/bin/* $(HOSTPREFIX)/bin/
	install -m 0755 -D $(SCRIPTS)/browser.sh $(TARGETPREFIX)/bin/browser.sh
	$(REMOVE)/links-$(QT-VER) $(BUILD_TMP)/.remove $(PKGPREFIX)
	touch $@

$(DEPDIR)/nbench: $(ARCHIVE)/nbench-byte-$(NBENCH_BYTE-VER).tar.gz | $(TARGETPREFIX)
	$(UNTAR)/nbench-byte-$(NBENCH_BYTE-VER).tar.gz
	set -e; cd $(BUILD_TMP)/nbench-byte-$(NBENCH_BYTE-VER); \
		$(PATCH)/nbench-byte-2.2.3-crossfix.diff; \
		printf "#!/bin/sh\necho 4\n" > pointer; chmod 0755 pointer; \
		$(BUILDENV) make CC=$(TARGET)-gcc; \
		mkdir -p $(TARGETPREFIX)/opt/nbench-byte; \
		printf '#!/bin/sh\ncd /opt/nbench-byte\n./nbench $$@\n' > nbench-run.sh; \
		chmod 0755 nbench-run.sh; \
		cp -a nbench nbench-run.sh *DAT $(TARGETPREFIX)/opt/nbench-byte
	$(REMOVE)/nbench-byte-$(NBENCH_BYTE-VER)
	touch $@

$(D)/libupnp: $(ARCHIVE)/libupnp-$(LIBUPNP_VER).tar.bz2 | $(TARGETPREFIX)
	$(UNTAR)/libupnp-$(LIBUPNP_VER).tar.bz2
	set -e; cd $(BUILD_TMP)/libupnp-$(LIBUPNP_VER); \
		$(CONFIGURE) --prefix=; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(PKGPREFIX)
	cp -a $(PKGPREFIX)/* $(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libupnp.pc
	$(REWRITE_LIBTOOL)/libixml.la
	$(REWRITE_LIBTOOL)/libthreadutil.la
	$(REWRITE_LIBTOOL)/libupnp.la
	cd $(PKGPREFIX); \
		rm -r include lib/pkgconfig lib/*a lib/*.so
	PKG_VER=$(LIBUPNP_VER) PKG_AUTOREQPROV=1 \
		$(OPKG_SH) $(CONTROL_DIR)/libupnp
	$(REMOVE)/libupnp-$(LIBUPNP_VER) $(PKGPREFIX)
	touch $@

$(ARCHIVE)/libdlna-hg.tar.bz2: | find-hg
	est -e; cd $(BUILD_TMP); \
		hg clone http://hg.geexbox.org/libdlna libdlna-hg; \
		tar cvpjf $@ --exclude='*/.hg' libdlna-hg
	$(REMOVE)/libdlna-hg

$(D)/libdlna: $(ARCHIVE)/libdlna-hg.tar.bz2 $(D)/ffmpeg $(D)/libupnp | $(TARGETPREFIX)
	$(UNTAR)/libdlna-hg.tar.bz2
	set -e; cd $(BUILD_TMP)/libdlna-hg; \
		$(PATCH)/libdlna-fix-build.diff; \
		$(BUILDENV) \
		./configure --cross-compile --cross-prefix=$(TARGET)- \
			--disable-sqlite --prefix=/opt/pkg; \
		touch src/TAGS src/tags; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(PKGPREFIX)
	mv $(PKGPREFIX)/opt/pkg/lib/pkgconfig/libdlna.pc $(PKG_CONFIG_PATH)/
	cp -a $(PKGPREFIX)/* $(TARGETPREFIX)
	sed -i 's/PREFIX/prefix/g' $(PKG_CONFIG_PATH)/libdlna.pc
	$(REWRITE_PKGCONF_OPT) $(PKG_CONFIG_PATH)/libdlna.pc
	cd $(PKGPREFIX)/opt/pkg && \
		rm -r include lib/pkgconfig lib/*.so
	$(OPKG_SH) $(CONTROL_DIR)/libdlna
	$(REMOVE)/libdlna-hg $(PKGPREFIX)
	touch $@

$(ARCHIVE)/ushare-1.1a.r469.tar.bz2: | find-hg
	set -e; cd $(BUILD_TMP); \
		hg clone -u 469 http://hg.geexbox.org/ushare ushare-1.1a.r469; \
		tar cvpjf $@ --exclude='*/.hg' ushare-1.1a.r469
	$(REMOVE)/ushare-hg

$(D)/ushare: $(ARCHIVE)/ushare-1.1a.r469.tar.bz2 $(D)/libdlna | $(TARGETPREFIX)
	$(UNTAR)/ushare-1.1a.r469.tar.bz2
	set -e; cd $(BUILD_TMP)/ushare-1.1a.r469; \
		$(PATCH)/ushare-new-upnp.diff; \
		$(BUILDENV) \
		./configure --cross-compile --cross-prefix=$(TARGET)- \
			--prefix=; \
		echo "mandir=/.remove" >> config.mak; \
		test -e src/config.h || ln -s ../config.h src/; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(PKGPREFIX)
	install -D -m 0755 $(SCRIPTS)/ushare.init $(PKGPREFIX)/etc/init.d/ushare
	ln -s ushare $(PKGPREFIX)/etc/init.d/S99ushare # start late, so that drives are mounted
	ln -s ushare $(PKGPREFIX)/etc/init.d/K01ushare # stop early...
	rm -rf $(PKGPREFIX)/.remove
	cp -a $(PKGPREFIX)/* $(TARGETPREFIX)
	PKG_VER=1.1a.r469 PKG_AUTOREQPROV=1 \
		$(OPKG_SH) $(CONTROL_DIR)/ushare
	$(REMOVE)/ushare-1.1a.r469 $(PKGPREFIX)
	touch $@

$(D)/dropbear: $(ARCHIVE)/dropbear-$(DROPBEAR-VER).tar.bz2 | $(TARGETPREFIX)
	$(UNTAR)/dropbear-$(DROPBEAR-VER).tar.bz2
	set -e; cd $(BUILD_TMP)/dropbear-$(DROPBEAR-VER); \
		$(PATCH)/dropbear-0.52-allow-empty-password-for-key-login.diff; \
		$(PATCH)/dropbear-0.53-opt-pkg-prefix.diff; \
		$(BUILDENV) CFLAGS="$(TARGET_CFLAGS) -DDSS_PRIV_FILENAME=\"\\\"/opt/pkg/etc/dropbear/dropbear_dss_host_key\\\"\" -DRSA_PRIV_FILENAME=\"\\\"/opt/pkg/etc/dropbear/dropbear_rsa_host_key\\\"\"" \
			 ./configure $(CONFIGURE_OPTS) --prefix=/opt/pkg --disable-lastlog --disable-utmp --disable-utmpx --disable-wtmpx ; \
		$(MAKE) PROGRAMS="dropbear dbclient dropbearkey scp" SCPPROGRESS=1; \
		$(MAKE) PROGRAMS="dropbear dbclient dropbearkey scp" install DESTDIR=$(PKGPREFIX)
	install -D -m 0755 $(SCRIPTS)/dropbear.init $(PKGPREFIX)/opt/pkg/etc/init.d/dropbear
	install -d -m 0755 $(PKGPREFIX)/opt/pkg/etc/dropbear
	ln -sf dropbear $(PKGPREFIX)/opt/pkg/etc/init.d/S60dropbear
	#ln -sf dropbear $(PKGPREFIX)/opt/pkg/etc/init.d/K60dropbear
	cp -a $(PKGPREFIX)/* $(TARGETPREFIX)
	$(OPKG_SH) $(CONTROL_DIR)/dropbear
	$(REMOVE)/dropbear-$(DROPBEAR-VER) $(PKGPREFIX)
	touch $@

$(DEPDIR)/opkg: $(ARCHIVE)/opkg-$(OPKG_SVN_VER).tar.gz | $(TARGETPREFIX)
	$(UNTAR)/opkg-$(OPKG_SVN_VER).tar.gz
	set -e; cd $(BUILD_TMP)/opkg-$(OPKG_SVN_VER); \
		$(PATCH)/opkg-0.1.8-dont-segfault.diff; \
		autoreconf -v --install; \
		echo ac_cv_func_realloc_0_nonnull=yes >> config.cache; \
		$(CONFIGURE) \
		--prefix= \
		--build=$(BUILD) \
		--host=$(TARGET) \
		--disable-curl \
		--disable-gpg \
		--disable-shared \
		--config-cache \
		--with-opkglibdir=/var/lib \
		--mandir=$(BUILD_TMP)/.remove; \
		$(MAKE) all exec_prefix=; \
		make install prefix=$(PKGPREFIX); \
		make distclean; \
		./configure \
		--prefix= \
		--disable-curl \
		--disable-gpg \
		--disable-shared \
		--with-opkglibdir=/var/lib; \
		$(MAKE) all; \
		cp -a src/opkg-cl $(HOSTPREFIX)/bin
	install -d -m 0755 $(PKGPREFIX)/var/lib/opkg
	install -d -m 0755 $(PKGPREFIX)/etc/opkg
	echo "# example config file, copy to opkg.conf and edit" > $(PKGPREFIX)/etc/opkg/opkg.conf.example
	echo "src server http://server/dist/$(PLATFORM)" >> $(PKGPREFIX)/etc/opkg/opkg.conf.example
	$(REMOVE)/opkg-$(OPKG_SVN_VER) $(PKGPREFIX)/.remove
	cp -a $(PKGPREFIX)/* $(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libopkg.pc
	rm -rf $(PKGPREFIX)/lib $(PKGPREFIX)/include
	PKG_VER=$(OPKG_SVN_VER) $(OPKG_SH) $(CONTROL_DIR)/opkg
	rm -rf $(PKGPREFIX)
	touch $@

#http://www.dbox2world.net/board293-coolstream-hd1/board314-coolstream-development/9363-idee-midnight-commander/
$(D)/libglib: $(ARCHIVE)/glib-$(GLIB-VER).tar.bz2 $(D)/zlib | $(TARGETPREFIX)
	$(UNTAR)/glib-$(GLIB-VER).tar.bz2
	set -e; cd $(BUILD_TMP)/glib-$(GLIB-VER); \
		echo "ac_cv_func_posix_getpwuid_r=yes" > config.cache; \
		echo "ac_cv_func_posix_getgrgid_r=ys" >> config.cache; \
		echo "glib_cv_stack_grows=no" >> config.cache; \
		echo "glib_cv_uscore=no" >> config.cache; \
		$(BUILDENV) \
		./configure \
			--cache-file=config.cache \
			--disable-gtk-doc \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--with-html-dir=/.remove \
			--mandir=/.remove \
			--prefix=/opt/pkg;\
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(PKGPREFIX)
	rm -rf $(PKGPREFIX)/.remove
	set -e; cd $(PKGPREFIX)/opt/pkg/lib/pkgconfig; for i in *; do \
		mv $$i $(PKG_CONFIG_PATH); $(REWRITE_PKGCONF_OPT) $(PKG_CONFIG_PATH)/$$i; done
	rm -rf $(PKGPREFIX)/opt/pkg/share/locale # who needs localization?
	rm $(PKGPREFIX)/opt/pkg/bin/glib-mkenums # no perl available on the box
	sed -i "s,^libdir=.*,libdir='$(TARGETPREFIX)/opt/pkg/lib'," $(PKGPREFIX)/opt/pkg/lib/*.la
	sed -i '/^dependency_libs=/{ s#/opt/pkg/lib#$(TARGETPREFIX)/opt/pkg/lib#g }' $(PKGPREFIX)/opt/pkg/lib/*.la
	rm $(PKGPREFIX)/opt/pkg/bin/gdbus
	cp -a $(PKGPREFIX)/* $(TARGETPREFIX)
	cd $(PKGPREFIX)/opt/pkg && \
		rm -r include lib/*.so lib/*.la share etc/bash_completion.d \
		bin/gtester-report bin/glib-gettextize
	rmdir $(PKGPREFIX)/opt/pkg/lib/pkgconfig $(PKGPREFIX)/opt/pkg/etc
	PKG_VER=$(GLIB-VER) \
		PKG_DEP=`opkg-find-requires.sh $(PKGPREFIX)` \
		PKG_PROV=`opkg-find-provides.sh $(PKGPREFIX)` \
		$(OPKG_SH) $(CONTROL_DIR)/libglib
	$(REMOVE)/glib-$(GLIB-VER) $(PKGPREFIX)
	touch $@

$(D)/libxml2: $(D)/zlib $(ARCHIVE)/libxml2-$(LIBXML2_VER).tar.gz | $(TARGETPREFIX)
	$(UNTAR)/libxml2-$(LIBXML2_VER).tar.gz
	set -e; cd $(BUILD_TMP)/libxml2-$(LIBXML2_VER); \
		$(CONFIGURE) --prefix= \
			--without-python \
			; \
		$(MAKE) ; \
		$(MAKE) install DESTDIR=$(PKGPREFIX)
	cd $(PKGPREFIX)/share && rm -rf doc gtk-doc man
	cp -a $(PKGPREFIX)/* $(TARGETPREFIX)
	mv $(TARGETPREFIX)/bin/xml2-config $(HOSTPREFIX)/bin
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libxml-2.0.pc $(HOSTPREFIX)/bin/xml2-config
	sed -i 's/^\(Libs:.*\)/\1 -lz/' $(PKG_CONFIG_PATH)/libxml-2.0.pc
	$(REWRITE_LIBTOOL)/libxml2.la
	cd $(PKGPREFIX); rm -r [^l]* lib/*[^0-9]
	PKG_VER=$(LIBXML2_VER) \
		PKG_DEP=`opkg-find-requires.sh $(PKGPREFIX)` \
		PKG_PROV=`opkg-find-provides.sh $(PKGPREFIX)` \
		$(OPKG_SH) $(CONTROL_DIR)/libxml2
	$(REMOVE)/libxml2-$(LIBXML2_VER) $(PKGPREFIX)
	touch $@

$(D)/mc: $(ARCHIVE)/mc-$(MC-VER).tar.gz $(D)/libglib $(D)/libncurses | $(TARGETPREFIX) find-autopoint
	$(UNTAR)/mc-$(MC-VER).tar.gz
	set -e; cd $(BUILD_TMP)/mc-$(MC-VER); \
		$(PATCH)/mc-4.6.2.diff; \
		./autogen.sh; \
		$(BUILDENV) \
		CFLAGS="$(TARGET_CFLAGS)" \
		CONFIG_SHELL=/bin/bash \
		./configure \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--prefix=/opt/pkg \
			--without-gpm-mouse \
			--with-screen=ncurses \
			--mandir=/.remove \
			--without-x; \
			$(CC) -o src/man2hlp src/man2hlp.c; \
			$(BUILDENV) $(MAKE) all; \
			make install DESTDIR=$(PKGPREFIX)
	rm -rf $(PKGPREFIX)/.remove
	rm -rf $(PKGPREFIX)/opt/pkg/share/locale # who needs localization?
	rm $(PKGPREFIX)/opt/pkg/share/mc/mc.h*.* # mc.hint.*, mc.hlp.*
	$(OPKG_SH) $(CONTROL_DIR)/mc
	$(REMOVE)/mc-$(MC-VER) $(PKGPREFIX)
	touch $@

$(D)/sg3-utils: $(ARCHIVE)/sg3_utils-$(SG3_UTILS-VER).tar.bz2 | $(TARGETPREFIX)
	$(UNTAR)/sg3_utils-$(SG3_UTILS-VER).tar.bz2
	rm -rf $(PKGPREFIX)
	set -e; cd $(BUILD_TMP)/sg3_utils-$(SG3_UTILS-VER); \
		$(CONFIGURE) --prefix= --mandir=/.remove; \
		$(MAKE); \
		make install DESTDIR=$(PKGPREFIX)
	rm -rf $(PKGPREFIX)/.remove $(BUILD_TMP)/pkg-tmp
	cp -a $(PKGPREFIX)/* $(TARGETPREFIX)
	$(REWRITE_LIBTOOL)/libsgutils2.la
	rm -r $(PKGPREFIX)/lib $(PKGPREFIX)/include $(PKGPREFIX)/bin/sg_start
	PKG_VER=$(SG3_UTILS-VER) $(OPKG_SH) $(CONTROL_DIR)/sg3_utils/addon
	rm -r $(PKGPREFIX)/*
	mkdir $(PKGPREFIX)/lib $(PKGPREFIX)/bin
	cp -a $(TARGETPREFIX)/lib/libsgutils2.so.2* $(PKGPREFIX)/lib
	cp -a $(TARGETPREFIX)/bin/sg_start          $(PKGPREFIX)/bin
	PKG_VER=$(SG3_UTILS-VER) $(OPKG_SH) $(CONTROL_DIR)/sg3_utils/base
	$(REMOVE)/sg3_utils-$(SG3_UTILS-VER) $(PKGPREFIX)
	touch $@

# the following libs are built static only for now, as they
# have only one user (lcd4linux) yet => no opkg package yet, either.
# libiconv libusb libusb-compat libgd2
$(D)/libiconv: $(ARCHIVE)/libiconv-$(ICONV-VER).tar.gz | $(TARGETPREFIX)
	$(UNTAR)/libiconv-$(ICONV-VER).tar.gz
	set -e; cd $(BUILD_TMP)/libiconv-$(ICONV-VER); \
		$(CONFIGURE) --target=$(TARGET) --enable-static --disable-shared \
			--prefix= --datarootdir=/.remove --bindir=/.remove ; \
		$(MAKE) ; \
		make install DESTDIR=$(TARGETPREFIX)
	rm -rf $(TARGETPREFIX)/.remove
	rm -rf $(TARGETPREFIX)/lib/preloadable_libiconv.so
	$(REWRITE_LIBTOOL)/libiconv.la
	$(REMOVE)/libiconv-$(ICONV-VER)
	touch $@

$(D)/libusb: $(ARCHIVE)/libusb-1.0.8.tar.bz2 | $(TARGETPREFIX)
	$(UNTAR)/libusb-1.0.8.tar.bz2
	set -e; cd $(BUILD_TMP)/libusb-1.0.8; \
		$(CONFIGURE) --prefix= --enable-static --disable-shared ; \
		$(MAKE) ; \
		make install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_LIBTOOL)/libusb-1.0.la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libusb-1.0.pc
	$(REMOVE)/libusb-1.0.8
	touch $@

$(D)/libusb-compat: $(ARCHIVE)/libusb-compat-0.1.3.tar.bz2 $(D)/libusb | $(TARGETPREFIX)
	$(UNTAR)/libusb-compat-0.1.3.tar.bz2
	set -e; cd $(BUILD_TMP)/libusb-compat-0.1.3; \
		$(CONFIGURE) --prefix= --enable-static --disable-shared ; \
		$(MAKE) ; \
		make install DESTDIR=$(TARGETPREFIX)
	rm -f $(TARGETPREFIX)/bin/libusb-config
	$(REWRITE_LIBTOOL)/libusb.la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libusb.pc
	$(REMOVE)/libusb-compat-0.1.3
	touch $@

$(D)/libgd2: $(D)/zlib $(D)/libpng $(D)/libjpeg $(D)/freetype $(D)/libiconv $(ARCHIVE)/gd-2.0.35.tar.gz | $(TARGETPREFIX)
	$(UNTAR)/gd-2.0.35.tar.gz
	set -e; cd $(BUILD_TMP)/gd/2.0.35; \
		chmod 0755 configure; \
		: autoreconf -fi; \
		$(CONFIGURE) --prefix= --enable-static --disable-shared --bindir=/.remove; \
		$(MAKE); \
		make install DESTDIR=$(TARGETPREFIX)
	rm -rf $(TARGETPREFIX)/.remove
	$(REWRITE_LIBTOOL)/libgd.la
	$(REMOVE)/gd
	touch $@

LCD4LINUXREV=1171
DPFHACK_DIR=makefu-dpfhack_pearl-c66acd3
$(ARCHIVE)/lcd4linux-r$(LCD4LINUXREV).tar.gz:
	set -e; cd $(BUILD_TMP); \
		rm -rf lcd4linux-r$(LCD4LINUXREV); \
		svn co -r$(LCD4LINUXREV) https://ssl.bulix.org/svn/lcd4linux/trunk lcd4linux-r$(LCD4LINUXREV); \
		tar cvpzf $@ lcd4linux-r$(LCD4LINUXREV)
	$(REMOVE)/lcd4linux-r$(LCD4LINUXREV)

# ugly hack to build / link against libdpf, but installing into TARGETPREFIX
# does not make sense as it is only linked statically anyway.
$(D)/lcd4linux: $(D)/libusb-compat $(D)/libgd2 $(ARCHIVE)/dpfhack_pearl.zip $(ARCHIVE)/lcd4linux-r$(LCD4LINUXREV).tar.gz| $(TARGETPREFIX)
	$(REMOVE)/lcd4linux-r$(LCD4LINUXREV) $(PKGPREFIX)
	$(UNTAR)/lcd4linux-r$(LCD4LINUXREV).tar.gz
	unzip $(ARCHIVE)/dpfhack_pearl.zip -d $(BUILD_TMP)/lcd4linux-r$(LCD4LINUXREV)
	ln -s $(DPFHACK_DIR)/dpflib $(BUILD_TMP)/lcd4linux-r$(LCD4LINUXREV)/
	set -e; cd $(BUILD_TMP)/lcd4linux-r$(LCD4LINUXREV)/$(DPFHACK_DIR) ; \
		$(PATCH)/dpflib-crossbuild.diff; \
		cp -a include/* dpflib/ ; \
		cd $(BUILD_TMP)/lcd4linux-r$(LCD4LINUXREV)/dpflib ; \
		$(BUILDENV) LDFLAGS="-Wl,-rpath-link,$(TARGETLIB) -L$(TARGETLIB)" \
			make CC=$(TARGET)-gcc; \
		ln -s . libdpf; ln -s dpf.h libdpf.h; \
	set -e; cd $(BUILD_TMP)/lcd4linux-r$(LCD4LINUXREV); \
		$(PATCH)/lcd4linux-svn1171-dpf.patch; \
		$(BUILD_ENV) ./bootstrap; \
		DPF_LDFLAGS="-L./dpflib" \
		$(BUILDENV) CFLAGS="$(TARGET_CFLAGS) -I./dpflib" ./configure $(CONFIGURE_OPTS) \
			--prefix= \
			--with-drivers='DPF' \
			--with-plugins='all,!dbus,!mpris_dbus,!asterisk,!isdn,!pop3,!ppp,!seti,!huawei,!imon,!kvv,!sample,!w1retap,!wireless,!xmms,!gps,!mpd,!mysql,!qnaplog' \
			--without-ncurses; \
		$(MAKE) all; \
		make install DESTDIR=$(PKGPREFIX)/opt/pkg
	install -D -m 600 $(SCRIPTS)/lcd4linux.conf $(PKGPREFIX)/opt/pkg/etc/lcd4linux.conf
	PKG_VER=0.10.9999.r$(LCD4LINUXREV) $(OPKG_SH) $(CONTROL_DIR)/lcd4linux
	$(REMOVE)/lcd4linux-r$(LCD4LINUXREV) $(PKGPREFIX)
	touch $@

GRAPHLCD_OBJDIR=$(BUILD_TMP)/graphlcd-base-touchcol
GRAPHLCD_ARCHIVE=$(ARCHIVE)/graphlcd-base-touchcol.tar.gz

#$(ARCHIVE)/graphlcd-base-touchcol.tar.gz:
#	cd $(BUILD_TMP) && \
#	rm -rf graphlcd-base-touchcol && \
#	git clone git://projects.vdr-developer.org/graphlcd-base.git -b touchcol graphlcd-base-touchcol && \
#	cd graphlcd-base-touchcol && \
#	git checkout a39f265732d0bc28cb66b58b5ecf1964a130d02b && \
#	tar -C $(BUILD_TMP) -zcf $@ graphlcd-base-touchcol && \
#	$(PATCH)/graphlcd.patch

$(D)/graphlcd-base-touchcol: $(ARCHIVE)/graphlcd-base-$(GRAPHLCD_VER).tar.gz libusb-compat | $(TARGETPREFIX)
	-$(REMOVE)/graphlcd-base-$(GRAPHLCD_VER) $(PKGPREFIX)
	set -e ; $(UNTAR)/graphlcd-base-$(GRAPHLCD_VER).tar.gz ;\
	cd $(BUILD_TMP)/graphlcd-base-$(GRAPHLCD_VER) ;\
	$(PATCH)/graphlcd.patch ;\
	$(MAKE) -C glcdgraphics all TARGET=$(TARGET)- ;\
	$(MAKE) -C glcddrivers all TARGET=$(TARGET)- ;\
	$(MAKE) -C glcdgraphics install DESTDIR=$(TARGETPREFIX) ;\
	$(MAKE) -C glcddrivers install DESTDIR=$(TARGETPREFIX) ;\
	cd $(BUILD_TMP) ;\
	mkdir -p $(PKGPREFIX)/lib ;\
	cp -a $(TARGETPREFIX)/lib/libglcd{drivers,graphics}* $(PKGPREFIX)/lib ;\
	PKG_VER=2.1 $(OPKG_SH) $(CONTROL_DIR)/graphlcd-base-touchcol ;\
	$(REMOVE)/graphlcd-base-$(GRAPHLCD_VER) $(PKGPREFIX) ;\
	touch $(D)/graphlcd-base-touchcol

$(D)/alsa-lib: $(ARCHIVE)/alsa-lib-$(ALSA_VER).tar.bz2 | $(TARGETPREFIX)
	$(UNTAR)/alsa-lib-$(ALSA_VER).tar.bz2
	rm -rf $(PKGPREFIX)
	set -e; cd $(BUILD_TMP)/alsa-lib-$(ALSA_VER); \
		$(CONFIGURE) --prefix= --mandir=/.remove --disable-aload --disable-rawmidi --disable-python --disable-old-symbols --disable-alisp --disable-ucm --disable-hwdep ;\
		$(MAKE); \
		make install DESTDIR=$(PKGPREFIX)
	rm -rf $(PKGPREFIX)/.remove $(BUILD_TMP)/pkg-tmp
	cp -a $(PKGPREFIX)/* $(TARGETPREFIX)
	rm -rf $(PKGPREFIX)/bin $(PKGPREFIX)/include $(PKGPREFIX)/share/aclocal $(PKGPREFIX)/lib/alsa-lib $(PKGPREFIX)/share/alsa/cards $(PKGPREFIX)/share/alsa/pcm $(PKGPREFIX)/share/alsa/alsa.conf.d
	PKG_VER=$(ALSA_VER) $(OPKG_SH) $(CONTROL_DIR)/alsa-lib
	$(REMOVE)/alsa-lib-$(ALSA_VER) $(PKGPREFIX)
	touch $@

$(D)/alsa-utils: $(ARCHIVE)/alsa-utils-$(ALSA_VER).tar.bz2 $(D)/alsa-lib | $(TARGETPREFIX)
	$(UNTAR)/alsa-utils-$(ALSA_VER).tar.bz2
	rm -rf $(PKGPREFIX)
	set -e; cd $(BUILD_TMP)/alsa-utils-$(ALSA_VER); \
	cp $(PATCHES)/alsa-utils-1.0.25-Makefile.am  Makefile.am ; \
	$(CONFIGURE) --prefix= --mandir=/.remove --disable-nls --disable-alsatest --disable-alsaconf --disable-alsaloop --disable-alsamixer --disable-xmlto ;\
	$(MAKE); \
	make install DESTDIR=$(PKGPREFIX)
	rm -rf $(PKGPREFIX)/.remove $(BUILD_TMP)/pkg-tmp
	cp -a $(PKGPREFIX)/* $(TARGETPREFIX)
	rm -rf $(PKGPREFIX)/var $(PKGPREFIX)/share $(PKGPREFIX)/lib/pkgconfig
	PKG_VER=$(ALSA_VER) $(OPKG_SH) $(CONTROL_DIR)/alsa-utils
	$(REMOVE)/alsa-utils-$(ALSA_VER) $(PKGPREFIX)
	touch $@

$(D)/usb-modeswitch-data: $(ARCHIVE)/usb-modeswitch-data-$(USB_MODESWITCH_DATA_VER).tar.bz2 | $(TARGETPREFIX)
	$(UNTAR)/usb-modeswitch-data-$(USB_MODESWITCH_DATA_VER).tar.bz2
	rm -rf $(PKGPREFIX)
	cd $(BUILD_TMP)/usb-modeswitch-data-$(USB_MODESWITCH_DATA_VER) && \
	make install DESTDIR=$(PKGPREFIX) && \
	cp -a $(PKGPREFIX)/* $(TARGETPREFIX) && \
	PKG_VER=$(USB_MODESWITCH_DATA_VER) $(OPKG_SH) $(CONTROL_DIR)/usb-modeswitch-data && \
	$(REMOVE)/usb-modeswitch-data-$(USB_MODESWITCH_DATA_VER) $(PKGPREFIX)
	touch $@

# Untested, experimental, requires some effort to work with mdev, see
# http://pastebin.com/eU69figK and http://pastebin.com/1Rb1KdXB
# for examples. I've no way to test this, and I don't know where those
# scripts come from.
# Requires http://www.sakis3g.org/versions/latest/sakis3g-source.tar.bz2
# or similar.
#   --martii
$(D)/usb-modeswitch: $(ARCHIVE)/usb-modeswitch-$(USB_MODESWITCH_VER).tar.bz2 $(D)/usb-modeswitch-data | $(TARGETPREFIX)
	$(UNTAR)/usb-modeswitch-$(USB_MODESWITCH_VER).tar.bz2
	rm -rf $(PKGPREFIX)
	cd $(BUILD_TMP)/usb-modeswitch-$(USB_MODESWITCH_VER) && \
	sed -i -e "s/= gcc/= $(TARGET)-gcc/" -e "s/-l usb/-lusb -lusb-1.0 -lpthread -lrt/" -e "s/install -D -s/install -D --strip-program=$(TARGET)-strip -s/" Makefile &&  \
	sed -i -e "s/^gcc /$(TARGET)-gcc /" -e "s/^strip /$(TARGET)-strip /" make_static_dispatcher.sh && \
	sed -i -e "s/@CC@/$(TARGET)-gcc/g" jim/Makefile.in && \
	$(BUILDENV) $(MAKE) DESTDIR=$(PKGPREFIX) install-static && \
	cp -a $(PKGPREFIX)/* $(TARGETPREFIX) && \
	PKG_VER=$(USB_MODESWITCH_VER) $(OPKG_SH) $(CONTROL_DIR)/usb-modeswitch && \
	$(REMOVE)/usb-modeswitch-$(USB_MODESWITCH_VER) $(PKGPREFIX)
	touch $@

$(D)/ppp: $(ARCHIVE)/ppp-$(PPP_VER).tar.gz | $(TARGETPREFIX)
	rm -rf $(PKGPREFIX) $(BUILD_TMP)/ppp-$(PPP_VER)
	$(UNTAR)/ppp-$(PPP_VER).tar.gz
	cd $(BUILD_TMP)/ppp-$(PPP_VER) && \
	zcat $(PATCHES)/ppp-$(PPP_DIFF_VER).diff.gz | patch -p1 && \
	for m in configure `find . -name Makefile\*` ; do echo $$m ; sed -i -e "s#/usr/local##g" -e "s#(INSTALL) -s#(INSTALL) --strip-program=$(TARGET)-strip -s#" $$m ; done ; \
	$(BUILDENV) ./configure && make INSTROOT=$(TARGETPREFIX) CC=$(TARGET)-gcc all install && \
	mkdir -p $(PKGPREFIX)/sbin && cp $(TARGETPREFIX)/sbin/pppd $(TARGETPREFIX)/sbin/pppstats $(TARGETPREFIX)/sbin/chat $(PKGPREFIX)/sbin && \
	PKG_VER=$(PPP_VER) $(OPKG_SH) $(CONTROL_DIR)/ppp && \
	$(REMOVE)/ppp-$(PPP_VER) $(PKGPREFIX) \
	touch $@

