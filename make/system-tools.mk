# Makefile to build system tools

$(D)/vsftpd: $(ARCHIVE)/vsftpd-$(VSFTPD_VER).tar.gz | $(TARGETPREFIX)
	$(UNTAR)/vsftpd-$(VSFTPD_VER).tar.gz
	rm -rf $(PKGPREFIX)
	set -e; cd $(BUILD_TMP)/vsftpd-$(VSFTPD_VER); \
		$(PATCH)/vsftpd.diff; \
		make clean; \
		TARGETPREFIX=$(TARGETPREFIX) make CC=$(TARGET)-gcc CFLAGS="-pipe -O2 -g0 -I$(TARGETPREFIX)/include" LDFLAGS="$(LD_FLAGS) -lcrypt -Wl,-rpath-link,$(TARGETLIB)"
	install -d $(PKGPREFIX)/share/empty
	install -D -m 755 $(BUILD_TMP)/vsftpd-$(VSFTPD_VER)/vsftpd $(PKGPREFIX)/opt/pkg/sbin/vsftpd
	install -D -m 644 $(SCRIPTS)/vsftpd.conf $(PKGPREFIX)/opt/pkg/etc/vsftpd.conf
	install -D -m 755 $(SCRIPTS)/vsftpd.init $(PKGPREFIX)/opt/pkg/etc/init.d/vsftpd
	# it is important that vsftpd is started *before* inetd to override busybox ftpd...
	ln -sf vsftpd $(PKGPREFIX)/opt/pkg/etc/init.d/S53vsftpd
	cp -a $(PKGPREFIX)/* $(TARGETPREFIX)/
	$(OPKG_SH) $(CONTROL_DIR)/vsftpd
	$(REMOVE)/vsftpd-$(VSFTPD_VER) $(PKGPREFIX)
	touch $@

$(D)/rsync: $(ARCHIVE)/rsync-$(RSYNC-VER).tar.gz | $(TARGETPREFIX)
	$(UNTAR)/rsync-$(RSYNC-VER).tar.gz
	rm -rf $(PKGPREFIX)
	set -e; cd $(BUILD_TMP)/rsync-$(RSYNC-VER); \
		$(CONFIGURE) --prefix= --build=$(BUILD) --host=$(TARGET) --mandir=$(BUILD_TMP)/.remove; \
		$(MAKE) all; \
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
	set -e; cd $(BUILD_TMP)/procps-$(PROCPS-VER); \
		$(PATCH)/procps-3.2.8-avoid-ICE-with-gcc-4.3.2-arm.diff; \
		$(PATCH)/procps-3.2.8-fix-unknown-HZ-compatible.diff; \
		make CC=$(TARGET)-gcc LDFLAGS="$(LD_FLAGS)" \
			CPPFLAGS="-pipe -O2 -g -I$(TARGETPREFIX)/include -I$(TARGETPREFIX)/include/ncurses -D__GNU_LIBRARY__" proc/libproc-$(PROCPS-VER).so; \
		make CC=$(TARGET)-gcc LDFLAGS="$(LD_FLAGS) proc/libproc-$(PROCPS-VER).so" \
			CPPFLAGS="-pipe -O2 -g -I$(TARGETPREFIX)/include -I$(TARGETPREFIX)/include/ncurses -D__GNU_LIBRARY__" top ps/ps; \
		mkdir -p $(TARGETPREFIX)/bin; \
		rm -f $(TARGETPREFIX)/bin/ps $(TARGETPREFIX)/bin/top; \
		install -m 755 top ps/ps $(TARGETPREFIX)/bin; \
		install -m 755 proc/libproc-$(PROCPS-VER).so $(TARGETPREFIX)/lib
	$(REMOVE)/procps-$(PROCPS-VER) $(PKGPREFIX)
	mkdir -p $(PKGPREFIX)/lib $(PKGPREFIX)/bin
	cp -a $(TARGETPREFIX)/bin/{ps,top} $(PKGPREFIX)/bin
	cp -a $(TARGETPREFIX)/lib/libproc-$(PROCPS-VER).so $(PKGPREFIX)/lib
	$(OPKG_SH) $(CONTROL_DIR)/procps
	rm -rf $(PKGPREFIX)
	touch $@

$(D)/busybox: $(D)/busybox-$(BUSYBOX_VER)
$(D)/busybox-$(BUSYBOX_VER): $(ARCHIVE)/busybox-$(BUSYBOX_VER).tar.bz2 $(PATCHES)/busybox-$(BUSYBOX_REL).config | $(TARGETPREFIX)
	$(UNTAR)/busybox-$(BUSYBOX_VER).tar.bz2
	rm -rf $(PKGPREFIX) $(BUILD_TMP)/bb-control
	set -e; cd $(BUILD_TMP)/busybox-$(BUSYBOX_VER); \
		$(PATCH)/busybox-1.18-hack-init-s-console.patch; \
		$(PATCH)/busybox-$(BUSYBOX_VER)-revert-broken-sighandling.patch; \
		$(PATCH)/busybox-$(BUSYBOX_VER)-mdev-firmware-loading.diff; \
		$(PATCH)/busybox-$(BUSYBOX_VER)-mdev-increase-timeout.diff; \
		test x"$(BUSYBOX_VER)" = x1.21.1 && \
			$(PATCH)/busybox-1.21.1-udhcpcp-fix-old-kernel.diff || true; \
		test -e $(PATCHES)/busybox-$(BUSYBOX_REL).config.$(PLATFORM) && \
			cp $(PATCHES)/busybox-$(BUSYBOX_REL).config.$(PLATFORM) .config || \
			cp $(PATCHES)/busybox-$(BUSYBOX_REL).config .config; \
		sed -i -e 's#^CONFIG_PREFIX.*#CONFIG_PREFIX="$(PKGPREFIX)"#' .config; \
		grep -q DBB_BT=AUTOCONF_TIMESTAMP Makefile.flags && \
		sed -i 's#AUTOCONF_TIMESTAMP#"\\"$(PLATFORM)\\""#' Makefile.flags || true; \
		$(MAKE) busybox CROSS_COMPILE=$(TARGET)- CFLAGS_EXTRA="$(TARGET_CFLAGS)"; \
		make install CROSS_COMPILE=$(TARGET)- CFLAGS_EXTRA="$(TARGET_CFLAGS)"
	install -m 0755 $(SCRIPTS)/run-parts $(PKGPREFIX)/bin
	cp -a $(PKGPREFIX)/* $(TARGETPREFIX)
	cp -a $(CONTROL_DIR)/busybox $(BUILD_TMP)/bb-control
	# "auto-provides/conflicts". let's hope opkg can deal with this...
	printf "Provides:" >> $(BUILD_TMP)/bb-control/control
	for i in `find $(PKGPREFIX)/ ! -type d ! -name busybox`; do printf " `basename $$i`," >> $(BUILD_TMP)/bb-control/control; done
	sed -i 's/,$$//' $(BUILD_TMP)/bb-control/control
	sed -i 's/\(^Provides:\)\(.*$$\)/\1\2\nConflicts:\2/' $(BUILD_TMP)/bb-control/control
	echo >> $(BUILD_TMP)/bb-control/control
	PKG_VER=$(BUSYBOX_VER) $(OPKG_SH) $(BUILD_TMP)/bb-control
	$(REMOVE)/busybox-$(BUSYBOX_VER) $(PKGPREFIX) $(BUILD_TMP)/bb-control
	touch $@

# experimental
$(D)/busybox-snapshot: $(ARCHIVE)/busybox-snapshot.tar.bz2 | $(TARGETPREFIX)
	$(UNTAR)/busybox-snapshot.tar.bz2
	set -e; pushd $(BUILD_TMP)/busybox; \
		cp $(PATCHES)/busybox-hd1-snapshot.config .config; \
		sed -i -e 's#^CONFIG_PREFIX.*#CONFIG_PREFIX="$(TARGETPREFIX)"#' .config; \
		$(MAKE) all  CROSS_COMPILE=$(TARGET)- CFLAGS_EXTRA="$(TARGET_CFLAGS)"; \
		make install CROSS_COMPILE=$(TARGET)- CFLAGS_EXTRA="$(TARGET_CFLAGS)"
	$(REMOVE)/busybox
	touch $@

$(D)/e2fsprogs: $(ARCHIVE)/e2fsprogs-$(E2FSPROGS-VER).tar.gz | $(TARGETPREFIX)
	rm -rf $(PKGPREFIX)
	$(UNTAR)/e2fsprogs-$(E2FSPROGS-VER).tar.gz
	set -e; cd $(BUILD_TMP)/e2fsprogs-$(E2FSPROGS-VER); \
		ln -sf /bin/true ./ldconfig; \
		CC=$(TARGET)-gcc \
		RANLIB=$(TARGET)-ranlib \
		CFLAGS="-Os" \
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
			--disable-defrag \
			--with-gnu-ld \
			--enable-symlink-install \
			--disable-nls; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(PKGPREFIX); \
		$(MAKE) -C lib/uuid  install DESTDIR=$(PKGPREFIX); \
		$(MAKE) -C lib/blkid install DESTDIR=$(PKGPREFIX); \
		:
	$(REMOVE)/e2fsprogs-$(E2FSPROGS-VER) $(PKGPREFIX)/.remove
	cp -a --remove-destination $(PKGPREFIX)/* $(TARGETPREFIX)/
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/uuid.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/blkid.pc
	cd $(PKGPREFIX) && rm sbin/badblocks sbin/dumpe2fs sbin/blkid sbin/logsave \
		sbin/e2undo sbin/filefrag sbin/e2freefrag bin/chattr bin/lsattr bin/uuidgen \
		lib/*.so && rm -r lib/pkgconfig include && rm -f lib/*.a
	PKG_VER=$(E2FSPROGS-VER) $(OPKG_SH) $(CONTROL_DIR)/e2fsprogs
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
	set -e; cd $(BUILD_TMP)/xfsprogs-$(XFSPROGS-VER); \
		$(BUILDENV) root_libdir=/opt/pkg/lib root_sbindir=/opt/pkg/sbin \
		./configure \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--includedir=$(TARGETPREFIX)/include \
			--oldincludedir=$(TARGETPREFIX)/include \
			--enable-gettext=no \
			--datarootdir=/.remove \
			--prefix=/opt/pkg; \
		LCFLAGS=-I$(TARGETPREFIX)/include $(MAKE) V=1; \
		DIST_ROOT=$(PKGPREFIX) $(MAKE) install
	rm -rf $(PKGPREFIX)/.remove
	cd $(PKGPREFIX)/opt/pkg/sbin; \
		rm xfs_rtcp xfs_mdrestore xfs_estimate xfs_io xfs_mkfile xfs_bmap xfs_freeze \
		   xfs_growfs xfs_info xfs_logprint xfs_copy xfs_ncheck xfs_metadump xfs_quota
	PKG_VER=$(XFSPROGS-VER) \
		PKG_DEP=`opkg-find-requires.sh $(PKGPREFIX)` \
		$(OPKG_SH) $(CONTROL_DIR)/xfsprogs
	$(REMOVE)/xfsprogs-$(XFSPROGS-VER) $(PKGPREFIX)
	touch $@

$(D)/ntfs-3g: $(ARCHIVE)/ntfs-3g_ntfsprogs-$(NTFS_3G_VER).tgz $(PATCHES)/.rebuild.ntfs-3g | $(TARGETPREFIX)
	$(UNTAR)/ntfs-3g_ntfsprogs-$(NTFS_3G_VER).tgz
	set -e; cd $(BUILD_TMP)/ntfs-3g_ntfsprogs-$(NTFS_3G_VER); \
		CFLAGS="-pipe -O2 -g" ./configure \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--prefix= \
			--mandir=/.remove \
			--docdir=/.remove \
			--disable-ldconfig \
			--disable-ntfsprogs \
			--disable-static \
			; \
		$(MAKE); \
		make install DESTDIR=$(PKGPREFIX)
	$(REMOVE)/ntfs-3g_ntfsprogs-$(NTFS_3G_VER) $(PKGPREFIX)/.remove
	cp -a $(PKGPREFIX)/* $(TARGETPREFIX)
	rm -r $(PKGPREFIX)/include $(PKGPREFIX)/lib/*.la $(PKGPREFIX)/lib/*.so \
		$(PKGPREFIX)/lib/pkgconfig/ $(PKGPREFIX)/bin/ntfs-3g.{usermap,secaudit}
	find $(PKGPREFIX) -name '*lowntfs*' | xargs rm
	PKG_VER=$(NTFS_3G_VER) \
		PKG_PROV=`opkg-find-provides.sh $(PKGPREFIX)` \
		$(OPKG_SH) $(CONTROL_DIR)/ntfs-3g
	rm -rf $(PKGPREFIX)
	touch $@

$(D)/skeleton: | $(TARGETPREFIX)
	cp --remove-destination -a skel-root/common/* $(TARGETPREFIX)/
	cp --remove-destination -a skel-root/$(PLATFORM)/* $(TARGETPREFIX)/

$(D)/autofs: $(ARCHIVE)/autofs-$(AUTOFS-VER).tar.gz | $(TARGETPREFIX)
	if ! grep -q CONFIG_AUTOFS4_FS=y $(K_OBJ)/.config; then \
		$(MAKE) $(TARGETPREFIX)/lib/modules/$(KVERSION_FULL)/kernel/fs/autofs4/autofs4.ko; fi
	rm -rf $(PKGPREFIX)
	$(UNTAR)/autofs-$(AUTOFS-VER).tar.gz
	set -e; cd $(BUILD_TMP)/autofs-$(AUTOFS-VER); \
		$(PATCH)/autofs-4.1.4-td.diff; \
		$(BUILDENV) $(MAKE) CC=$(TARGET)-gcc STRIP=$(TARGET)-strip SUBDIRS="lib daemon modules"; \
		$(MAKE) install INSTALLROOT=$(PKGPREFIX) SUBDIRS="lib daemon modules"
	$(REMOVE)/autofs-$(AUTOFS-VER)
	install -m 0755 -D $(SCRIPTS)/autofs.init $(PKGPREFIX)/etc/init.d/autofs
	ln -sf autofs $(PKGPREFIX)/etc/init.d/S60autofs
	ln -sf autofs $(PKGPREFIX)/etc/init.d/K40autofs
	if ! grep -q CONFIG_AUTOFS4_FS=y $(K_OBJ)/.config; then \
		mkdir -p $(PKGPREFIX)/lib/modules/$(KVERSION_FULL)/kernel/fs/autofs4; \
		cp -a $(TARGETPREFIX)/lib/modules/$(KVERSION_FULL)/kernel/fs/autofs4/autofs4.ko $(PKGPREFIX)/lib/modules/$(KVERSION_FULL)/kernel/fs/autofs4/; \
	fi
	cp -a --remove-destination $(PKGPREFIX)/* $(TARGETPREFIX)/
	$(OPKG_SH) $(CONTROL_DIR)/autofs
	rm -rf $(PKGPREFIX)
	touch $@

samba-server:
samba-client:
$(D)/samba2: $(ARCHIVE)/samba-$(SAMBA2-VER).tar.gz $(PATCHES)/.rebuild.samba2 | $(TARGETPREFIX)
	$(UNTAR)/samba-$(SAMBA2-VER).tar.gz
	rm -rf $(PKGPREFIX)
	set -e; cd $(BUILD_TMP)/samba-$(SAMBA2-VER); \
		$(PATCH)/samba_2.2.12.diff; \
		$(PATCH)/samba_2.2.12-noprint.diff; \
		cd source; \
		autoconf configure.in > configure; \
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
			--with-swatdir=$(PKGPREFIX)/swat; \
		$(MAKE) clean || true; \
		$(MAKE) bin/make_smbcodepage bin/make_unicodemap CC=$(CC); \
		install -d $(PKGPREFIX)/opt/pkg/lib/codepages; \
		./bin/make_smbcodepage c 850 codepages/codepage_def.850 \
			$(PKGPREFIX)/opt/pkg/lib/codepages/codepage.850; \
		./bin/make_unicodemap 850 codepages/CP850.TXT \
			$(PKGPREFIX)/opt/pkg/lib/codepages/unicode_map.850; \
		./bin/make_unicodemap ISO8859-1 codepages/CPISO8859-1.TXT \
			$(PKGPREFIX)/opt/pkg/lib/codepages/unicode_map.ISO8859-1
	$(MAKE) -C $(BUILD_TMP)/samba-$(SAMBA2-VER)/source distclean
	set -e; cd $(BUILD_TMP)/samba-$(SAMBA2-VER)/source; \
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
			--with-swatdir=$(PKGPREFIX)/swat \
			; \
		$(MAKE) bin/smbd bin/nmbd bin/smbclient bin/smbmount bin/smbmnt bin/smbpasswd
	install -d $(PKGPREFIX)/opt/pkg/bin
	for i in smbd nmbd; do \
		install $(BUILD_TMP)/samba-$(SAMBA2-VER)/source/bin/$$i $(PKGPREFIX)/opt/pkg/bin; \
	done
	install -d $(PKGPREFIX)/opt/pkg/etc/samba/private
	install $(SCRIPTS)/smb.conf $(PKGPREFIX)/opt/pkg/etc
	cp -a $(PKGPREFIX)/* $(TARGETPREFIX)
	$(TARGET)-strip $(PKGPREFIX)/opt/pkg/bin/*
	DONT_STRIP=1 $(OPKG_SH) $(CONTROL_DIR)/samba2/server
	rm -rf $(PKGPREFIX)/*
	install -d $(PKGPREFIX)/opt/pkg/bin
	for i in smbclient smbmount smbmnt smbpasswd; do \
		install $(BUILD_TMP)/samba-$(SAMBA2-VER)/source/bin/$$i $(PKGPREFIX)/opt/pkg/bin; \
	done
	cp -a $(PKGPREFIX)/* $(TARGETPREFIX)
	$(OPKG_SH) $(CONTROL_DIR)/samba2/client
	$(REMOVE)/samba-$(SAMBA2-VER) $(PKGPREFIX)
	touch $@

$(D)/portmap: $(ARCHIVE)/portmap-$(PORTMAP-VER).tgz $(PATCHES)/.rebuild.portmap
	rm -rf $(PKGPREFIX) $(BUILD_TMP)/portmap-$(PORTMAP-VER)
	mkdir -p $(PKGPREFIX)/sbin
	$(UNTAR)/portmap-$(PORTMAP-VER).tgz
	set -e; cd $(BUILD_TMP)/portmap_$(PORTMAP-VER); \
		$(PATCH)/portmap_6.0-nocheckport.diff; \
		$(BUILDENV) $(MAKE) NO_TCP_WRAPPER=1 DAEMON_UID=65534 DAEMON_GID=65535 CC="$(TARGET)-gcc"; \
		install -m 0755 portmap $(PKGPREFIX)/sbin; \
		install -m 0755 portmap $(TARGETPREFIX)/sbin; \
		install -m 0755 pmap_dump $(TARGETPREFIX)/sbin; \
		install -m 0755 pmap_set $(TARGETPREFIX)/sbin
	PKG_VER=$(PORTMAP-VER) $(OPKG_SH) $(CONTROL_DIR)/portmap
	$(REMOVE)/portmap-$(PORTMAP_VER) $(PKGPREFIX)
	touch $@

$(D)/unfsd: $(D)/libflex $(D)/portmap $(ARCHIVE)/unfs3-$(UNFS3-VER).tar.gz
	$(UNTAR)/unfs3-$(UNFS3-VER).tar.gz
	set -e; cd $(BUILD_TMP)/unfs3-$(UNFS3-VER); \
		$(CONFIGURE) --build=$(BUILD) --host=$(TARGET) --target=$(TARGET) \
			--prefix= --mandir=/.remove; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	rm -f -r $(TARGETPREFIX)/.remove
	rm -rf $(PKGPREFIX)
	mkdir -p $(PKGPREFIX)/sbin
	install -m 755 -D $(SCRIPTS)/nfsd.init $(TARGETPREFIX)/etc/init.d/nfsd
	install -m 755 -D $(SCRIPTS)/nfsd.init $(PKGPREFIX)/etc/init.d/nfsd
	ln -s nfsd $(PKGPREFIX)/etc/init.d/S99nfsd # needs to start after modules are loaded
	ln -s nfsd $(PKGPREFIX)/etc/init.d/K01nfsd
	cp -a $(TARGETPREFIX)/sbin/unfsd $(PKGPREFIX)/sbin
	PKG_VER=$(UNFS3-VER) $(OPKG_SH) $(CONTROL_DIR)/unfsd
	$(REMOVE)/unfs3-$(UNFS3-VER) $(PKGPREFIX)
	touch $@

$(D)/libevent: $(ARCHIVE)/libevent-$(LIBEVENT_VER).tar.gz
	rm -rf $(PKGPREFIX) $(BUILD_TMP)/libevent-$(LIBEVENT_VER)
	mkdir -p $(PKGPREFIX)/lib
	$(UNTAR)/libevent-$(LIBEVENT_VER).tar.gz
	set -e; cd $(BUILD_TMP)/libevent-$(LIBEVENT_VER);\
	$(BUILDENV) $(CONFIGURE) --prefix=$(TARGETPREFIX) --host=$(TARGET);\
	make install;\
	cp -a $(TARGETPREFIX)/lib/libevent*.so* $(PKGPREFIX)/lib ;\
	$(TARGET)-strip $(PKGPREFIX)/lib/*
	PKG_VER=$(LIBEVENT_VER) PKG_PROV=`opkg-find-provides.sh $(PKGPREFIX)` $(OPKG_SH) $(CONTROL_DIR)/libevent
	$(REMOVE)/libevent-$(LIBEVENT_VER) $(PKGPREFIX)
	touch $@

$(D)/libnfsidmap: $(ARCHIVE)/libnfsidmap-$(LIBNFSIDMAP_VER).tar.gz
	rm -rf $(PKGPREFIX) $(BUILD_TMP)/libnfsidmap-$(LIBNFSIDMAP_VER)
	mkdir -p $(PKGPREFIX)/lib
	$(UNTAR)/libnfsidmap-$(LIBNFSIDMAP_VER).tar.gz
	set -e; cd $(BUILD_TMP)/libnfsidmap-$(LIBNFSIDMAP_VER);\
	$(BUILDENV) ac_cv_func_malloc_0_nonnull=yes $(CONFIGURE) --prefix=$(TARGETPREFIX) --host=$(TARGET);\
	sed -i -e '/^#define malloc rpl_malloc/d' config.h; \
	make install ; \
	cp -a $(TARGETPREFIX)/lib/libnfsidmap* $(PKGPREFIX)/lib;\
	rm $(PKGPREFIX)/lib/*a $(PKGPREFIX)/lib/*/*a ;\
	$(TARGET)-strip $(PKGPREFIX)/lib/*.so* $(PKGPREFIX)/lib/*/*.so*
	PKG_VER=$(LIBNFSIDMAP_VER) PKG_PROV=`opkg-find-provides.sh $(PKGPREFIX)` PKG_DEP=`opkg-find-requires.sh $(PKGPREFIX)` $(OPKG_SH) $(CONTROL_DIR)/libnfsidmap
	$(REMOVE)/libnfsidmap-$(LIBNFSIDMAP_VER) $(PKGPREFIX)
	touch $@

$(D)/nfs-utils: $(D)/libevent $(D)/libnfsidmap $(D)/libblkid $(D)/portmap $(ARCHIVE)/nfs-utils-$(NFSUTILS_VER).tar.bz2 $(SCRIPTS)/knfsd.init $(PATCHES)/.rebuild.nfsutils
	rm -rf $(PKGPREFIX) $(BUILD_TMP)/nfs-utils-$(NFSUTILS_VER)
	mkdir -p $(PKGPREFIX)/{sbin,etc/init.d}
	$(UNTAR)/nfs-utils-$(NFSUTILS_VER).tar.bz2
	set -e; cd $(BUILD_TMP)/nfs-utils-$(NFSUTILS_VER); \
		$(BUILDENV) $(CONFIGURE) --build=$(BUILD) --host=$(TARGET) --target=$(TARGET) \
			--prefix= --exec-prefix=  --disable-nfsdcltrack \
                        --disable-uuid --disable-gss --disable-nfsv41 --without-tcp-wrappers; \
		$(MAKE) DESTDIR=$(PKGPREFIX) install; \
	install -m 0755 $(SCRIPTS)/knfsd.init $(PKGPREFIX)/etc/init.d/knfsd;\
	ln -s knfsd $(PKGPREFIX)/etc/init.d/S99knfsd;\
	ln -s knfsd $(PKGPREFIX)/etc/init.d/K01knfsd;\
	chmod u+w $(PKGPREFIX)/sbin/mount.nfs; \
	cp -a $(PKGPREFIX)/* $(TARGETPREFIX);\
	rm -rf $(PKGPREFIX)/{share,var/lib/nfs}/;\
	ln -s /tmp/nfs $(PKGPREFIX)/var/lib/nfs;\
	printf "/ 0.0.0.0/0.0.0.0(rw,no_subtree_check)\n/media/sda1 0.0.0.0/0.0.0.0(rw,no_subtree_check)\n" > $(PKGPREFIX)/etc/exports;\
	PKG_VER=$(NFSUTILS_VER) PKG_PROV=`opkg-find-provides.sh $(PKGPREFIX)` PKG_DEP=`opkg-find-requires.sh $(PKGPREFIX)` $(OPKG_SH) $(CONTROL_DIR)/nfs-utils
	$(REMOVE)/nfs-utils-$(NFSUTILS_VER) $(PKGPREFIX)
	touch $@

fbshot: $(TARGETPREFIX)/bin/fbshot
$(TARGETPREFIX)/bin/fbshot: $(ARCHIVE)/fbshot-$(FBSHOT-VER).tar.gz $(wildcard $(PATCHES)/fbshot-0.3-*.diff) libpng | $(TARGETPREFIX)
	$(UNTAR)/fbshot-$(FBSHOT-VER).tar.gz
	set -e; cd $(BUILD_TMP)/fbshot-$(FBSHOT-VER); \
		$(PATCH)/fbshot-0.3-32bit_cs_fb.diff; \
		$(PATCH)/fbshot-0.3-32bit_td_fb.diff; \
		$(PATCH)/fbshot-0.3-libpng16.diff
	set -e; cd $(BUILD_TMP)/fbshot-$(FBSHOT-VER); \
		$(TARGET)-gcc -DHW_$(PLATFORM) $(TARGET_CFLAGS) $(TARGET_LDFLAGS) fbshot.c -lpng -lz -o $@
	$(REMOVE)/fbshot-$(FBSHOT-VER)

# old valgrind for TD with old toolchain (linuxthreads glibc)
$(D)/valgrind-old: $(ARCHIVE)/valgrind-3.3.1.tar.bz2 | $(TARGETPREFIX)
	$(UNTAR)/valgrind-3.3.1.tar.bz2
	set -e; cd $(BUILD_TMP)/valgrind-3.3.1; \
		export ac_cv_path_GDB=/opt/pkg/bin/gdb; \
		export AR=$(TARGET)-ar; \
		$(CONFIGURE) --prefix=/ --enable-only32bit --enable-tls; \
		make all; \
		make install DESTDIR=$(TARGETPREFIX)
	$(REMOVE)/valgrind-3.3.1
	touch $@

ifeq ($(BOXARCH), arm)
VALGRIND_EXTRA_EXPORT = export ac_cv_host=armv7-unknown-linux-gnueabi
else
VALGRIND_EXTRA_EXPORT = :
endif
# newer valgrind is probably only usable with external toolchain and newer glibc (posix threads)
$(DEPDIR)/valgrind: $(ARCHIVE)/valgrind-$(VALGRIND_VER).tar.bz2 | $(TARGETPREFIX)
	$(UNTAR)/valgrind-$(VALGRIND_VER).tar.bz2
	rm -rf $(PKGPREFIX)
	set -e; cd $(BUILD_TMP)/valgrind-$(VALGRIND_VER); \
		export ac_cv_path_GDB=/opt/pkg/bin/gdb; \
		$(VALGRIND_EXTRA_EXPORT); \
		export AR=$(TARGET)-ar; \
		$(CONFIGURE) --prefix=/opt/pkg --enable-only32bit --mandir=/.remove --datadir=/.remove; \
		$(MAKE) all; \
		make install DESTDIR=$(PKGPREFIX)
	rm -rf $(PKGPREFIX)/.remove
	mv $(PKGPREFIX)/opt/pkg/lib/pkgconfig/* $(PKG_CONFIG_PATH)
	$(REWRITE_PKGCONF_OPT) $(PKG_CONFIG_PATH)/valgrind.pc
	cp -a $(PKGPREFIX)/* $(TARGETPREFIX)
	rm -rf $(PKGPREFIX)/opt/pkg/include $(PKGPREFIX)/opt/pkg/lib/pkconfig
	rm -rf $(PKGPREFIX)/opt/pkg/lib/valgrind/*.a
	rm -rf $(PKGPREFIX)/opt/pkg/bin/{cg_*,callgrind_*,ms_print} # perl scripts - we don't have perl
	PKG_VER=$(VALGRIND_VER) $(OPKG_SH) $(CONTROL_DIR)/valgrind
	$(REMOVE)/valgrind-$(VALGRIND_VER) $(PKGPREFIX)
	touch $@

$(D)/lirc: $(ARCHIVE)/lirc-$(LIRC_VER).tar.bz2 $(PATCHES)/lirc-0.9.0.diff $(PATCHES)/lircd_spark.conf $(wildcard $(PATCHES)/lircd_spark.conf.0?_*) $(TARGETPREFIX)/include/aotom_main.h $(SCRIPTS)/lircd.init $(PATCHES)/.rebuild.lirc
	$(UNTAR)/lirc-$(LIRC_VER).tar.bz2
	rm -rf $(PKGPREFIX)
	set -e; cd $(BUILD_TMP)/lirc-$(LIRC_VER); \
		$(PATCH)/lirc-0.9.0.diff ;\
		ac_cv_have_kernel='no_kernel=yes kerneldir="missing" kernelext="ko"' \
		CFLAGS="$(TARGET_CFLAGS) -DUINPUT_NEUTRINO_HACK -DSPARK" ./configure \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--prefix= \
			--mandir=/.remove \
			--with-driver=exaudio \
			--without-x \
			--with-syslog=LOG_DAEMON \
			; \
		$(MAKE) all; \
		make install DESTDIR=$(PKGPREFIX); \
		make install DESTDIR=$(TARGETPREFIX)
	install -m 0644 -D $(PATCHES)/lircd_spark.conf $(PKGPREFIX)/etc/lircd.conf
	for L in $(PATCHES)/lircd_spark.conf.0?_* ; do install -m 0644 -D $$L $(PKGPREFIX)/etc/$${L/*_spark/lircd}; done
	install -m 0755 -D $(SCRIPTS)/lircd.init $(PKGPREFIX)/etc/init.d/lircd
	ln -sf lircd $(PKGPREFIX)/etc/init.d/S60lircd
	ln -sf lircd $(PKGPREFIX)/etc/init.d/K40lircd
	rm -rf $(TARGETPREFIX)/.remove $(PKGPREFIX)/.remove \
		$(PKGPREFIX)/include $(PKGPREFIX)/lib/lib*.a $(PKGPREFIX)/lib/lib*.?? \
		$(PKGPREFIX)/bin/pronto2lirc $(PKGPREFIX)/var
	PKG_PROV=`opkg-find-provides.sh $(PKGPREFIX)` \
		PKG_VER=$(LIRC_VER) $(OPKG_SH) $(CONTROL_DIR)/lirc
	$(REMOVE)/lirc-$(LIRC_VER) $(PKGPREFIX)
	touch $@

$(D)/iperf: $(ARCHIVE)/iperf-$(IPERF-VER).tar.gz | $(TARGETPREFIX)
	$(UNTAR)/iperf-$(IPERF-VER).tar.gz
	rm -rf $(PKGPREFIX)
	set -e; cd $(BUILD_TMP)/iperf-$(IPERF-VER); \
		ac_cv_func_malloc_0_nonnull=yes \
		$(BUILDENV) ./configure \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--target=$(TARGET) \
			--prefix=/opt/pkg \
			--mandir=/.remove \
			; \
		$(MAKE) install DESTDIR=$(PKGPREFIX)
	rm -rf $(PKGPREFIX)/.remove
	install -D -m 0755 $(PKGPREFIX)/opt/pkg/bin/iperf $(TARGETPREFIX)/opt/pkg/bin/iperf
	PKG_VER=$(IPERF-VER) $(OPKG_SH) $(CONTROL_DIR)/iperf
	$(REMOVE)/iperf-$(IPERF-VER) $(PKGPREFIX)
	touch $@

$(D)/tcpdump: $(D)/libpcap $(ARCHIVE)/tcpdump-$(TCPDUMP-VER).tar.gz | $(TARGETPREFIX)
	$(UNTAR)/tcpdump-$(TCPDUMP-VER).tar.gz
	set -e; cd $(BUILD_TMP)/tcpdump-$(TCPDUMP-VER); \
		$(PATCH)/tcpdump-noipv6.diff; \
		cp -a $(PATCHES)/ppi.h .; \
		echo "ac_cv_linux_vers=2" >> config.cache ; \
		PCAP_CONFIG=$(TARGETPREFIX)/bin/pcap-config $(CONFIGURE) --prefix= --disable-ipv6 --disable-smb --without-crypto -C --mandir=/.remove; \
		$(MAKE) all; \
		make install DESTDIR=$(PKGPREFIX)
	rm -rf $(PKGPREFIX)/.remove $(PKGPREFIX)/sbin/tcpdump.*
	PKG_VER=$(TCPDUMP-VER) $(OPKG_SH) $(CONTROL_DIR)/tcpdump
	$(REMOVE)/tcpdump-$(TCPDUMP-VER) $(PKGPREFIX)
	touch $@

# !!! this is experimental and not working now !!!
$(D)/systemd: $(ARCHIVE)/systemd-$(SYSTEMD-VER).tar.bz2 $(D)/dbus $(D)/libcap | $(TARGETPREFIX)
	$(UNTAR)/systemd-$(SYSTEMD-VER).tar.bz2
	rm -rf $(PKGPREFIX)
	set -e; cd $(BUILD_TMP)/systemd-$(SYSTEMD-VER); \
		autoreconf -f -i -s;\
		automake --foreign --include-deps;\
		$(BUILDENV) LDFLAGS="-Wl,-rpath-link,$(TARGETLIB) -L$(TARGETLIB)" ./configure \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--target=$(TARGET) \
			--prefix=$(TARGETPREFIX) \
			--with-distro=other \
			--with-syslog-service=/sbin/syslogd \
			--with-sysvinit-path=/etc/init.d \
			--with-sysvrcd-path=/etc/init.d \
			--with-rootdir=$(TARGETPREFIX) \
			; \
		$(MAKE)
	$(REMOVE)/systemd-$(SYSTEMD-VER) $(PKGPREFIX)
	touch $@

$(D)/dbus: $(ARCHIVE)/dbus-$(DBUS-VER).tar.gz $(D)/libexpat | $(TARGETPREFIX)
	-rm -rf $(PKGPREFIX) $(BUILD_TMP)/dbus-$(DBUS-VER) ; mkdir -p $(PKGPREFIX); \
	$(UNTAR)/dbus-$(DBUS-VER).tar.gz && \
	set -e; cd $(BUILD_TMP)/dbus-$(DBUS-VER); \
		$(BUILDENV) ./configure \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--target=$(TARGET) \
			--prefix= \
			--disable-doxygen-docs \
			--disable-xml-docs \
			--enable-abstract-sockets \
			--with-x=no \
			--with-xml=no \
			; \
		$(MAKE) install DESTDIR=$(PKGPREFIX) ; \
		rm -rf $(PKGPREFIX)/var ;\
		cp -a $(PKGPREFIX)/* $(TARGETPREFIX) ; \
		$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/dbus-1.pc; \
		$(REWRITE_LIBTOOL)/libdbus-1.la; \
		rm -rf $(PKGPREFIX)/{share/doc,share/man,include,lib/*a,lib/dbus-1.0}; \
		$(TARGET)-strip `find $(PKGPREFIX) -type f` || true ; \
		PKG_DEP=`opkg-find-requires.sh $(PKGPREFIX)` PKG_VER=$(DBUS-VER) $(OPKG_SH) $(CONTROL_DIR)/dbus && \
		$(REMOVE)/dbus-$(DBUS-VER) $(PKGPREFIX); \
		touch $@

$(D)/ntp: $(ARCHIVE)/ntp-$(NTP_VER).tar.gz | $(TARGETPREFIX)
	$(UNTAR)/ntp-$(NTP_VER).tar.gz
	rm -rf $(PKGPREFIX)
ifeq ($(PLATFORM), spark)
	set -e; cd $(BUILD_TMP)/ntp-$(NTP_VER); \
		$(PATCH)/ntp-fix-MOD_NANO-on-kernel-2.6.32.patch
endif
	set -e; cd $(BUILD_TMP)/ntp-$(NTP_VER); \
		$(PATCH)/ntp-remove-buildtime.patch; \
		$(BUILDENV) ./configure \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--target=$(TARGET) \
			--prefix= \
			; \
		$(MAKE) install DESTDIR=$(PKGPREFIX)
	cp -a $(PKGPREFIX)/* $(TARGETPREFIX)
	mv -v $(PKGPREFIX)/bin/ntpdate $(PKGPREFIX)/sbin/
	rm $(PKGPREFIX)/bin/*
	rm -rf $(PKGPREFIX)/share/man
	PKG_VER=$(NTP_VER) $(OPKG_SH) $(CONTROL_DIR)/ntp
	$(REMOVE)/ntp-$(NTP_VER) $(PKGPREFIX)
	touch $@

$(D)/yaffs2utils: $(ARCHIVE)/yaffs2utils-$(YAFFS2UTILS-VER).tar.gz | $(TARGETPREFIX)
	-rm -rf $(PKGPREFIX) ; mkdir -p $(TARGETPREFIX)/sbin $(PKGPREFIX)/sbin; \
	$(UNTAR)/yaffs2utils-$(YAFFS2UTILS-VER).tar.gz ; \
	mv $(BUILD_TMP)/$(YAFFS2UTILS-VER) $(BUILD_TMP)/yaffs2utils-$(YAFFS2UTILS-VER) ; \
	set -e; cd $(BUILD_TMP)/yaffs2utils-$(YAFFS2UTILS-VER); \
		$(PATCH)/yaffs2utils-0.2.9.patch; \
		$(BUILDENV) $(MAKE) CC=$(TARGET)-gcc STRIP=$(TARGET)-strip INSTALLDIR=$(TARGETPREFIX)/sbin install ; \
	cp -a $(TARGETPREFIX)/sbin/{mkyaffs2,unspare2,unyaffs2} $(PKGPREFIX)/sbin ; \
	PKG_VER=$(YAFFS2UTILS-VER) $(OPKG_SH) $(CONTROL_DIR)/yaffs2utils ; \
	$(REMOVE)/yaffs2utils-$(YAFFS2UTILS-VER) $(PKGPREFIX) ; \
	touch $@

$(D)/lzo: $(ARCHIVE)/lzo-$(LZO_VER).tar.gz
	-rm -rf $(PKGPREFIX) ; mkdir -p $(TARGETPREFIX)/sbin $(PKGPREFIX)/sbin; \
	$(UNTAR)/lzo-$(LZO_VER).tar.gz && \
	cd $(BUILD_TMP)/lzo-$(LZO_VER) && \
	$(BUILDENV) ./configure \
		--build=$(BUILD) \
		--host=$(TARGET) \
		--target=$(TARGET) \
		--prefix= \
		&& \
	$(MAKE) install DESTDIR=$(TARGETPREFIX) && \
	touch $@

$(TARGETPREFIX)/include/lzo/lzo1x.h:
	rm $(D)/lzo

$(D)/mtd-utils: $(D)/zlib $(D)/lzo $(ARCHIVE)/mtd-utils-$(MTD_UTILS_VER).tar.bz2 | $(TARGETPREFIX)
	-rm -rf $(PKGPREFIX) ; mkdir -p $(PKGPREFIX)/sbin ; \
	$(UNTAR)/mtd-utils-$(MTD_UTILS_VER).tar.bz2 ; \
	set -e; cd $(BUILD_TMP)/mtd-utils-$(MTD_UTILS_VER); \
		$(BUILDENV) $(MAKE) PREFIX= CC=${TARGET}-gcc LD=${TARGET}-ld STRIP=${TARGET}-strip `pwd`/mkfs.jffs2 `pwd`/sumtool BUILDDIR=`pwd` WITHOUT_XATTR=1 DESTDIR=$(TARGETPREFIX) install ; \
	cp -a $(TARGETPREFIX)/sbin/{mkfs.jffs2,sumtool,nandwrite} $(PKGPREFIX)/sbin ; \
	PKG_VER=$(MTD_UTILS_VER) $(OPKG_SH) $(CONTROL_DIR)/mtd-utils ; \
	$(REMOVE)/mtd-utils-$(MTD_UTILS_VER) $(PKGPREFIX) ; \
	touch $@

$(D)/wireless_tools: $(ARCHIVE)/wireless_tools.$(WIRELESSTOOLS_VER).tar.gz | $(TARGETPREFIX)
	-rm -rf $(PKGPREFIX) ; mkdir $(PKGPREFIX); \
	$(UNTAR)/wireless_tools.$(WIRELESSTOOLS_VER).tar.gz && \
	set -e; cd $(BUILD_TMP)/wireless_tools.$(WIRELESSTOOLS_VER) && sed -i "s/CC = gcc/CC = $(TARGET)-gcc/" Makefile && \
	make PREFIX=$(PKGPREFIX) install && \
	cp -a $(PKGPREFIX)/* $(TARGETPREFIX) && \
	rm -rf $(PKGPREFIX)/include $(PKGPREFIX)/man && \
	PKG_VER=$(WIRELESSTOOLS_VER) $(OPKG_SH) $(CONTROL_DIR)/wireless_tools && \
	$(REMOVE)/wireless_tools.$(WIRELESSTOOLS_VER) $(PKGPREFIX) && \
	touch $@

$(D)/wpa_supplicant: libnl $(ARCHIVE)/wpa_supplicant-$(WPASUPP_VER).tar.gz | $(TARGETPREFIX)
	-rm -rf $(PKGPREFIX) ; mkdir -p $(TARGETPREFIX)/sbin $(PKGPREFIX)/sbin; \
	$(BUILDENV) ; $(UNTAR)/wpa_supplicant-$(WPASUPP_VER).tar.gz && \
	cd $(BUILD_TMP)/wpa_supplicant-$(WPASUPP_VER)/wpa_supplicant && \
	cp $(PATCHES)/wpa_supplicant.config .config && \
	cd $(BUILD_TMP)/wpa_supplicant-$(WPASUPP_VER)/wpa_supplicant && \
	make CC=$(TARGET)-gcc TARGETPREFIX=$(TARGETPREFIX) wpa_supplicant && \
	$(TARGET)-strip --strip-unneeded wpa_supplicant && \
	cp -a wpa_supplicant $(TARGETPREFIX)/sbin/ && \
	cp -a wpa_supplicant $(PKGPREFIX)/sbin/ && \
	PKG_VER=$(WPASUPP_VER) $(OPKG_SH) $(CONTROL_DIR)/wpa_supplicant && \
	$(REMOVE)/wpa_supplicant-$(WPASUPP_VER) $(PKGPREFIX) && \
	touch $@

$(D)/aio-grab: zlib libpng libjpeg $(ARCHIVE)/aio-grab-$(AIOGRAB_VER).tar.bz2 $(PATCHES)/aio-grab-$(AIOGRAB_VER)-ADD_ST_FRAMESYNC_SUPPORT.patch $(PATCHES)/aio-grab-$(AIOGRAB_VER)-ADD_ST_SUPPORT.patch
	-rm -rf $(PKGPREFIX) $(BUILD_TMP)/aio-grab-$(AIOGRAB_VER) ; mkdir -p $(TARGETPREFIX)/bin $(PKGPREFIX)/bin; \
	cp -a $(BUILD_TMP)/driver/bpamem/bpamem.h $(TARGETPREFIX)/include; \
	$(UNTAR)/aio-grab-$(AIOGRAB_VER).tar.bz2 && \
	cd $(BUILD_TMP)/aio-grab-$(AIOGRAB_VER) && \
	$(PATCH)/aio-grab-$(AIOGRAB_VER)-ADD_ST_SUPPORT.patch && \
	$(PATCH)/aio-grab-$(AIOGRAB_VER)-ADD_ST_FRAMESYNC_SUPPORT.patch && \
	autoreconf -f -i -s && automake --foreign --include-deps && \
	$(BUILDENV) ./configure --prefix=$(PKGPREFIX) --build=$(BUILD) --host=$(TARGET) --target=$(TARGET) && \
	make && cp grab $(PKGPREFIX)/bin/ && $(TARGET)-strip $(PKGPREFIX)/bin/* && \
	PKG_DEP=`opkg-find-requires.sh $(PKGPREFIX)` PKG_VER=1.0 $(OPKG_SH) $(CONTROL_DIR)/aio-grab && \
	rm -rf $(PKGPREFIX) $(BUILD_TMP)/aio-grab-$(AIOGRAB_VER) && \
	touch $@

$(D)/wget: e2fsprogs $(ARCHIVE)/wget-$(WGET_VER).tar.gz | $(TARGETPREFIX)
	$(UNTAR)/wget-$(WGET_VER).tar.gz
	rm -rf $(PKGPREFIX)
	set -e; cd $(BUILD_TMP)/wget-$(WGET_VER); \
		ac_cv_path_POD2MAN=no \
		$(BUILDENV) ./configure \
			--without-ssl \
			--disable-ipv6 \
			--disable-nls \
			--disable-opie \
			--disable-digest \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--target=$(TARGET) \
			--prefix= \
			; \
		$(MAKE) install DESTDIR=$(PKGPREFIX)
		#mkdir -p $(PKGPREFIX)/lib
		#cp -d $(TARGETPREFIX)/lib/libuuid.so.1.2 $(PKGPREFIX)/lib
		#ln -s ./libuuid.so.1.2 $(PKGPREFIX)/lib/libuuid.so.1
		#ln -s ./libuuid.so.1.2 $(PKGPREFIX)/lib/libuuid.so
	rm -rf $(PKGPREFIX)/share $(PKGPREFIX)/etc
	PKG_VER=$(WGET_VER) \
		PKG_DEP=`opkg-find-requires.sh $(PKGPREFIX)` \
		$(OPKG_SH) $(CONTROL_DIR)/wget
	$(REMOVE)/wget-$(WGET_VER) $(PKGPREFIX)
	touch $@

$(D)/jfsutils: $(ARCHIVE)/jfsutils-$(JFSUTILS_VER).tar.gz e2fsprogs | $(TARGETPREFIX)
	$(REMOVE)/jfsutils-$(JFSUTILS_VER) $(PKGPREFIX)
	$(UNTAR)/jfsutils-$(JFSUTILS_VER).tar.gz
	set -e; cd $(BUILD_TMP)/jfsutils-$(JFSUTILS_VER); \
		$(BUILDENV) ./configure \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--target=$(TARGET) \
			--prefix= \
			; \
		$(MAKE) install DESTDIR=$(PKGPREFIX)
		cp -a $(PKGPREFIX)/* $(TARGETPREFIX)
		rm -rf $(PKGPREFIX)/share
			PKG_VER=$(JFSUTILS_VER) \
			PKG_DEP=`opkg-find-requires.sh $(PKGPREFIX)` \
			$(OPKG_SH) $(CONTROL_DIR)/jfsutils
		$(REMOVE)/jfsutils-$(JFSUTILS_VER) $(PKGPREFIX)
	touch $@

$(D)/hd-idle: $(ARCHIVE)/hd-idle-$(HDIDLE_VER).tgz | $(TARGETPREFIX)
	$(REMOVE)/hd-idle $(PKGPREFIX)
	$(UNTAR)/hd-idle-$(HDIDLE_VER).tgz
	set -e; cd $(BUILD_TMP)/hd-idle; \
		sed -i -e 's/-g root -o root//g' Makefile ; \
		$(BUILDENV) make CC=$(TARGET)-gcc TARGET_DIR=$(PKGPREFIX) install ; \
		cp -a $(PKGPREFIX)/* $(TARGETPREFIX) ; \
		rm -rf $(PKGPREFIX)/share ; \
		$(TARGET)-strip $(PKGPREFIX)/sbin/*
		PKG_VER=$(HDIDLE_VER) PKG_DEP=`opkg-find-requires.sh $(PKGPREFIX)` $(OPKG_SH) $(CONTROL_DIR)/hd-idle
		$(REMOVE)/hd-idle $(PKGPREFIX)
	touch $@

$(D)/hdparm: $(ARCHIVE)/hdparm-$(HDPARM_VER).tar.gz | $(TARGETPREFIX)
	$(REMOVE)/hdparm-$(HDPARM_VER) $(PKGPREFIX)
	$(UNTAR)/hdparm-$(HDPARM_VER).tar.gz
	set -e; cd $(BUILD_TMP)/hdparm-$(HDPARM_VER); \
		$(BUILDENV) make CC=$(TARGET)-gcc STRIP=$(TARGET)-strip DESTDIR=$(PKGPREFIX) install ; \
		cp -a $(PKGPREFIX)/* $(TARGETPREFIX) ; \
		rm -rf $(PKGPREFIX)/usr ; \
		PKG_VER=$(HDPARM_VER) PKG_DEP=`opkg-find-requires.sh $(PKGPREFIX)` $(OPKG_SH) $(CONTROL_DIR)/hdparm
		$(REMOVE)/hdparm-$(HDPARM_VER) $(PKGPREFIX)
	touch $@

$(D)/sdparm: $(ARCHIVE)/sdparm-$(SDPARM_VER).tgz | $(TARGETPREFIX)
	$(REMOVE)/sdparm-$(SDPARM_VER) $(PKGPREFIX)
	$(UNTAR)/sdparm-$(SDPARM_VER).tgz
	set -e; cd $(BUILD_TMP)/sdparm-$(SDPARM_VER); \
		$(BUILDENV) ./configure --build=$(BUILD) --host=$(TARGET) --target=$(TARGET) --bindir=/sbin --prefix= ; \
		$(MAKE) install DESTDIR=$(PKGPREFIX)
		cp -a $(PKGPREFIX)/* $(TARGETPREFIX)
		rm -rf $(PKGPREFIX)/share $(PKGPREFIX)/sbin/*_*
		$(TARGET)-strip $(PKGPREFIX)/sbin/*
		PKG_VER=$(SDPARM_VER) PKG_DEP=`opkg-find-requires.sh $(PKGPREFIX)` $(OPKG_SH) $(CONTROL_DIR)/sdparm
		$(REMOVE)/sdparm-$(SDPARM_VER) $(PKGPREFIX)
	touch $@

system-tools: $(D)/rsync $(D)/procps $(D)/busybox $(D)/e2fsprogs $(D)/ntp $(D)/wpa_supplicant $(D)/wireless_tools $(D)/vsftpd
system-tools-opt: $(D)/samba2 $(D)/ntfs-3g
system-tools-all: system-tools system-tools-opt

PHONY += system-tools system-tools-opt system-tools-all
