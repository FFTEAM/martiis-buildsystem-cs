#
# various gstreamer targets. experimental.
#
$(D)/gstreamer: $(ARCHIVE)/gstreamer-$(GSTREAMER_VER).tar.bz2 $(D)/libxml2 $(D)/libglib | $(TARGETPREFIX)
	$(UNTAR)/gstreamer-$(GSTREAMER_VER).tar.bz2
	set -e; cd $(BUILD_TMP)/gstreamer-$(GSTREAMER_VER); \
		$(CONFIGURE) --prefix= \
			LDFLAGS="$(LD_FLAGS) -Wl,-rpath-link,$(TARGETLIB)" \
			; \
		$(MAKE); \
		make install DESTDIR=$(PKGPREFIX)
	cd $(PKGPREFIX)/share && rm -r gtk-doc locale man
	for i in $(PKGPREFIX)/lib/pkgconfig/*.pc; do \
		mv $$i $(PKG_CONFIG_PATH); \
		$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/$${i##*/}; \
		done
	sed -i '/^dependency_libs=/{ s# /lib# $(TARGETPREFIX)/lib#g }' \
		$(PKGPREFIX)/lib/*.la $(PKGPREFIX)/lib/gstreamer-0.10/*.la
	rmdir $(PKGPREFIX)/lib/pkgconfig
	cp -a $(PKGPREFIX)/* $(TARGETPREFIX)
	for i in libgstdataprotocol-0.10.la \
		gstreamer-0.10/libgstcoreelements.la \
		gstreamer-0.10/libgstcoreindexers.la \
		libgstcheck-0.10.la libgstnet-0.10.la libgstreamer-0.10.la \
		libgstbase-0.10.la libgstcontroller-0.10.la; do \
		$(REWRITE_LIBTOOL)/$$i; done
	rm -r $(PKGPREFIX)/include $(PKGPREFIX)/share
	rm $(PKGPREFIX)/lib/gstreamer-0.10/*.la \
		$(PKGPREFIX)/lib/*.so $(PKGPREFIX)/lib/*.a $(PKGPREFIX)/lib/*.la
	PKG_VER=$(GSTREAMER_VER) \
		PKG_DEP=`opkg-find-requires.sh $(PKGPREFIX)` \
		PKG_PROV=`opkg-find-provides.sh $(PKGPREFIX)` \
		$(OPKG_SH) $(CONTROL_DIR)/gstreamer
	$(REMOVE)/gstreamer-$(GSTREAMER_VER) $(PKGPREFIX)
	touch $@

$(D)/gst-plugins-base: $(ARCHIVE)/gst-plugins-base-$(GSTREAMER_VER).tar.bz2 $(D)/gstreamer
	$(UNTAR)/gst-plugins-base-$(GSTREAMER_VER).tar.bz2
	set -e; cd $(BUILD_TMP)/gst-plugins-base-$(GSTREAMER_VER); \
		$(CONFIGURE) --prefix= \
			--disable-theora \
			--disable-gnome_vfs \
			--disable-pango \
			--disable-ogg \
			--disable-vorbis \
			--with-audioresample-format=int \
			--disable-x \
			--disable-examples \
			LDFLAGS="$(LD_FLAGS) -Wl,-rpath-link,$(TARGETLIB)" \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(PKGPREFIX)
	cd $(PKGPREFIX) && rm bin/gst-visualise-0.10
	cd $(PKGPREFIX)/share && rm -rf locale gtk-doc man
	for i in $(PKGPREFIX)/lib/pkgconfig/*.pc; do \
		mv $$i $(PKG_CONFIG_PATH); \
		$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/$${i##*/}; \
		done
	sed -i '/^dependency_libs=/{ s# /lib# $(TARGETPREFIX)/lib#g }' \
		$(PKGPREFIX)/lib/*.la $(PKGPREFIX)/lib/gstreamer-0.10/*.la
	rmdir $(PKGPREFIX)/lib/pkgconfig
	cp -a $(PKGPREFIX)/* $(TARGETPREFIX)
	for i in `cd $(PKGPREFIX)/lib/; echo gstreamer-0.10/*.la *.la`; do \
		$(REWRITE_LIBTOOL)/$$i; done
	rm -r $(PKGPREFIX)/include $(PKGPREFIX)/share
	rm $(PKGPREFIX)/lib/gstreamer-0.10/*.la \
		$(PKGPREFIX)/lib/*.so $(PKGPREFIX)/lib/*.a $(PKGPREFIX)/lib/*.la
	PKG_VER=$(GSTREAMER_VER) \
		PKG_DEP=`opkg-find-requires.sh $(PKGPREFIX)` \
		PKG_PROV=`opkg-find-provides.sh $(PKGPREFIX)` \
		$(OPKG_SH) $(CONTROL_DIR)/gst-plugins-base
	$(REMOVE)/gst-plugins-base-$(GSTREAMER_VER) $(PKGPREFIX)
	touch $@

$(D)/gst-plugins-good: $(ARCHIVE)/gst-plugins-good-$(GST_PLUG_GOOD_VER).tar.bz2 $(D)/gstreamer $(D)/gst-plugins-base
	$(UNTAR)/gst-plugins-good-$(GST_PLUG_GOOD_VER).tar.bz2
	set -e; cd $(BUILD_TMP)/gst-plugins-good-$(GST_PLUG_GOOD_VER); \
		$(CONFIGURE) --prefix= \
			--disable-examples \
			--disable-cairo \
			--disable-x \
			--disable-esd \
			--disable-gdk_pixbuf \
			LDFLAGS="$(LD_FLAGS) -Wl,-rpath-link,$(TARGETLIB)" \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(PKGPREFIX)
	cd $(PKGPREFIX)/share && rm -rf locale
	sed -i '/^dependency_libs=/{ s# /lib# $(TARGETPREFIX)/lib#g }' \
		$(PKGPREFIX)/lib/gstreamer-0.10/*.la
	cp -a $(PKGPREFIX)/* $(TARGETPREFIX)
	for i in `cd $(PKGPREFIX)/lib/gstreamer-0.10; echo *.la`; do \
		$(REWRITE_LIBTOOL)/gstreamer-0.10/$$i; done
	rm $(PKGPREFIX)/lib/gstreamer-0.10/*.la
	PKG_VER=$(GST_PLUG_GOOD_VER) \
		PKG_DEP=`opkg-find-requires.sh $(PKGPREFIX)` \
		PKG_PROV=`opkg-find-provides.sh $(PKGPREFIX)` \
		$(OPKG_SH) $(CONTROL_DIR)/gst-plugins-good
	$(REMOVE)/gst-plugins-good-$(GST_PLUG_GOOD_VER) $(PKGPREFIX)
	touch $@
