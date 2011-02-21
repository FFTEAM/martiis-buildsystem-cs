# Makefile to build system tools

$(D)/vsftpd: $(ARCHIVE)/vsftpd-$(VSFTPD-VER).tar.gz | $(TARGETPREFIX)
	$(UNTAR)/vsftpd-$(VSFTPD-VER).tar.gz
	rm -rf $(PKGPREFIX)
	cd $(BUILD_TMP)/vsftpd-$(VSFTPD-VER) && \
		$(PATCH)/vsftpd.diff && \
		TARGETPREFIX=$(TARGETPREFIX) make CC=$(TARGET)-gcc CFLAGS="-pipe -O2 -g0 -I$(TARGETPREFIX)/include" LDFLAGS="$(LD_FLAGS)"
	install -d $(PKGPREFIX)/share/empty
	install -D -m 755 $(BUILD_TMP)/vsftpd-$(VSFTPD-VER)/vsftpd $(PKGPREFIX)/opt/pkg/sbin/vsftpd
	install -D -m 644 $(SCRIPTS)/vsftpd.conf $(PKGPREFIX)/opt/pkg/etc/vsftpd.conf
	install -D -m 755 $(SCRIPTS)/vsftpd.init $(PKGPREFIX)/opt/pkg/etc/init.d/vsftpd
	# it is important that vsftpd is started *before* inetd to override busybox ftpd...
	ln -sf vsftpd $(PKGPREFIX)/opt/pkg/etc/init.d/S80vsftpd
	cp -a $(PKGPREFIX)/* $(TARGETPREFIX)/
	$(OPKG_SH) $(CONTROL_DIR)/vsftpd
	$(REMOVE)/vsftpd-$(VSFTPD-VER) $(PKGPREFIX)
	touch $@

$(D)/rsync: $(ARCHIVE)/rsync-$(RSYNC-VER).tar.gz | $(TARGETPREFIX)
	$(UNTAR)/rsync-$(RSYNC-VER).tar.gz
	rm -rf $(PKGPREFIX)
	pushd $(BUILD_TMP)/rsync-$(RSYNC-VER) && \
		$(CONFIGURE) --prefix= --build=$(BUILD) --host=$(TARGET) --mandir=$(BUILD_TMP)/.remove && \
		$(MAKE) all && \
		make install prefix=$(PKGPREFIX)
	$(REMOVE)/rsync-$(RSYNC-VER) $(BUILD_TMP)/.remove
	install -D -m 0755 $(SCRIPTS)/rsyncd.init $(PKGPREFIX)/etc/init.d/rsyncd
	ln -sf rsyncd $(PKGPREFIX)/etc/init.d/K40rsyncd
	ln -sf rsyncd $(PKGPREFIX)/etc/init.d/S60rsyncd
	cp -a $(PKGPREFIX)/* $(TARGETPREFIX)
	cd $(TARGETPREFIX)/etc && { \
		test -e rsyncd.conf    || cp $(SCRIPTS)/rsyncd.conf . ; \
		test -e rsyncd.secrets || cp $(SCRIPTS)/rsyncd.secrets . ; }; true
	cp -a $(SCRIPTS)/rsyncd.{conf,secrets} $(PKGPREFIX)/etc
	$(OPKG_SH) $(CONTROL_DIR)/rsync
	rm -rf $(PKGPREFIX)
	touch $@

$(D)/procps: $(D)/libncurses $(ARCHIVE)/procps-$(PROCPS-VER).tar.gz | $(TARGETPREFIX)
	$(UNTAR)/procps-$(PROCPS-VER).tar.gz
	pushd $(BUILD_TMP)/procps-$(PROCPS-VER) && \
		$(PATCH)/procps-3.2.8-avoid-ICE-with-gcc-4.3.2-arm.diff && \
		$(PATCH)/procps-3.2.8-fix-unknown-HZ-compatible.diff && \
		make CC=$(TARGET)-gcc LDFLAGS="$(LD_FLAGS)" \
			CPPFLAGS="-pipe -O2 -g -I$(TARGETPREFIX)/include -I$(TARGETPREFIX)/include/ncurses -D__GNU_LIBRARY__" proc/libproc-$(PROCPS-VER).so && \
		make CC=$(TARGET)-gcc LDFLAGS="$(LD_FLAGS) proc/libproc-$(PROCPS-VER).so" \
			CPPFLAGS="-pipe -O2 -g -I$(TARGETPREFIX)/include -I$(TARGETPREFIX)/include/ncurses -D__GNU_LIBRARY__" top ps/ps && \
		mkdir -p $(TARGETPREFIX)/bin && \
		rm -f $(TARGETPREFIX)/bin/ps $(TARGETPREFIX)/bin/top && \
		install -m 755 top ps/ps $(TARGETPREFIX)/bin && \
		install -m 755 proc/libproc-$(PROCPS-VER).so $(TARGETPREFIX)/lib
	$(REMOVE)/procps-$(PROCPS-VER) $(PKGPREFIX)
	mkdir -p $(PKGPREFIX)/lib $(PKGPREFIX)/bin
	cp -a $(TARGETPREFIX)/bin/{ps,top} $(PKGPREFIX)/bin
	cp -a $(TARGETPREFIX)/lib/libproc-$(PROCPS-VER).so $(PKGPREFIX)/lib
	$(OPKG_SH) $(CONTROL_DIR)/procps
	rm -rf $(PKGPREFIX)
	touch $@

$(D)/busybox: $(ARCHIVE)/busybox-$(BUSYBOX-VER).tar.bz2 | $(TARGETPREFIX)
	$(UNTAR)/busybox-$(BUSYBOX-VER).tar.bz2
	rm -rf $(PKGPREFIX) $(BUILD_TMP)/bb-control
	cd $(BUILD_TMP)/busybox-$(BUSYBOX-VER) && \
		$(PATCH)/busybox-1.18.3-fix-libiproute-compile-with-kernel-headers-2.6.17.patch && \
		cp $(PATCHES)/busybox-$(BUSYBOX-VER).config .config && \
		sed -i -e 's#^CONFIG_PREFIX.*#CONFIG_PREFIX="$(PKGPREFIX)"#' .config && \
		grep -q DBB_BT=AUTOCONF_TIMESTAMP Makefile.flags && \
		sed -i 's#AUTOCONF_TIMESTAMP#"\\"$(PLATFORM)\\""#' Makefile.flags && \
		$(MAKE) all  CROSS_COMPILE=$(TARGET)- CFLAGS_EXTRA="$(TARGET_CFLAGS)" && \
		make install CROSS_COMPILE=$(TARGET)- CFLAGS_EXTRA="$(TARGET_CFLAGS)"
	install -m 0755 $(SCRIPTS)/run-parts $(PKGPREFIX)/bin
	cp -a $(PKGPREFIX)/* $(TARGETPREFIX)
	cp -a $(CONTROL_DIR)/busybox $(BUILD_TMP)/bb-control
	# "auto-provides/conflicts". let's hope opkg can deal with this...
	printf "Provides:" >> $(BUILD_TMP)/bb-control/control
	for i in `find $(PKGPREFIX)/ ! -type d ! -name busybox`; do printf " `basename $$i`," >> $(BUILD_TMP)/bb-control/control; done
	sed -i "s/@VER@/$(BUSYBOX-VER)/" $(BUILD_TMP)/bb-control/control
	sed -i 's/,$$//' $(BUILD_TMP)/bb-control/control
	sed -i 's/\(^Provides:\)\(.*$$\)/\1\2\nConflicts:\2/' $(BUILD_TMP)/bb-control/control
	echo >> $(BUILD_TMP)/bb-control/control
	$(OPKG_SH) $(BUILD_TMP)/bb-control
	$(REMOVE)/busybox-$(BUSYBOX-VER) $(PKGPREFIX) $(BUILD_TMP)/bb-control
	touch $@

# experimental
$(D)/busybox-snapshot: $(ARCHIVE)/busybox-snapshot.tar.bz2 | $(TARGETPREFIX)
	$(UNTAR)/busybox-snapshot.tar.bz2
	pushd $(BUILD_TMP)/busybox && \
		cp $(PATCHES)/busybox-hd1-snapshot.config .config && \
		sed -i -e 's#^CONFIG_PREFIX.*#CONFIG_PREFIX="$(TARGETPREFIX)"#' .config && \
		$(MAKE) all  CROSS_COMPILE=$(TARGET)- CFLAGS_EXTRA="$(TARGET_CFLAGS)" && \
		make install CROSS_COMPILE=$(TARGET)- CFLAGS_EXTRA="$(TARGET_CFLAGS)"
	$(REMOVE)/busybox
	touch $@

$(D)/e2fsprogs: $(ARCHIVE)/e2fsprogs-$(E2FSPROGS-VER).tar.gz | $(TARGETPREFIX)
	rm -rf $(PKGPREFIX)
	$(UNTAR)/e2fsprogs-$(E2FSPROGS-VER).tar.gz
	cd $(BUILD_TMP)/e2fsprogs-$(E2FSPROGS-VER) && \
		ln -sf /bin/true ./ldconfig && \
		CC=$(TARGET)-gcc \
		RANLIB=$(TARGET)-ranlib \
		CFLAGS="-Os -msoft-float" \
		PATH=$(BUILD_TMP)/e2fsprogs-$(E2FSPROGS-VER):$(PATH) \
		./configure \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--target=$(TARGET) \
			--prefix=/ \
			--infodir=/.remove \
			--mandir=/.remove \
			--enable-elf-shlibs \
			--enable-htree \
			--disable-profile \
			--disable-e2initrd-helper \
			--disable-debugfs \
			--disable-imager \
			--disable-resizer \
			--disable-uuidd \
			--disable-fsck \
			--with-gnu-ld \
			--enable-symlink-install \
			--disable-nls && \
		$(MAKE) && \
		$(MAKE) install DESTDIR=$(PKGPREFIX) && \
		$(MAKE) -C lib/uuid  install DESTDIR=$(PKGPREFIX) && \
		$(MAKE) -C lib/blkid install DESTDIR=$(PKGPREFIX) && \
		:
	$(REMOVE)/e2fsprogs-$(E2FSPROGS-VER) $(PKGPREFIX)/.remove
	cp -a --remove-destination $(PKGPREFIX)/* $(TARGETPREFIX)/
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/uuid.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/blkid.pc
	cd $(PKGPREFIX) && rm sbin/badblocks sbin/dumpe2fs sbin/blkid sbin/logsave \
		sbin/e2undo sbin/filefrag sbin/e2freefrag bin/chattr bin/lsattr bin/uuidgen \
		lib/*.so && rm -r lib/pkgconfig include && rm -f lib/*.a
	$(OPKG_SH) $(CONTROL_DIR)/e2fsprogs
	rm -rf $(PKGPREFIX)
	touch $@

$(TARGETPREFIX)/lib/libuuid.so.1:
	@echo
	@echo "to build libuuid.so.1, you have to build either the 'e2fsprogs'"
	@echo "or the 'libuuid' target. Using 'e2fsprogs' is recommended."
	@echo
	@false

$(D)/xfsprogs: $(ARCHIVE)/xfsprogs-$(XFSPROGS-VER).tar.gz | $(TARGETPREFIX) $(TARGETPREFIX)/lib/libuuid.so.1
	$(UNTAR)/xfsprogs-$(XFSPROGS-VER).tar.gz
	cd $(BUILD_TMP)/xfsprogs-$(XFSPROGS-VER) && \
		$(BUILDENV) root_libdir=/opt/xfsprogs/lib root_sbindir=/opt/xfsprogs/sbin \
		./configure \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--includedir=$(TARGETPREFIX)/include \
			--oldincludedir=$(TARGETPREFIX)/include \
			--enable-gettext=no \
			--datarootdir=/.remove \
			--prefix=/opt/xfsprogs && \
		LCFLAGS=-I$(TARGETPREFIX)/include $(MAKE) V=1 && \
		DIST_ROOT=$(TARGETPREFIX) $(MAKE) install
	rm -rf $(TARGETPREFIX)/.remove
	$(REMOVE)/xfsprogs-$(XFSPROGS-VER)
	touch $@

$(D)/ntfs-3g: $(ARCHIVE)/ntfs-3g-$(NTFS_3G-VER).tgz | $(TARGETPREFIX)
	$(UNTAR)/ntfs-3g-$(NTFS_3G-VER).tgz
	cd $(BUILD_TMP)/ntfs-3g-$(NTFS_3G-VER) && \
		$(BUILDENV) ./configure \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--prefix= \
			--mandir=/.remove \
			--docdir=/.remove \
			--disable-ldconfig \
			--disable-static \
			&& \
		$(MAKE) && \
		make install DESTDIR=$(PKGPREFIX)
	$(REMOVE)/ntfs-3g-$(NTFS_3G-VER) $(PKGPREFIX)/.remove
	cp -a $(PKGPREFIX)/* $(TARGETPREFIX)
	rm -r $(PKGPREFIX)/include $(PKGPREFIX)/lib/*.la $(PKGPREFIX)/lib/*.so \
		$(PKGPREFIX)/lib/pkgconfig/ $(PKGPREFIX)/bin/ntfs-3g.{usermap,secaudit}
	find $(PKGPREFIX) -name '*lowntfs*' | xargs rm
	$(OPKG_SH) $(CONTROL_DIR)/ntfs-3g
	rm -rf $(PKGPREFIX)
	touch $@

$(D)/skeleton: | $(TARGETPREFIX)
	cp --remove-destination -a skel-root/common/* $(TARGETPREFIX)/
	cp --remove-destination -a skel-root/$(PLATFORM)/* $(TARGETPREFIX)/

$(D)/autofs: $(ARCHIVE)/autofs-$(AUTOFS-VER).tar.bz2 | $(TARGETPREFIX)
	$(MAKE) $(TARGETPREFIX)/lib/modules/$(KVERSION_FULL)/kernel/fs/autofs4/autofs4.ko
	rm -rf $(PKGPREFIX)
	$(UNTAR)/autofs-$(AUTOFS-VER).tar.bz2
	cd $(BUILD_TMP)/autofs-$(AUTOFS-VER) && \
		$(PATCH)/autofs-4.1.4-td.diff && \
		$(BUILDENV) $(MAKE) CC=$(TARGET)-gcc STRIP=$(TARGET)-strip SUBDIRS="lib daemon modules"  && \
		$(MAKE) install INSTALLROOT=$(PKGPREFIX) SUBDIRS="lib daemon modules"
	$(REMOVE)/autofs-$(AUTOFS-VER)
	install -m 0755 -D $(SCRIPTS)/autofs.init $(PKGPREFIX)/etc/init.d/autofs
	ln -sf autofs $(PKGPREFIX)/etc/init.d/S60autofs
	ln -sf autofs $(PKGPREFIX)/etc/init.d/K40autofs
	mkdir -p $(PKGPREFIX)/lib/modules/$(KVERSION_FULL)/kernel/fs/autofs4
	cp -a $(TARGETPREFIX)/lib/modules/$(KVERSION_FULL)/kernel/fs/autofs4/autofs4.ko $(PKGPREFIX)/lib/modules/$(KVERSION_FULL)/kernel/fs/autofs4/
	cp -a --remove-destination $(PKGPREFIX)/* $(TARGETPREFIX)/
	$(OPKG_SH) $(CONTROL_DIR)/autofs
	rm -rf $(PKGPREFIX)
	touch $@

$(D)/samba2: $(ARCHIVE)/samba-$(SAMBA2-VER).tar.gz | $(TARGETPREFIX)
	$(UNTAR)/samba-$(SAMBA2-VER).tar.gz
	rm -rf $(PKGPREFIX)
	cd $(BUILD_TMP)/samba-$(SAMBA2-VER) && \
		$(PATCH)/samba_2.2.12.diff && \
		$(PATCH)/samba_2.2.12-noprint.diff && \
		cd source && \
		autoconf configure.in > configure && \
		./configure \
			--build=$(BUILD) \
			--prefix=/opt/pkg \
			samba_cv_struct_timespec=yes \
			samba_cv_HAVE_GETTIMEOFDAY_TZ=yes \
			--with-configdir=/opt/pkg/etc \
			--with-privatedir=/opt/pkg/etc/samba/private \
			--with-lockdir=/var/lock \
			--with-piddir=/var/run \
			--with-logfilebase=/var/log/ \
			--disable-cups \
			--with-swatdir=$(PKGPREFIX)/swat && \
		$(MAKE) clean; \
		$(MAKE) bin/make_smbcodepage bin/make_unicodemap CC=$(CC) && \
		install -d $(PKGPREFIX)/opt/pkg/lib/codepages && \
		./bin/make_smbcodepage c 850 codepages/codepage_def.850 \
			$(PKGPREFIX)/opt/pkg/lib/codepages/codepage.850 && \
		./bin/make_unicodemap 850 codepages/CP850.TXT \
			$(PKGPREFIX)/opt/pkg/lib/codepages/unicode_map.850 && \
		./bin/make_unicodemap ISO8859-1 codepages/CPISO8859-1.TXT \
			$(PKGPREFIX)/opt/pkg/lib/codepages/unicode_map.ISO8859-1
	$(MAKE) -C $(BUILD_TMP)/samba-$(SAMBA2-VER)/source distclean
	cd $(BUILD_TMP)/samba-$(SAMBA2-VER)/source && \
		$(BUILDENV) \
		./configure \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--prefix=/opt/pkg \
			samba_cv_struct_timespec=yes \
			samba_cv_HAVE_GETTIMEOFDAY_TZ=yes \
			samba_cv_HAVE_IFACE_IFCONF=yes \
			samba_cv_HAVE_EXPLICIT_LARGEFILE_SUPPORT=yes \
			samba_cv_HAVE_OFF64_T=yes \
			samba_cv_have_longlong=yes \
			--with-configdir=/opt/pkg/etc \
			--with-privatedir=/opt/pkg/etc/samba/private \
			--with-lockdir=/var/lock \
			--with-piddir=/var/run \
			--with-logfilebase=/var/log/ \
			--disable-cups \
			--with-swatdir=$(PKGPREFIX)/swat
	install -d $(PKGPREFIX)/opt/pkg/bin
	cd $(BUILD_TMP)/samba-$(SAMBA2-VER)/source && \
		$(MAKE) bin/smbd bin/nmbd bin/smbclient bin/smbmount bin/smbmnt bin/smbpasswd
	for i in smbd nmbd; do \
		install $(BUILD_TMP)/samba-$(SAMBA2-VER)/source/bin/$$i $(PKGPREFIX)/opt/pkg/bin; \
	done
	install -d $(PKGPREFIX)/opt/pkg/etc/samba/private
	install -d $(PKGPREFIX)/opt/pkg/etc/init.d
	install $(SCRIPTS)/smb.conf $(PKGPREFIX)/opt/pkg/etc
	install -m 755 $(SCRIPTS)/samba2.init $(PKGPREFIX)/opt/pkg/etc/init.d/samba
	ln -s samba $(PKGPREFIX)/opt/pkg/etc/init.d/S99samba
	ln -s samba $(PKGPREFIX)/opt/pkg/etc/init.d/K01samba
	cp -a $(PKGPREFIX)/* $(TARGETPREFIX)
	$(TARGET)-strip $(PKGPREFIX)/opt/pkg/bin/*
	DONT_STRIP=1 $(OPKG_SH) $(CONTROL_DIR)/samba2/server
	rm -rf $(PKGPREFIX)/*
	install -d $(PKGPREFIX)/opt/pkg/bin
	for i in smbclient smbmount smbmnt smbpasswd; do \
		install $(BUILD_TMP)/samba-$(SAMBA2-VER)/source/bin/$$i $(PKGPREFIX)/opt/pkg/bin; \
	done
	$(OPKG_SH) $(CONTROL_DIR)/samba2/client
	$(REMOVE)/samba-$(SAMBA2-VER) $(PKGPREFIX)
	touch $@

$(D)/portmap: $(ARCHIVE)/portmap-$(PORTMAP-VER).tgz
	$(UNTAR)/portmap-$(PORTMAP-VER).tgz
	cd $(BUILD_TMP)/portmap_$(PORTMAP-VER) && \
		$(PATCH)/portmap_6.0-nocheckport.diff && \
		$(BUILDENV) $(MAKE) NO_TCP_WRAPPER=1 DAEMON_UID=65534 DAEMON_GID=65535 CC="$(TARGET)-gcc" && \
		install -m 0755 portmap $(TARGETPREFIX)/sbin && \
		install -m 0755 pmap_dump $(TARGETPREFIX)/sbin && \
		install -m 0755 pmap_set $(TARGETPREFIX)/sbin
	$(REMOVE)/portmap_$(PORTMAP-VER)
	touch $@

$(D)/unfsd: $(D)/libflex $(D)/portmap $(ARCHIVE)/unfs3-$(UNFS3-VER).tar.gz
	$(UNTAR)/unfs3-$(UNFS3-VER).tar.gz
	cd $(BUILD_TMP)/unfs3-$(UNFS3-VER) && \
		$(CONFIGURE) --build=$(BUILD) --host=$(TARGET) --target=$(TARGET) \
			--prefix= --mandir=/.remove && \
		$(MAKE) && \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	rm -f -r $(TARGETPREFIX)/.remove
	rm -rf $(PKGPREFIX)
	mkdir -p $(PKGPREFIX)/sbin
	install -m 755 -D $(SCRIPTS)/nfsd.init $(TARGETPREFIX)/etc/init.d/nfsd
	install -m 755 -D $(SCRIPTS)/nfsd.init $(PKGPREFIX)/etc/init.d/nfsd
	ln -s nfsd $(PKGPREFIX)/etc/init.d/S99nfsd # needs to start after modules are loaded
	ln -s nfsd $(PKGPREFIX)/etc/init.d/K01nfsd
	cp -a $(TARGETPREFIX)/sbin/{unfsd,portmap} $(PKGPREFIX)/sbin
	$(OPKG_SH) $(CONTROL_DIR)/unfsd
	$(REMOVE)/unfs3-$(UNFS3-VER) $(PKGPREFIX)
	touch $@

fbshot: $(TARGETPREFIX)/bin/fbshot
$(TARGETPREFIX)/bin/fbshot: $(ARCHIVE)/fbshot-$(FBSHOT-VER).tar.gz | $(TARGETPREFIX)
	$(UNTAR)/fbshot-$(FBSHOT-VER).tar.gz
	cd $(BUILD_TMP)/fbshot-$(FBSHOT-VER) && \
		$(PATCH)/fbshot-0.3-32bit_cs_fb.diff && \
		$(TARGET)-gcc $(TARGET_CFLAGS) $(TARGET_LDFLAGS) fbshot.c -lpng -lz -o $@
	$(REMOVE)/fbshot-$(FBSHOT-VER)

system-tools: $(D)/rsync $(D)/procps $(D)/busybox $(D)/e2fsprogs
system-tools-opt: $(D)/samba2 $(D)/xfsprogs $(D)/vsftpd
system-tools-all: system-tools system-tools-opt

PHONY += system-tools system-tools-opt system-tools-all
