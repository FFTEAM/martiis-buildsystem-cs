# makefile for basic prerequisites
# version 2

preqs: neutrino-hd cs-svn $(DEPDIR) $(PKG_CONFIG_PATH)

$(DEPDIR):
	mkdir $(DEPDIR)

$(PKG_CONFIG_PATH):
	mkdir -p $(PKG_CONFIG_PATH)

download:
	mkdir download

$(SOURCE_DIR)/neutrino-hd:
	@echo ' ============================================================================== '
	@echo "                     Cloning neutrino-hd git repo"
	@echo ' ============================================================================== '
	mkdir -p $(SOURCE_DIR)
	cd $(SOURCE_DIR) && \
		git clone git://gitorious.org/neutrino-hd/neutrino-hd.git

$(SOURCE_DIR)/svn/COOLSTREAM:
	mkdir -p $(shell dirname $@)
	cd $(shell dirname $@) && svn co http://www.coolstreamtech.de/coolstream_public_svn/COOLSTREAM

$(SOURCE_DIR)/svn/CROSSENVIROMENT/coolstream:
	mkdir -p $(shell dirname $@)
	cd $(shell dirname $@) && svn co http://www.coolstreamtech.de/coolstream_public_svn/CROSSENVIROMENT/coolstream

# instead of checking out everything, just check out the stuff that's really needed.
$(SOURCE_DIR)/svn/THIRDPARTY/libraries:
	mkdir -p $@
	cd $@ && svn co http://www.coolstreamtech.de/coolstream_public_svn/THIRDPARTY/libraries/libcs && \
		 svn co http://www.coolstreamtech.de/coolstream_public_svn/THIRDPARTY/libraries/libnxp

neutrino-hd: $(SOURCE_DIR)/neutrino-hd
cs-svn: $(SOURCE_DIR)/svn/THIRDPARTY/libraries $(SOURCE_DIR)/svn/COOLSTREAM $(SOURCE_DIR)/svn/CROSSENVIROMENT/coolstream
