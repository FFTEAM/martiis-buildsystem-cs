# makefile for basic prerequisites
# version 2

preqs: neutrino-hd cs-svn $(D) $(PKG_CONFIG_PATH) download

$(D):
	mkdir $(D)

$(PKG_CONFIG_PATH):
	mkdir -p $(PKG_CONFIG_PATH)

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

$(SOURCE_DIR)/svn/THIRDPARTY/applications/hotplug:
	mkdir -p $(shell dirname $@)
	cd $(shell dirname $@) && $(SVNCO)/THIRDPARTY/applications/$(shell basename $@)

$(SOURCE_DIR)/svn/THIRDPARTY/libraries:
	mkdir -p $@
	cd $@ && $(SVNCO)/THIRDPARTY/libraries/libcs && \
		 $(SVNCO)/THIRDPARTY/libraries/libnxp

neutrino-hd: $(SOURCE_DIR)/neutrino-hd
cs-svn: $(SOURCE_DIR)/svn/THIRDPARTY/libraries $(SOURCE_DIR)/svn/COOLSTREAM $(SOURCE_DIR)/svn/CROSSENVIROMENT/coolstream
