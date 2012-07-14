# build a flash image.
# the contents need to be in $(BUILD_TMP)/install
# e.g. installed with "make minimal-system-pkgs"
#
# This is totally untested :-)
#
# the needed mkyaffs2 binary is build with the yaffs2utils target
#

TIME := $(shell date +%Y%m%d%H%M)
FLASHIMG = $(BUILD_TMP)/e2yaffs2-$(PLATFORM)-$(TIME).img

local-install:
	# copy local/flash/* into the image...
	# you can e.g. create local/flash/boot/audio.elf ...
	@if test -d $(BASE_DIR)/local/flash/; then \
		cp -a -v $(BASE_DIR)/local/flash/. $(BUILD_TMP)/install/.; \
	fi

flash-prepare: local-install

yaffs2utils_installed: /bin/mkyaffs2

/bin/mkyaffs2: yaffs2utils-host

flash-build:
	ln -sf /share/zoneinfo/CET $(BUILD_TMP)/install/etc/localtime # CET is the default in a fresh neutrino install
	mkyaffs2 --all-root -v -o $(BASE_DIR)/misc/oob-spark.img $(BUILD_TMP)/install $(FLASHIMG)


flashimage: flash-prepare flash-build
	rm -fr $(BUILD_TMP)/install
	$(MAKE) system-pkgs
	@set -e; rm -rf $(BUILD_TMP)/enigma2; mkdir $(BUILD_TMP)/enigma2; \
		cd $(BUILD_TMP)/enigma2; \
		cp -a $(BUILD_TMP)/uImage .; \
		cp -a $(FLASHIMG) e2yaffs2.img; \
		cp -a $(BASE_DIR)/misc/install_yaffs2.sh $(BASE_DIR)/misc/upgrade_yaffs2.sh .; \
		chmod 755 install_yaffs2.sh upgrade_yaffs2.sh ; \
		echo; echo; echo "Flash image is in build_tmp/enigma2:"; ls -l *; \
		echo; echo "Copy this directory to an USB stick, boot SPARK"; \
		echo "and run either upgrade_yaffs2.sh or install_yaffs2.sh"

# installed *on the host*, this is not a cross-build...
#
yaffs2utils-host: $(ARCHIVE)/yaffs2utils-$(YAFFS2UTILS-VER).tar.gz | $(HOSTPREFIX)/bin
	$(UNTAR)/yaffs2utils-$(YAFFS2UTILS-VER).tar.gz && \
	cd $(BUILD_TMP) && \
	mv $(YAFFS2UTILS-VER) yaffs2utils-$(YAFFS2UTILS-VER)-host ; \
	cd yaffs2utils-$(YAFFS2UTILS-VER)-host && \
	make all && cp mkyaffs2 unspare2 unyaffs2 $(HOSTPREFIX)/bin/ && \
	cd $(BUILD_TMP) && \
	rm -rf $(BUILD_TMP)/yaffs2utils-$(YAFFS2UTILS-VER)-host

PHONY += flashimage mtd-utils
