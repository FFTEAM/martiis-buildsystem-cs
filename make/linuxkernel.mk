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

KVERSION = 2.6.26.8
KVERSION_FULL = $(KVERSION)-nevis

$(BUILD_TMP)/linux-$(KVERSION):
	tar -C $(BUILD_TMP) -xf $(ARCHIVE)/linux-$(KVERSION).tar.bz2
	cp $(PATCHES)/kernel.config $@/.config

$(DEPDIR)/cskernel: $(BUILD_TMP)/linux-$(KVERSION)
	pushd $(BUILD_TMP)/linux-$(KVERSION) && \
		make ARCH=arm CROSS_COMPILE=$(TARGET)- oldconfig && \
		make ARCH=arm CROSS_COMPILE=$(TARGET)- && \
		make ARCH=arm CROSS_COMPILE=$(TARGET)- INSTALL_MOD_PATH=$(TARGETPREFIX)/mymodules modules_install
	touch $@

# rule for the autofs4 module - needed by the automounter
# installs the already built module into the "proper" path
$(TARGETPREFIX)/lib/modules/$(KVERSION_FULL)/kernel/fs/autofs4/autofs4.ko: cskernel
	install -m 644 -D $(TARGETPREFIX)/mymodules/lib/modules/$(KVERSION_FULL)/kernel/fs/autofs4/autofs4.ko $@
