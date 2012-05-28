# makefile for basic prerequisites

TOOLCHECK  = find-git find-svn find-gzip find-bzip2 find-patch find-gawk
TOOLCHECK += find-makeinfo find-automake find-gcc find-libtool
TOOLCHECK += find-yacc find-flex find-tic find-pkg-config
TOOLCHECK += find-cmake

PREQS = download neutrino-hd-source $(D)
ifeq ($(PLATFORM), tripledragon)
PREQS += tdsvn
endif
ifeq ($(PLATFORM), coolstream)
PREQS += cs-svn
endif
ifeq ($(PLATFORM), spark)
PREQS += $(TDT_SRC)
endif
ifeq ($(USE_STB_HAL), yes)
PREQS += $(SOURCE_DIR)/libstb-hal
endif

preqs: $(PREQS)

$(D):
	mkdir $(D)

download:
	@echo
	@echo "Download directory missing:"
	@echo "==========================="
	@echo "You need to make a directory named 'download' by executing 'mkdir download'"
	@echo "or create a symlink to the directory where you keep your sources, e.g. by"
	@echo "typing 'ln -s /path/to/my/Archive download'."
	@echo
	@false

$(SOURCE_DIR)/neutrino-hd:
	@echo ' ============================================================================== '
	@echo "                  Cloning neutrino-hd git repo"
	@echo ' ============================================================================== '
	mkdir -p $(SOURCE_DIR)
	cd $(SOURCE_DIR) && \
		git clone $(GITORIOUS)/neutrino-hd/neutrino-hd.git neutrino-hd

$(SOURCE_DIR)/neutrino-hd-td:
	@echo ' ============================================================================== '
	@echo "                  Cloning neutrino-hd-tripledragon git repo"
	@echo ' ============================================================================== '
	mkdir -p $(SOURCE_DIR)
	cd $(SOURCE_DIR) && \
		git clone $(GITORIOUS)/neutrino-hd/neutrino-hd-tripledragon.git neutrino-hd-td

$(SOURCE_DIR)/libstb-hal:
	@echo "=== cloning libstb-hal ==="
	mkdir -p $(SOURCE_DIR)
	cd $(SOURCE_DIR) && \
		git clone $(GITORIOUS)/neutrino-hd/libstb-hal.git libstb-hal

$(PLUGIN_DIR):
	mkdir -p $(SOURCE_DIR)
	cd $(SOURCE_DIR) && \
		git clone $(GITORIOUS)/neutrino-hd/neutrino-hd-plugins.git

$(SOURCE_DIR)/svn/COOLSTREAM:
	mkdir -p $(shell dirname $@)
	cd $(shell dirname $@) && $(SVNCO)/COOLSTREAM

# instead of checking out everything, just check out the stuff that's really needed.
$(SOURCE_DIR)/svn/CROSSENVIROMENT/coolstream \
$(SOURCE_DIR)/svn/CROSSENVIROMENT/crosstool-ng-1.3.2 \
$(SOURCE_DIR)/svn/CROSSENVIROMENT/crosstool-ng-configs:
	mkdir -p $(shell dirname $@)
	cd $(shell dirname $@) && $(SVNCO)/CROSSENVIROMENT/$(shell basename $@)

$(SVN_TP_LIBS)/libcs \
$(SVN_TP_LIBS)/libnxp:
	mkdir -p $(shell dirname $@)
	cd $(shell dirname $@) && $(SVNCO)/THIRDPARTY/libraries/$(shell basename $@)

$(SOURCE_DIR)/svn/THIRDPARTY/lib:
	mkdir -p $@
	cd $@ && $(SVNCO)/THIRDPARTY/lib/firmware

$(SOURCE_DIR)/svn/THIRDPARTY/kernel:
	mkdir -p $(shell dirname $@)
	cd $(shell dirname $@) && $(SVNCO)/THIRDPARTY/kernel

find-%:
	@TOOL=$(patsubst find-%,%,$@); \
		type -p $$TOOL >/dev/null || \
		{ echo "required tool $$TOOL missing."; false; }

toolcheck: $(TOOLCHECK)
	@echo "All required tools seem to be installed."
	@echo
	@if test "$(subst /bin/,,$(shell readlink /bin/sh))" != bash; then \
		echo "WARNING: /bin/sh is not linked to bash."; \
		echo "         This configuration might work, but is not supported."; \
		echo; \
	fi

neutrino-hd-source: $(N_HD_SOURCE)
cs-svn: $(SVN_TP_LIBS)/libcs $(SVN_TP_LIBS)/libnxp $(SOURCE_DIR)/svn/COOLSTREAM $(SOURCE_DIR)/svn/CROSSENVIROMENT/coolstream $(SOURCE_DIR)/svn/THIRDPARTY/lib

# TRIPLEDRAGON stuff...
$(TD_SVN):
	make find-lzma
	set -e; cd $(SOURCE_DIR); \
		lzma -dc $(PATCHES)/tripledragon/tdsvn-essential.tar.lzma | tar xv

tdsvn: $(TD_SVN)

$(TDT_SRC):
	set -e; cd $(SOURCE_DIR); \
		git clone $(TDT_GIT)
