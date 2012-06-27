# makefile to build crosstool

crosstool: $(CROSS_DIR)/bin/$(TARGET)-gcc

$(CROSS_DIR)/bin/$(TARGET)-gcc: | $(ARCHIVE)/crosstool-ng-1.15.2.tar.bz2 $(ARCHIVE)/linux-azbox-$(LINUX_AZBOX_VER).tar.bz2
	make $(BUILD_TMP)
	$(UNTAR)/crosstool-ng-1.15.2.tar.bz2
	set -e; unset CONFIG_SITE; cd $(BUILD_TMP)/crosstool-ng-1.15.2; \
		$(PATCH)/crosstool-ng-1.15.2-don_t-build-nconf.diff; \
		cp $(PATCHES)/111-ppl-0_10_2-fix-CXXFLAGS-for-gcc-4_7.patch patches/ppl/0.10.2/; \
		test "$(GIT_PROTOCOL)" = http && \
			sed -i 's#svn://svn.eglibc.org#http://www.eglibc.org/svn#' \
				scripts/build/libc/eglibc.sh || \
			true; \
		mkdir -p targets/src/; \
		tar -C targets/src/ -xf $(ARCHIVE)/linux-azbox-$(LINUX_AZBOX_VER).tar.bz2; \
		sed -i 's/ -static//' targets/src/linux-$(LINUX_AZBOX_VER)/scripts/Makefile.host; \
		cp -a $(PATCHES)/crosstool-ng-mips.config .config; \
		NUM_CPUS=$$(expr `grep -c ^processor /proc/cpuinfo` \* 2); \
		MEM_512M=$$(awk '/MemTotal/ {M=int($$2/1024/512); print M==0?1:M}' /proc/meminfo); \
		test $$NUM_CPUS -gt $$MEM_512M && NUM_CPUS=$$MEM_512M; \
		test $$NUM_CPUS = 0 && NUM_CPUS=1; \
		sed -i "s@^CT_PARALLEL_JOBS=.*@CT_PARALLEL_JOBS=$$NUM_CPUS@" .config; \
		export TD_BASE_DIR=$(BASE_DIR); \
		export TD_BUILD_TMP=$(BUILD_TMP); \
		./configure --enable-local; \
		MAKELEVEL=0 make; \
		./ct-ng oldconfig; \
		./ct-ng build
	$(REMOVE)/crosstool-ng-1.15.2

