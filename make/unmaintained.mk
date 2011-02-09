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

PHONY += hotplug
