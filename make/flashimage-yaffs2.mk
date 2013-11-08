# build a flash image.
# the contents need to be in $(BUILD_TMP)/install
# e.g. installed with "make minimal-system-pkgs"
#
# the needed mkyaffs2 binary is build with the yaffs2utils-host target
#

TIME := $(shell date +%Y%m%d%H%M)
FLASHIMG = $(BUILD_TMP)/e2yaffs2-$(PLATFORM)-$(TIME).img

local-install:
	# copy local/flash/* into the image...
	# you can e.g. create local/flash/boot/audio.elf ...
	@if test -d $(BASE_DIR)/local/flash/; then \
		rsync -avP --exclude=*.*~ $(BASE_DIR)/local/flash/. $(BUILD_TMP)/install; \
	fi

flash-prepare: local-install $(HOSTPREFIX)/bin/mkyaffs2

flash-build:
	ln -sf /share/zoneinfo/CET $(BUILD_TMP)/install/etc/localtime # CET is the default in a fresh neutrino install
	mkyaffs2 --all-root -v -o $(BASE_DIR)/misc/oob-spark.img $(BUILD_TMP)/install $(FLASHIMG)


flashimage: system-pkgs plugins flash-prepare flash-build
	rm -fr $(BUILD_TMP)/install
	@set -e; rm -rf $(BUILD_TMP)/enigma2; mkdir $(BUILD_TMP)/enigma2; \
		cd $(BUILD_TMP)/enigma2; \
		cp -a $(BUILD_TMP)/uImage .; \
		cp -a $(FLASHIMG) e2yaffs2.img; \
		cp -a $(BASE_DIR)/misc/install_yaffs2.sh $(BASE_DIR)/misc/upgrade_yaffs2.sh .; \
		chmod 755 install_yaffs2.sh upgrade_yaffs2.sh ; \
		echo; echo; echo "Flash image is in build_tmp/enigma2:"; ls -l *; \
		echo; echo "Copy this directory to an USB stick, boot SPARK"; \
		echo "and run either upgrade_yaffs2.sh or install_yaffs2.sh"

$(HOSTPREFIX)/bin/mkyaffs2: yaffs2utils-host

yaffs2utils-host: $(ARCHIVE)/yaffs2utils-$(YAFFS2UTILS-VER).tar.gz | $(HOSTPREFIX)/bin
	if test ! -d $(BUILD_TMP)/yaffs2utils-$(YAFFS2UTILS-VER)-host ; then \
		$(UNTAR)/yaffs2utils-$(YAFFS2UTILS-VER).tar.gz && \
			mv $(BUILD_TMP)/$(YAFFS2UTILS-VER) $(BUILD_TMP)/yaffs2utils-$(YAFFS2UTILS-VER)-host ;\
	fi ; \
	cd $(BUILD_TMP)/yaffs2utils-$(YAFFS2UTILS-VER)-host && \
		make all && cp mkyaffs2 unspare2 unyaffs2 $(HOSTPREFIX)/bin/ && \
		cd $(BUILD_TMP) && \
		rm -rf $(BUILD_TMP)/yaffs2utils-$(YAFFS2UTILS-VER)-host

PHONY += flashimage yaffs2utils-host
