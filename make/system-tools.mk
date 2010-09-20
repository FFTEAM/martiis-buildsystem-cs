#Makefile to build system tools

$(D)/rsync: $(ARCHIVE)/rsync-3.0.6.tar.gz | $(TARGETPREFIX)
	$(UNTAR)/rsync-3.0.6.tar.gz
	pushd $(BUILD_TMP)/rsync-3.0.6 && \
		$(CONFIGURE) --prefix= --build=$(BUILD) --host=$(TARGET) --mandir=$(BUILD_TMP)/.remove && \
		$(MAKE) all && \
		make install prefix=$(TARGETPREFIX)
	$(REMOVE)/rsync-3.0.6
	$(REMOVE)/.remove
	touch $@

$(D)/procps: $(D)/libncurses $(ARCHIVE)/procps-3.2.7.tar.gz | $(TARGETPREFIX)
	$(UNTAR)/procps-3.2.7.tar.gz
	pushd $(BUILD_TMP)/procps-3.2.7 && \
		$(PATCH)/procps-3.2.7-avoid-ICE-with-gcc-4.3.2-arm.diff && \
		make CC=$(TARGET)-gcc LDFLAGS="$(LD_FLAGS)" \
			CPPFLAGS="-pipe -O2 -g -I$(TARGETPREFIX)/include -I$(TARGETPREFIX)/include/ncurses -D__GNU_LIBRARY__" \
			top ps/ps && \
		mkdir -p $(TARGETPREFIX)/bin && \
		rm -f $(TARGETPREFIX)/bin/ps $(TARGETPREFIX)/bin/top && \
		install -m 755 top ps/ps $(TARGETPREFIX)/bin && \
		install -m 755 proc/libproc-3.2.7.so $(TARGETPREFIX)/lib
	$(REMOVE)/procps-3.2.7
	touch $@

$(D)/busybox: $(ARCHIVE)/busybox-1.15.2.tar.bz2 | $(TARGETPREFIX)
	$(UNTAR)/busybox-1.15.2.tar.bz2
	pushd $(BUILD_TMP)/busybox-1.15.2 && \
		$(PATCH)/busybox-1.15.2-make-ftpd-more-tolerant.diff && \
		cp $(PATCHES)/busybox-hd1.config .config && \
		sed -i -e 's#^CONFIG_PREFIX.*#CONFIG_PREFIX="$(TARGETPREFIX)"#' .config && \
		$(MAKE) all  CROSS_COMPILE=$(TARGET)- CFLAGS_EXTRA="$(TARGET_CFLAGS)" && \
		make install CROSS_COMPILE=$(TARGET)- CFLAGS_EXTRA="$(TARGET_CFLAGS)"
	$(REMOVE)/busybox-1.15.2
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

$(D)/strace: $(ARCHIVE)/strace-4.5.19.tar.bz2 | $(TARGETPREFIX)
	$(UNTAR)/strace-4.5.19.tar.bz2
	pushd $(BUILD_TMP)/strace-4.5.19 && \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(TARGETPREFIX)/include" \
		CXXFLAGS="$(TARGET_CXXFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure --prefix= --build=$(BUILD) --host=$(TARGET) --mandir=$(BUILD_TMP)/.remove && \
		$(MAKE) all && \
		make install prefix=$(TARGETPREFIX)
	$(REMOVE)/strace-4.5.19
	$(REMOVE)/.remove
	touch $@

$(D)/e2fsprogs: $(ARCHIVE)/e2fsprogs-1.41.12.tar.gz | $(TARGETPREFIX)
	$(UNTAR)/e2fsprogs-1.41.12.tar.gz
	cd $(BUILD_TMP)/e2fsprogs-1.41.12 && \
		ln -sf /bin/true ./ldconfig && \
		CC=$(TARGET)-gcc \
		RANLIB=$(TARGET)-ranlib \
		CFLAGS="-Os -msoft-float" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		PATH=$(BUILD_TMP)/e2fsprogs-1.41.12:$(PATH) \
		./configure \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--target=$(TARGET) \
			--prefix=/ \
			--infodir=/.remove \
			--mandir=/.remove \
			--with-linker=$(TARGET)-ld \
			--disable-evms \
			--enable-htree \
			--disable-profile \
			--disable-e2initrd-helper \
			--disable-swapfs \
			--disable-debugfs \
			--disable-imager \
			--disable-resizer \
			--disable-uuidd \
			--enable-dynamic-e2fsck \
			--enable-fsck \
			--with-gnu-ld \
			--disable-nls && \
		$(MAKE) && \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REMOVE)/e2fsprogs-1.41.12
	rm -r $(TARGETPREFIX)/.remove
	touch $@

$(D)/xfsprogs: $(ARCHIVE)/xfsprogs-3.1.3.tar.gz $(D)/libuuid | $(TARGETPREFIX)
	$(UNTAR)/xfsprogs-3.1.3.tar.gz
	cd $(BUILD_TMP)/xfsprogs-3.1.3 && \
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
	$(REMOVE)/xfsprogs-3.1.3
	touch $@

#  NOTE:
#  gdb built for target or local-PC
$(D)/gdb: $(ARCHIVE)/gdb-7.0.tar.bz2 | $(TARGETPREFIX)
	$(UNTAR)/gdb-7.0.tar.bz2
	pushd $(BUILD_TMP)/gdb-7.0 && \
		$(BUILDENV) \
		./configure \
			--nfp --disable-werror \
			--prefix= \
			--mandir=$(BUILD_TMP)/.remove \
			--infodir=$(BUILD_TMP)/.remove \
			--build=$(BUILD) --host=$(TARGET) && \
		$(MAKE) all-gdb && \
		make install-gdb prefix=$(TARGETPREFIX) && \
	$(REMOVE)/gdb-7.0
	$(REMOVE)/.remove
	touch $@

#  NOTE:
#  gdb-remote built for local-PC or target
$(D)/gdb-remote: $(ARCHIVE)/gdb-7.0.tar.bz2 | $(TARGETPREFIX)
	$(UNTAR)/gdb-7.0.tar.bz2
	pushd $(BUILD_TMP)/gdb-7.0 && \
		./configure \
			--nfp --disable-werror \
			--prefix=$(HOSTPREFIX) \
			--build=$(BUILD) --host=$(BUILD) --target=$(TARGET) && \
		$(MAKE) all-gdb && \
		make install-gdb && \
	$(REMOVE)/gdb-7.0
	touch $@

system-tools-all: $(D)/rsync $(D)/procps $(D)/busybox $(D)/strace $(D)/e2fsprogs $(D)/gdb $(D)/gdb-remote

$(D)/skeleton: | $(TARGETPREFIX)
	cp --remove-destination -a skel-root/* $(TARGETPREFIX)/

$(D)/autofs: $(ARCHIVE)/autofs-4.1.4.tar.bz2 | $(TARGETPREFIX)
	$(MAKE) $(TARGETPREFIX)/lib/modules/$(KVERSION_FULL)/kernel/fs/autofs4/autofs4.ko
	$(UNTAR)/autofs-4.1.4.tar.bz2
	cd $(BUILD_TMP)/autofs-4.1.4 && \
		$(PATCH)/autofs-4.1.4-td.diff && \
		$(BUILDENV) $(MAKE) CC=$(TARGET)-gcc STRIP=$(TARGET)-strip SUBDIRS="lib daemon modules"  && \
		$(MAKE) install INSTALLROOT=$(TARGETPREFIX) SUBDIRS="lib daemon modules"
	install -m 0755 -D $(PATCHES)/autofs.init $(TARGETPREFIX)/etc/init.d/S60autofs
	ln -sf S60autofs $(TARGETPREFIX)/etc/init.d/K40autofs
	$(REMOVE)/autofs-4.1.4
	touch $@

$(D)/samba3: $(ARCHIVE)/samba-3.3.9.tar.gz $(D)/libiconv | $(TARGETPREFIX)
	$(UNTAR)/samba-3.3.9.tar.gz
	cd $(BUILD_TMP)/samba-3.3.9 && \
		$(PATCH)/samba-3.3.9.diff && \
		cd source && \
		export CONFIG_SITE=$(PATCHES)/samba-3.3.9-config.site && \
		./autogen.sh && \
		$(CONFIGURE) --build=$(BUILD) --host=$(TARGET) --target=$(TARGET) \
			--prefix=/ --mandir=/.remove \
			--sysconfdir=/etc/samba \
			--with-configdir=/etc/samba \
			--with-privatedir=/etc/samba \
			--with-modulesdir=/lib/samba \
			--datadir=/var/samba \
			--localstatedir=/var/samba \
			--with-piddir=/tmp \
			--with-libiconv=/lib \
			--with-cifsumount --without-krb5 --without-ldap --without-ads --disable-cups --disable-swat \
			&& \
		$(MAKE) && \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	rm -f -r $(TARGETPREFIX)/.remove
	$(REMOVE)/samba-3.3.9
	touch $@

$(D)/samba2: $(ARCHIVE)/samba-2.2.12.tar.gz | $(TARGETPREFIX)
	$(UNTAR)/samba-2.2.12.tar.gz
	cd $(BUILD_TMP)/samba-2.2.12 && \
		$(PATCH)/samba_2.2.12.diff && \
		$(PATCH)/samba_2.2.12-noprint.diff && \
		cd source && \
		autoconf configure.in > configure && \
		./configure \
			--build=$(BUILD) \
			--prefix=/opt/samba \
			samba_cv_struct_timespec=yes \
			samba_cv_HAVE_GETTIMEOFDAY_TZ=yes \
			--with-configdir=/opt/samba/etc \
			--with-privatedir=/opt/samba/etc/samba/private \
			--with-lockdir=/var/lock \
			--with-piddir=/var/run \
			--with-logfilebase=/var/log/ \
			--disable-cups \
			--with-swatdir=$(TARGETPREFIX)/swat && \
		$(MAKE) clean; \
		$(MAKE) bin/make_smbcodepage bin/make_unicodemap CC=$(CC) && \
		install -d $(TARGETPREFIX)/opt/samba/lib/codepages && \
		./bin/make_smbcodepage c 850 codepages/codepage_def.850 \
			$(TARGETPREFIX)/opt/samba/lib/codepages/codepage.850 && \
		./bin/make_unicodemap 850 codepages/CP850.TXT \
			$(TARGETPREFIX)/opt/samba/lib/codepages/unicode_map.850 && \
		./bin/make_unicodemap ISO8859-1 codepages/CPISO8859-1.TXT \
			$(TARGETPREFIX)/opt/samba/lib/codepages/unicode_map.ISO8859-1
	$(MAKE) -C $(BUILD_TMP)/samba-2.2.12/source distclean
	cd $(BUILD_TMP)/samba-2.2.12/source && \
		$(BUILDENV) \
		./configure \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--prefix=/opt/samba \
			samba_cv_struct_timespec=yes \
			samba_cv_HAVE_GETTIMEOFDAY_TZ=yes \
			samba_cv_HAVE_IFACE_IFCONF=yes \
			samba_cv_HAVE_EXPLICIT_LARGEFILE_SUPPORT=yes \
			samba_cv_HAVE_OFF64_T=yes \
			samba_cv_have_longlong=yes \
			--with-configdir=/opt/samba/etc \
			--with-privatedir=/opt/samba/etc/samba/private \
			--with-lockdir=/var/lock \
			--with-piddir=/var/run \
			--with-logfilebase=/var/log/ \
			--disable-cups \
			--with-swatdir=$(TARGETPREFIX)/swat
	install -d $(TARGETPREFIX)/opt/samba/bin
	cd $(BUILD_TMP)/samba-2.2.12/source && \
		$(MAKE) bin/smbd bin/nmbd bin/smbclient bin/smbmount bin/smbmnt bin/smbpasswd
	for i in smbd nmbd smbclient smbmount smbmnt smbpasswd; do \
		install $(BUILD_TMP)/samba-2.2.12/source/bin/$$i $(TARGETPREFIX)/opt/samba/bin; \
	done
	install -d $(TARGETPREFIX)/opt/samba/etc/samba/private
	install -d $(TARGETPREFIX)/opt/samba/etc/init.d
	install $(PATCHES)/smb.conf $(TARGETPREFIX)/opt/samba/etc
	install -m 755 $(PATCHES)/samba2.init $(TARGETPREFIX)/opt/samba/etc/init.d/samba
	$(REMOVE)/samba-2.2.12
	touch $@

$(D)/portmap: $(ARCHIVE)/portmap-6.0.tgz
	$(UNTAR)/portmap-6.0.tgz
	cd $(BUILD_TMP)/portmap_6.0 && \
		$(PATCH)/portmap_6.0-nocheckport.diff && \
		$(BUILDENV) $(MAKE) NO_TCP_WRAPPER=1 DAEMON_UID=65534 DAEMON_GID=65535 CC="$(TARGET)-gcc" && \
		install -m 0755 -s portmap $(TARGETPREFIX)/sbin && \
		install -m 0755 -s pmap_dump $(TARGETPREFIX)/sbin && \
		install -m 0755 -s pmap_set $(TARGETPREFIX)/sbin
	$(REMOVE)/portmap_6.0
	touch $@

$(D)/unfsd: $(D)/libflex $(D)/portmap $(ARCHIVE)/unfs3-0.9.22.tar.gz
	$(UNTAR)/unfs3-0.9.22.tar.gz
	cd $(BUILD_TMP)/unfs3-0.9.22 && \
		$(CONFIGURE) --build=$(BUILD) --host=$(TARGET) --target=$(TARGET) \
			--prefix= --mandir=/.remove && \
		$(MAKE) && \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	rm -f -r $(TARGETPREFIX)/.remove
	$(REMOVE)/unfs3-0.9.22
	touch $@

hotplug: $(TARGETPREFIX)/sbin/hotplug
$(TARGETPREFIX)/sbin/hotplug: $(SOURCE_DIR)/svn/THIRDPARTY/applications/hotplug $(SOURCE_DIR)/svn/THIRDPARTY/applications/hotplug/hotplug.c $(D)/libblkid $(D)/libuuid | $(TARGETPREFIX)
	mkdir -p $(TARGETPREFIX)/sbin
	cd $(SOURCE_DIR)/svn/THIRDPARTY/applications/hotplug && \
		$(TARGET)-gcc -Wall -Wextra -Wshadow -O2 -g \
			-I$(TARGETPREFIX)/include -L$(TARGETPREFIX)/lib \
			-lblkid -luuid \
			-o $@ hotplug.c

fbshot: $(TARGETPREFIX)/bin/fbshot
$(TARGETPREFIX)/bin/fbshot: $(ARCHIVE)/fbshot-0.3.tar.gz | $(TARGETPREFIX)
	$(UNTAR)/fbshot-0.3.tar.gz
	cd $(BUILD_TMP)/fbshot-0.3 && \
		$(PATCH)/fbshot-0.3-32bit_cs_fb.diff && \
		$(TARGET)-gcc $(TARGET_CFLAGS) $(TARGET_LDFLAGS) fbshot.c -lpng -lz -o $@
	$(REMOVE)/fbshot-0.3

PHONY += hotplug system-tools-all
