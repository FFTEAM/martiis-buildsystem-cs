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
