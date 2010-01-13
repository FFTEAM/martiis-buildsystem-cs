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
	find $(BOX)/{bin,sbin,lib} -type f -print0 | xargs -0 $(TARGET)-strip || true
	du -sh $(BOX)
