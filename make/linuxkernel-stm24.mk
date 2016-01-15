###############################################################
# stuff needed to build kernel modules(very experimental...)  #
# DO NOT TRY TO USE THIS KERNEL, IT WILL MOST LIKELY NOT WORK #
#                                                             #
# ATTENTION: the modules will probably only work with a       #
#            crosstool-built arm-cx2450x-linux-gnueabi-gcc,   #
#            or to be more precise, with the same compiler    #
#            that also built the running kernel!              #
#                                                             #
# modules are installed in $(TARGETPREFIX)/mymodules and can  #
# be picked from there.                                       #
###############################################################

KVERSION = 2.6.32.61
KVERSION_FULL = $(KVERSION)_stm24_0217
SOURCE_MODULE = $(TARGETPREFIX)/mymodules/lib/modules/$(KVERSION_FULL)
TARGET_MODULE = $(TARGETPREFIX)/lib/modules/$(KVERSION_FULL)

TMP_KDIR=$(BUILD_TMP)/linux-2.6.32
TDT_PATCHES=$(TDT_SRC)/tdt/cvs/cdk/Patches

MY_KERNELPATCHES = 

# this is ugly, but easier than changing the way the tdt patches are applied.
# The reason for this patch is, that the spark_setup and spark7162_setup patches
# can not both be applied, because they overlap in a single file. The spark7162
# patch has everything that's needed in this file, so I partly revert the former...
#$(TDT_PATCHES)/linux-sh4-spark_setup_stm24$(PATCH_STR)_revert.patch: \
#		$(PATCHES)/linux-sh4-spark_setup_stm24$(PATCH_STR)_revert.patch
#	ln -sf $(PATCHES)/linux-sh4-spark_setup_stm24$(PATCH_STR)_revert.patch $(TDT_PATCHES)

# if you only want to build for one version, set SPARK_ONLY=1 or SPARK7162_ONLY=1 in config

#$(BUILD_TMP)/linux-$(KVERSION_FULL): \
#		$(STL_ARCHIVE)/stlinux24-host-kernel-source-sh4-$(KVERSION_FULL)-$(subst _0,,$(PATCH_STR)).src.rpm \
#		$(MY_KERNELPATCHES) \
#		$(SPARK_PATCHES_24:%=$(TDT_PATCHES)/%)
#	unpack-rpm.sh $(BUILD_TMP) "" $(BUILD_TMP)/ksrc $<
#	rm -fr $(TMP_KDIR)
#	tar -C $(BUILD_TMP) -xf $(BUILD_TMP)/ksrc/linux-2.6.32.tar.bz2
#	set -e; cd $(TMP_KDIR); \
#		bzcat $(BUILD_TMP)/ksrc/linux-$(KVERSION).patch.bz2 | patch -p1 ;\
#		bzcat $(BUILD_TMP)/ksrc/linux-$(KVERSION)_stm24_sh4$(PATCH_STR).patch.bz2 | patch -p1; \
#		sed -i "s/_0213/$(PATCH_STR)/g" ./localversion-stm; \

$(BUILD_TMP)/linux-$(KVERSION_FULL):
		rm -fr $(TMP_KDIR)
		tar -C $(BUILD_TMP) -xzf $(STL_ARCHIVE)/linux-stm-217.tar.gz
		mv $(BUILD_TMP)/stm_kernel-217 $(TMP_KDIR)
		set -e; cd $(TMP_KDIR); \
		for i in $(SPARK_PATCHES_24); do \
			echo "==> Applying Patch: $$i"; \
			patch -p1 -i $(TDT_PATCHES)/$$i; \
		done
		for i in $(MY_KERNELPATCHES); do \
			echo "==> Applying Patch: $(subst $(PATCHES)/,'',$$i)"; \
			patch -p1 -i $$i; \
		done 
	rm -fr $@ $@-7162
	cd $(BUILD_TMP) && mv linux-2.6.32 linux-$(KVERSION_FULL)
ifeq ($(SPARK_ONLY), )
	cp -al $@ $@-7162 # hardlinked tree
	cd $@-7162; \
	patch -p1 -i $(TDT_PATCHES)/linux-sh4-spark7162_setup_stm24_0217.patch; \
	cp $(PATCHES)/kernel.config-spark7162-0217 .config; \
	sed -i "s#^\(CONFIG_EXTRA_FIRMWARE_DIR=\).*#\1\"$(TDT_SRC)/tdt/cvs/cdk/integrated_firmware\"#" .config; \
	cd $(BUILD_TMP)
	$(MAKE) -C $@-7162 ARCH=sh oldconfig
	$(MAKE) -C $@-7162 ARCH=sh include/asm
	$(MAKE) -C $@-7162 ARCH=sh include/linux/version.h
endif
	cd $@; \
	patch -p1 -i $(TDT_PATCHES)/linux-sh4-spark_setup_stm24_0217_$(ROOTFS_TYPE).patch; \
	cp $(PATCHES)/kernel.config-spark-0217 .config; \
	sed -i "s#^\(CONFIG_EXTRA_FIRMWARE_DIR=\).*#\1\"$(TDT_SRC)/tdt/cvs/cdk/integrated_firmware\"#" .config
	cd $(BUILD_TMP)
	$(MAKE) -C $@ ARCH=sh oldconfig
	$(MAKE) -C $@ ARCH=sh include/asm
	$(MAKE) -C $@ ARCH=sh include/linux/version.h

kernelmenuconfig: $(BUILD_TMP)/linux-$(KVERSION_FULL)$(K_EXTRA)
	make -C$^ ARCH=sh CROSS_COMPILE=$(TARGET)- menuconfig

_sparkkernel: $(BUILD_TMP)/linux-$(KVERSION_FULL)$(K_EXTRA)
	set -e; cd $(BUILD_TMP)/linux-$(KVERSION_FULL)$(K_EXTRA); \
		export PATH=$(CROSS_BASE)/host/bin:$(PATH); \
		$(MAKE) ARCH=sh CROSS_COMPILE=$(TARGET)- uImage modules; \
		make    ARCH=sh CROSS_COMPILE=$(TARGET)- \
			INSTALL_MOD_PATH=$(TARGETPREFIX)/mymodules$(K_EXTRA) modules_install; \
		cp -L arch/sh/boot/uImage $(BUILD_TMP)/uImage$(K_EXTRA)

$(D)/sparkkernel: $(BUILD_TMP)/linux-$(KVERSION_FULL)
ifeq ($(SPARK7162_ONLY), )
	$(MAKE) _sparkkernel
	touch $(BUILD_TMP)/uImage-7162
endif
ifeq ($(SPARK_ONLY), )
	$(MAKE) _sparkkernel K_EXTRA=-7162
	touch $(BUILD_TMP)/uImage
endif
	touch $@

$(TARGETPREFIX)/include/linux/dvb:
	mkdir -p $@

# disabled, merged upstream:
# $(PATCHES)/sparkdrivers/0006-stmdvb-reinit-TS-merger-when-demux-is-idle.patch \
# $(PATCHES)/sparkdrivers/0001-pti-fix-spark_stm_tsm_init-parameters.patch \
# $(PATCHES)/sparkdrivers/0001-import-aotom-from-pinky-s-git.patch \
#

# martii: pre-applied:
#$(PATCHES)/sparkdrivers/0001-player2_191-silence-kmsg-spam.patch \
#$(PATCHES)/sparkdrivers/0002-e2proc-silence-kmsg-spam.patch \
#$(PATCHES)/sparkdrivers/0003-pti-silence-kmsg-spam.patch \
#$(PATCHES)/sparkdrivers/0004-stmfb-silence-kmsg-spam.patch \
#$(PATCHES)/sparkdrivers/0005-frontends-spark_dvbapi5-silence-kmsg-spam.patch \
#$(PATCHES)/sparkdrivers/0006-frontends-spark7162-silence-kmsg-spam.patch \
#

$(BUILD_TMP)/driver: \
| $(TARGETPREFIX)/include/linux/dvb
	cp -a $(TDT_SRC)/tdt/cvs/driver $(BUILD_TMP)
	set -e; cd $(BUILD_TMP)/driver; \
		cp -a bpamem/bpamem.h $(TARGETPREFIX)/include; \
		rm -f player2 multicom; \
		ln -s player2_191 player2; \
		ln -s multicom-3.2.4 multicom; \
		rm -f .config; printf "export CONFIG_PLAYER_191=y\nexport CONFIG_MULTICOM324=y\n" > .config; \
		cp player2/linux/include/linux/dvb/stm_ioctls.h $(TARGETPREFIX)/include/linux/dvb; \
		cd include; \
		rm -f stmfb player2 multicom; \
		ln -s stmfb-3.1_stm24_0104 stmfb; \
		ln -s player2_179 player2; \
		ln -s ../multicom-3.2.4/include multicom; \
		cd ../stgfb; \
		rm -f stmfb; \
		ln -s stmfb-3.1_stm24_0104 stmfb; \
		cp -a stmfb/linux/drivers/video/stmfb.h $(TARGETPREFIX)/include/linux
	cp -a $(BUILD_TMP)/driver/frontcontroller/aotom/aotom_main.h $(TARGETPREFIX)/include
	# disable wireless build
	# sed -i 's/^\(obj-y.*+= wireless\)/# \1/' $(BUILD_TMP)/driver/Makefile
	# disable led, button, boxtype and simu_button - these either aren't for spark or unneeded
	sed -i 's@^\(obj-y.*+= \(led\|button\|boxtype\|simu_button\)/\)@# \1@' $(BUILD_TMP)/driver/Makefile
ifeq ($(SPARK_ONLY), )
	cp -al $@ $@-7162
endif

# CONFIG_MODULES_PATH= is needed because the Makefile contains
# "-I$(CONFIG_MODULES_PATH)/usr/include". With CONFIG_MODULES_PATH unset,
# host system includes are used and that might be fatal.
_sparkdriver: $(BUILD_TMP)/driver$(K_EXTRA) | $(BUILD_TMP)/linux-$(KVERSION_FULL)$(K_EXTRA)
	$(MAKE) -C $(BUILD_TMP)/linux-$(KVERSION_FULL)$(K_EXTRA) ARCH=sh \
		CONFIG_MODULES_PATH=$(CROSS_DIR)/target \
		KERNEL_LOCATION=$(BUILD_TMP)/linux-$(KVERSION_FULL)$(K_EXTRA) \
		DRIVER_TOPDIR=$(BUILD_TMP)/driver$(K_EXTRA) \
		M=$(firstword $^) \
		PLAYER191=player191 \
		CROSS_COMPILE=$(TARGET)-
	make    -C $(BUILD_TMP)/linux-$(KVERSION_FULL)$(K_EXTRA) ARCH=sh \
		CONFIG_MODULES_PATH=$(CROSS_DIR)/target \
		KERNEL_LOCATION=$(BUILD_TMP)/linux-$(KVERSION_FULL)$(K_EXTRA) \
		DRIVER_TOPDIR=$(BUILD_TMP)/driver$(K_EXTRA) \
		M=$(firstword $^) \
		PLAYER191=player191 \
		CROSS_COMPILE=$(TARGET)- \
		INSTALL_MOD_PATH=$(TARGETPREFIX)/mymodules$(K_EXTRA) modules_install

$(D)/sparkdriver:
ifeq ($(SPARK7162_ONLY), )
	$(MAKE) _sparkdriver SPARK=1
endif
ifeq ($(SPARK_ONLY), )
	$(MAKE) _sparkdriver SPARK7162=1 K_EXTRA=-7162
	find $(TARGETPREFIX)/mymodules-7162 -name stmcore-display-sti7106.ko | \
		xargs -r rm # we don't have a 7106 chip
endif
	touch $@

sparkfirmware: $(STL_ARCHIVE)/stlinux24-sh4-stmfb-firmware-1.20-1.noarch.rpm
	unpack-rpm.sh $(BUILD_TMP) $(STM_RELOCATE)/devkit/sh4/target $(TARGETPREFIX)/mymodules $^
	unpack-rpm.sh $(BUILD_TMP) $(STM_RELOCATE)/devkit/sh4/target $(TARGETPREFIX)/mymodules-7162 $^
	ln -sf component_7111_mb618.fw	 $(TARGETPREFIX)/mymodules/lib/firmware/component.fw
	ln -sf fdvo0_7105.fw		 $(TARGETPREFIX)/mymodules/lib/firmware/fdvo0.fw
	ln -sf component_7105_hdk7105.fw $(TARGETPREFIX)/mymodules-7162/lib/firmware/component.fw
	ln -sf fdvo0_7105.fw		 $(TARGETPREFIX)/mymodules-7162/lib/firmware/fdvo0.fw

# rule for the autofs4 module - needed by the automounter
# installs the already built module into the "proper" path
$(TARGET_MODULE)/kernel/fs/autofs4/autofs4.ko: $(K_DEP)
	install -m 644 -D $(SOURCE_MODULE)/kernel/fs/autofs4/autofs4.ko $@
	make depmod

# input drivers: usbhid, evdev
inputmodules: $(D)/cskernel
	mkdir -p $(TARGET_MODULE)/kernel/drivers
	cp -a	$(SOURCE_MODULE)/kernel/drivers/input $(SOURCE_MODULE)/kernel/drivers/hid \
		$(TARGET_MODULE)/kernel/drivers/
	make depmod

# helper target...
depmod:
	PATH=$(PATH):/sbin:/usr/sbin depmod -b $(TARGETPREFIX) $(KVERSION_FULL)
	mv $(TARGET_MODULE)/modules.dep $(TARGET_MODULE)/.modules.dep
	rm $(TARGET_MODULE)/modules.*
	mv $(TARGET_MODULE)/.modules.dep $(TARGET_MODULE)/modules.dep
