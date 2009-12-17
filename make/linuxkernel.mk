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

$(BUILD_TMP)/linux-2.6.26.8:
	tar -C $(BUILD_TMP) -xf $(ARCHIVE)/linux-2.6.26.8.tar.bz2
	cp $(PATCHES)/kernel.config $@/.config

$(DEPDIR)/cskernel: $(BUILD_TMP)/linux-2.6.26.8
	pushd $(BUILD_TMP)/linux-2.6.26.8 && \
		make ARCH=arm CROSS_COMPILE=$(TARGET)- oldconfig && \
		make ARCH=arm CROSS_COMPILE=$(TARGET)- && \
		make ARCH=arm CROSS_COMPILE=$(TARGET)- INSTALL_MOD_PATH=$(TARGETPREFIX)/mymodules modules_install
	touch $@

