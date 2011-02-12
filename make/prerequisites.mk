# makefile for basic prerequisites

TOOLCHECK  = find-git find-svn find-gzip find-bzip2 find-patch find-gawk
TOOLCHECK += find-makeinfo find-automake find-gcc find-libtool
TOOLCHECK += find-yacc find-flex find-tic find-pkg-config

PREQS = download neutrino-hd-source $(D)
ifeq ($(PLATFORM), tripledragon)
PREQS += tdsvn preqs-directfb-td
else
PREQS += cs-svn
TOOLCHECK += find-cmake
endif

DFB_TD_DEPS  = $(TD_SVN)/ARMAS/cross-enivroment-build/stb/include/directfb
DFB_TD_DEPS += $(TD_SVN)/ARMAS/cross-enivroment-build/stb/lib/pkgconfig
DFB_TD_DEPS += $(TD_SVN)/ARMAS/filesystem-skeleton/stb/lib

preqs: $(PREQS)
preqs-directfb-td: $(DFB_TD_DEPS)

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
	@echo "                  Cloning neutrino-hd-experimental git repo"
	@echo ' ============================================================================== '
	mkdir -p $(SOURCE_DIR)
	cd $(SOURCE_DIR) && \
		git clone git://gitorious.org/neutrino-hd/neutrino-hd-experimental.git neutrino-hd

$(SOURCE_DIR)/neutrino-hd-td:
	@echo ' ============================================================================== '
	@echo "                  Cloning neutrino-hd-tripledragon git repo"
	@echo ' ============================================================================== '
	mkdir -p $(SOURCE_DIR)
	cd $(SOURCE_DIR) && \
		git clone git://gitorious.org/neutrino-hd/neutrino-hd-tripledragon.git neutrino-hd-td


$(PLUGIN_DIR):
	mkdir -p $(SOURCE_DIR)
	cd $(SOURCE_DIR) && \
		git clone git://gitorious.org/neutrino-hd/neutrino-hd-plugins.git

check-repo:
	@git --git-dir=$(SOURCE_DIR)/neutrino-hd/.git config remote.origin.url | \
		grep -q "neutrino-hd-experimental.git$$" || \
	{ echo "=====================================================================";	\
	  echo "* ************ deprecated neutrino-hd repo / branch *************** *";	\
	  echo "* switch your git repo in source/neutrino-hd to branch 'master' of";	\
	  echo "* git://gitorious.org/neutrino-hd/neutrino-hd-experimental.git";	\
	  echo "* if you don't know how to do that, it's probably easiest to remove";	\
	  echo "* $(SOURCE_DIR)/neutrino-hd";						\
	  echo "* and then call 'make preqs' again.";					\
	  echo "=====================================================================";	\
	  echo "continuing in 20 seconds..."; echo "";					\
	  sleep 20; }

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
$(SVN_TP_LIBS)/libnxp \
$(SVN_TP_LIBS)/OpenThreads-svn:
	mkdir -p $(shell dirname $@)
	cd $(shell dirname $@) && $(SVNCO)/THIRDPARTY/libraries/$(shell basename $@)

$(SOURCE_DIR)/svn/THIRDPARTY/lib:
	mkdir -p $@
	cd $@ && $(SVNCO)/THIRDPARTY/lib/firmware

find-%:
	@TOOL=$(patsubst find-%,%,$@); \
		type -p $$TOOL >/dev/null || \
		{ echo "required tool $$TOOL missing."; false; }

toolcheck: $(TOOLCHECK)
	@echo "All required tools seem to be installed."
	@echo

neutrino-hd-source: $(N_HD_SOURCE)
cs-svn: $(SVN_TP_LIBS)/libcs $(SVN_TP_LIBS)/libnxp $(SOURCE_DIR)/svn/COOLSTREAM $(SOURCE_DIR)/svn/CROSSENVIROMENT/coolstream $(SOURCE_DIR)/svn/THIRDPARTY/lib

# TRIPLEDRAGON stuff...
#
# instead of checking out everything, just check out the stuff that's really needed.
$(TD_SVN):
	mkdir -p $(TD_SVN)/ARMAS/filesystem-skeleton/lib/modules/
	mkdir -p $(TD_SVN)/ARMAS/cross-enivroment-build/stb/include/
	mkdir -p $(TD_SVN)/ARMAS/linux-enviroment/
	cd $(TD_SVN)/ARMAS/filesystem-skeleton/lib/modules/ && \
		$(SVNCO)/ARMAS/filesystem-skeleton/lib/modules/2.6.12
	cd $(TD_SVN)/ARMAS/cross-enivroment-build/stb/include/ && \
		$(SVNCO)/ARMAS/cross-enivroment-build/stb/include/hardware
	cd $(TD_SVN)/ARMAS/linux-enviroment/ && \
		$(SVNCO)/ARMAS/linux-enviroment/drivers && \
		$(SVNCO)/ARMAS/linux-enviroment/kernel

# BASE_DIR/tdsvn already creates .../stb/include
$(TD_SVN)/ARMAS/cross-enivroment-build/stb/include/directfb: $(TD_SVN)
	cd $(shell dirname $@) && \
		$(SVNCO)/ARMAS/cross-enivroment-build/stb/include/directfb

$(TD_SVN)/ARMAS/cross-enivroment-build/stb/lib/pkgconfig: | $(TD_SVN)
	mkdir -p $(shell dirname $@)
	cd $(shell dirname $@) && \
		$(SVNCO)/ARMAS/cross-enivroment-build/stb/lib/pkgconfig

$(TD_SVN)/ARMAS/filesystem-skeleton/stb/lib: | $(TD_SVN)
	mkdir -p $(shell dirname $@)
	cd $(shell dirname $@) && \
		$(SVNCO)/ARMAS/filesystem-skeleton/stb/lib

tdsvn: $(TD_SVN)

