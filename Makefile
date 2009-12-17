#master makefile

include make/environment.mk

############################################################################
#  A print out of environment variables
#
# maybe a help about all supported targets would be nice here, too...
#
printenv:
	@echo '============================================================================== '
	@echo "Coolstream Environment Varibles:"
	@echo "CROSS_DIR:           $(CROSS_DIR)"
	@echo "CROSS_BASE:          $(CROSS_BASE)"
	@echo "TARGET:              $(TARGET)"
	@echo "BASE_DIR:            $(BASE_DIR)"
	@echo "BUILD:               $(BUILD)"
	@echo "PATH:                $(PATH)"
	@echo '============================================================================== '
	@PATH=$(PATH):$(CROSS_DIR)/bin && \
	if type -p $(TARGET)-gcc >/dev/null 2>&1; then \
		echo "$(TARGET)-gcc found in PATH or in \$$CROSS_DIR/bin."; \
	else \
		echo "$(TARGET)-gcc not found in PATH or \$$CROSS_DIR/bin"; \
		echo "please check your setup."; \
	fi
	@echo ""
	@echo "a few helpful make targets:"
	@echo "* make preqs         - downloads necessary stuff"
	@echo "* make bootstrap     - prepares for building"
	@echo "* make neutrino      - builds neutrino"
	@echo ""
	@echo "later, you might find those useful:"
	@echo "* make update-self     - update the build system"
	@echo "* make update-neutrino - update the neutrino source"
	@echo ""

include make/prerequisites.mk
include make/bootstrap.mk
include make/system-libs.mk
include make/system-tools.mk
#include make/tuxbox.mk
include make/neutrino.mk
#include make/cleantargets.mk
include make/linuxkernel.mk

update-self:
	git pull

update-neutrino:
	cd $(SOURCE_DIR)/neutrino-hd && git pull

all:
	@echo "'make all' is not a valid target. Please read the documentation."

# for local extensions, e.g. special plugins or similar...
# put them into $(BASE_DIR)/local since that is ignored in .gitignore
-include ./Makefile.local

