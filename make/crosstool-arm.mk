# makefile to build crosstool

crosstool: $(CROSS_DIR)/bin/$(TARGET)-gcc

$(CROSS_DIR)/bin/$(TARGET)-gcc:
	@echo
	@echo "====================================================="
	@echo "old crosstool is hard to maintain and likely to break"
	@echo " consider using 'make crosstool-new' which also gets"
	@echo "  you a shiny new(er) gcc 4.5.2 and eglibc 2.12 ;-)"
	@echo "====================================================="
	@echo
	@echo "sleeping for 10 seconds before continuing..."
	@echo
	@sleep 10
	$(MAKE) crosstool-old

crosstool-old: | $(SOURCE_DIR)/svn/CROSSENVIROMENT/crosstool-ng-1.3.2 $(SOURCE_DIR)/svn/CROSSENVIROMENT/crosstool-ng-configs $(ARCHIVE)/linux-2.6.26.8.tar.bz2 $(ARCHIVE)/binutils-2.19.50.0.1.tar.bz2
	make $(BUILD_TMP)
	tar --exclude='*/.svn' -cC $(SOURCE_DIR)/svn/CROSSENVIROMENT/ crosstool-ng-1.3.2 | tar -xC $(BUILD_TMP)
	set -e; unset CONFIG_SITE; cd $(BUILD_TMP)/crosstool-ng-1.3.2; \
		test "$(GIT_PROTOCOL)" = http && \
			sed -i 's#svn://svn.eglibc.org#http://www.eglibc.org/svn#' \
				scripts/build/libc/eglibc.sh || \
			true; \
		$(PATCH)/crosstool-132-bash4.diff; \
		mkdir -p patches/linux/2.6.26.8; \
		cp $(PATCHES)/linux-2.6.26.8-rename-getline.patch patches/linux/2.6.26.8; \
		cp $(PATCHES)/linux-2.6.26.8-new-make.patch       patches/linux/2.6.26.8; \
		cp $(PATCHES)/eglibc-2_8-new-make.patch           patches/eglibc/2_8/; \
		cp -a $(PATCHES)/crosstool-ng-1.3.2-newconfig .config; \
		sed -i -e 's#^CT_LOCAL_TARBALLS_DIR=.*#CT_LOCAL_TARBALLS_DIR="$(BASE_DIR)/download"#' \
		       -e 's#^CT_PREFIX_DIR=.*#CT_PREFIX_DIR="$(CROSS_BASE)"#' .config; \
		./configure --local; make; chmod 0755 ct-ng; \
		./ct-ng oldconfig; ./ct-ng build.2

crosstool-new: $(ARCHIVE)/crosstool-ng-1.10.0.tar.bz2 $(ARCHIVE)/linux-2.6.26.8.tar.bz2
	make $(BUILD_TMP)
	$(UNTAR)/crosstool-ng-1.10.0.tar.bz2
	set -e; unset CONFIG_SITE; cd $(BUILD_TMP)/crosstool-ng-1.10.0; \
		$(PATCH)/crosstool-ng-1.10.0-new-file.patch; \
		cp $(PATCHES)/111-ppl-0_10_2-fix-CXXFLAGS-for-gcc-4_7.patch patches/ppl/0.10.2/; \
		test "$(GIT_PROTOCOL)" = http && \
			sed -i 's#svn://svn.eglibc.org#http://www.eglibc.org/svn#' \
				scripts/build/libc/eglibc.sh || \
			true; \
		mkdir -p targets/src/; \
		tar -C targets/src/ -xf $(ARCHIVE)/linux-2.6.26.8.tar.bz2; \
		(cd targets/src/linux-2.6.26.8 && \
			patch -p1 -i $(PATCHES)/linux-2.6.26.8-new-make.patch && \
			patch -p1 -i $(PATCHES)/linux-2.6.26.8-rename-getline.patch); \
		ln -sf linux-2.6.26.8 targets/src/linux-custom; \
		touch targets/src/.linux-custom.extracted; \
		cp -a $(PATCHES)/crosstool-ng-coolstreamnew.config .config; \
		NUM_CPUS=$$(expr `grep -c ^processor /proc/cpuinfo` \* 2); \
		MEM_512M=$$(awk '/MemTotal/ {M=int($$2/1024/512); print M==0?1:M}' /proc/meminfo); \
		test $$NUM_CPUS -gt $$MEM_512M && NUM_CPUS=$$MEM_512M; \
		test $$NUM_CPUS = 0 && NUM_CPUS=1; \
		sed -i "s@^CT_PARALLEL_JOBS=.*@CT_PARALLEL_JOBS=$$NUM_CPUS@" .config; \
		export TD_BASE_DIR=$(BASE_DIR); \
		export TD_BUILD_TMP=$(BUILD_TMP); \
		./configure --local; make; chmod 0755 ct-ng; \
		./ct-ng oldconfig; \
		./ct-ng build
	ln -sf sys-root/lib $(CROSS_BASE)/$(TARGET)/
	$(REMOVE)/crosstool-ng-1.10.0

