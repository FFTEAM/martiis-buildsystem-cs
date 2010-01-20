# makefile for basic prerequisites
# version 2

preqs: neutrino-hd cs-svn $(DEPDIR) $(PKG_CONFIG_PATH) download

$(DEPDIR):
	mkdir $(DEPDIR)

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
	@echo "                     Cloning neutrino-hd git repo"
	@echo ' ============================================================================== '
	mkdir -p $(SOURCE_DIR)
	cd $(SOURCE_DIR) && \
		git clone git://gitorious.org/neutrino-hd/neutrino-hd.git && \
		cd neutrino-hd && \
		git checkout -b neutrino-experimental origin/neutrino-experimental

$(SOURCE_DIR)/svn/COOLSTREAM:
	mkdir -p $(shell dirname $@)
	cd $(shell dirname $@) && svn co http://www.coolstreamtech.de/coolstream_public_svn/COOLSTREAM

# instead of checking out everything, just check out the stuff that's really needed.
$(SOURCE_DIR)/svn/CROSSENVIROMENT/coolstream \
$(SOURCE_DIR)/svn/CROSSENVIROMENT/crosstool-ng-1.3.2 \
$(SOURCE_DIR)/svn/CROSSENVIROMENT/crosstool-ng-configs:
	mkdir -p $(shell dirname $@)
	cd $(shell dirname $@) && svn co http://www.coolstreamtech.de/coolstream_public_svn/CROSSENVIROMENT/$(shell basename $@)

$(SOURCE_DIR)/svn/THIRDPARTY/applications/hotplug:
	mkdir -p $(shell dirname $@)
	cd $(shell dirname $@) && svn co http://www.coolstreamtech.de/coolstream_public_svn/THIRDPARTY/applications/$(shell basename $@)

$(SOURCE_DIR)/svn/THIRDPARTY/libraries:
	mkdir -p $@
	cd $@ && svn co http://www.coolstreamtech.de/coolstream_public_svn/THIRDPARTY/libraries/libcs && \
		 svn co http://www.coolstreamtech.de/coolstream_public_svn/THIRDPARTY/libraries/libnxp

neutrino-hd: $(SOURCE_DIR)/neutrino-hd
cs-svn: $(SOURCE_DIR)/svn/THIRDPARTY/libraries $(SOURCE_DIR)/svn/COOLSTREAM $(SOURCE_DIR)/svn/CROSSENVIROMENT/coolstream
