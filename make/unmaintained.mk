###############################################################
# This file contains unmaintained and not-to-be-used targets. #
# They might have worked at some time but are definitely not  #
# maintained or tested, maybe they never worked at all.       #
# They are only kept here for reference.                      #
###############################################################

$(D)/libiconv: $(ARCHIVE)/libiconv-1.13.1.tar.gz | $(TARGETPREFIX)
	$(UNTAR)/libiconv-1.13.1.tar.gz
	pushd $(BUILD_TMP)/libiconv-1.13.1 && \
		$(CONFIGURE) --build=$(BUILD) --host=$(TARGET) --target=$(TARGET) --prefix= --datarootdir=/.remove && \
		$(MAKE) && \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	rm -fr $(TARGETPREFIX)/.remove
	$(REMOVE)/libiconv-1.13.1
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

$(SVN_TP_APPS)/hotplug:
	mkdir -p $(SVN_TP_APPS)
	cd $(SVN_TP_APPS) && $(SVNCO)/THIRDPARTY/applications/hotplug

hotplug: $(TARGETPREFIX)/sbin/hotplug
$(TARGETPREFIX)/sbin/hotplug: $(SVN_TP_APPS)/hotplug $(SVN_TP_APPS)/hotplug/hotplug.c $(D)/libblkid $(D)/libuuid | $(TARGETPREFIX)
	mkdir -p $(TARGETPREFIX)/sbin
	cd $(SVN_TP_APPS)/hotplug && \
		$(TARGET)-gcc -Wall -Wextra -Wshadow -O2 -g \
			-I$(TARGETPREFIX)/include -L$(TARGETPREFIX)/lib \
			-lblkid -luuid \
			-o $@ hotplug.c

# try to package a minimal root fs for the box target
BOX = $(BUILD_TMP)/rootfs

rootfs:
	rm -rf $(BOX)
	cp -a $(TARGETPREFIX) $(BOX)
	rm -rf $(BOX)/include $(BOX)/mymodules
	rm -rf $(BOX)/share/{aclocal,gdb,locale} # locale not (yet) needed by anything
	rm -rf $(BOX)/lib/pkgconfig
	rm -f $(BOX)/lib/libvorbisenc*
	find $(BOX) -name .gitignore -type f -print0 | xargs --no-run-if-empty -0 rm -f
	find $(BOX)/lib \( -name '*.a' -o -name '*.la' \) -print0 | xargs --no-run-if-empty -0 rm -f
	du -sh $(BOX)
	@echo "*******************************************************"
	@echo "*** The following warnings from strip are harmless! ***"
	@echo "*******************************************************"
	find $(BOX)/bin -type f -print0 | xargs -0 $(TARGET)-strip || true
	find $(BOX)/sbin -type f -print0 | xargs -0 $(TARGET)-strip || true
	find $(BOX)/lib -path $(BOX)/lib/modules -prune -o -type f -print0 | xargs -0 $(TARGET)-strip || true
	du -sh $(BOX)


PHONY += hotplug
