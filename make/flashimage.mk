# build a flash image.
# the contents need to be in $(BUILD_TMP)/install
# e.g. installed with "make minimal-system-pkgs"
#
# This is totally untested :-)
#
# the needed mkfs.jffs2 and sumtool are built with the mtd-utils target
#

NOW := $(shell date +%Y%m%d%H%M)
FLASHIMG = $(BUILD_TMP)/flashroot-$(NOW).img
SUMIMG   = $(BUILD_TMP)/flashroot-$(NOW).sum.img

ifeq ($(PLATFORM), coolstream)
# the devtable is used for having a console device on first boot.
flashimage: find-mkfs.jffs2 find-sumtool
	echo "/dev/console c 0644 0 0 5 1 0 0 0" > $(BUILD_TMP)/devtable
	mkfs.jffs2 -e 0x20000 -p -U -D $(BUILD_TMP)/devtable -d $(BUILD_TMP)/install -o $(FLASHIMG)
	sumtool    -e 0x20000 -i $(FLASHIMG) -o $(SUMIMG)
else
flashimage:
	@echo flashimage is not a supported target for $(PLATFORM)
endif

#
# mtd-utils build needs zlib-devel and lzo-devel packages
# installed *on the host*, this is not a cross-build...
#
mtd-utils: $(ARCHIVE)/mtd-utils-1.4.4.tar.bz2 | $(HOSTPREFIX)/bin
	$(UNTAR)/mtd-utils-1.4.4.tar.bz2
	cd $(BUILD_TMP)/mtd-utils-1.4.4 && \
		$(MAKE) `pwd`/mkfs.jffs2 `pwd`/sumtool BUILDDIR=`pwd` WITHOUT_XATTR=1 && \
		cp -a mkfs.jffs2 sumtool $(HOSTPREFIX)/bin
	rm -rf $(BUILD_TMP)/mtd-utils-1.4.4

PHONY += flashimage mtd-utils
