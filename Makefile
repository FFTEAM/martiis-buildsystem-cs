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
	@echo "N_HD_SOURCE:         $(N_HD_SOURCE)"
	@echo '============================================================================== '
	@PATH=$(PATH):$(CROSS_DIR)/bin && \
	if type -p $(TARGET)-gcc >/dev/null 2>&1; then \
		echo "$(TARGET)-gcc found in PATH or in \$$CROSS_DIR/bin."; \
	else \
		echo "$(TARGET)-gcc not found in PATH or \$$CROSS_DIR/bin"; \
		echo "please check your setup. Maybe you want to 'make crosstool'."; \
	fi
	@echo ""
	@echo "a few helpful make targets:"
	@echo "* make preqs             - downloads necessary stuff"
	@echo "* make crosstool         - build cross toolchain"
	@echo "* make bootstrap         - prepares for building"
	@echo "* make neutrino          - builds neutrino"
	@echo "* make neutrino-system   - should build enough to have a bootable system"
	@echo ""
	@echo "later, you might find those useful:"
	@echo "* make update-self       - update the build system"
	@echo "* make update-neutrino   - update the neutrino source"
	@echo "* make update-svn        - update the coolstream svn parts (mainly drivers)"
	@echo "* make update-svn-target - copy updated svn parts into \$$TARGETPREFIX"
	@echo ""
	@echo "cleantargets:"
	@echo "make clean               - clean neutrino build dir"
	@echo "make rebuild-clean       - additionally remove \$$TARGETPREFIX, but keep the toolchain"
	@echo "                           after that you need to restart with 'bootstrap'"
	@echo "make all-clean           - additionally remove the crosscompiler"
	@echo "                           you usually don't want to do that."
	@echo ""

include make/prerequisites.mk
include make/bootstrap.mk
include make/system-libs.mk
include make/system-tools.mk
#include make/tuxbox.mk
include make/neutrino.mk
include make/cleantargets.mk
include make/linuxkernel.mk
include make/archives.mk
include make/rootfs.mk

update-self:
	git pull

update-neutrino:
	make check-repo
	cd $(N_HD_SOURCE) && git pull

# only updates important(?) stuff, no crosstool etc.
update-svn:
	cd $(SOURCE_DIR)/svn/COOLSTREAM && $(SVN) up
	cd $(SOURCE_DIR)/svn/THIRDPARTY/libraries && $(SVN) up *
	if [ -d $(SOURCE_DIR)/svn/THIRDPARTY/applications ]; then \
		cd $(SOURCE_DIR)/svn/THIRDPARTY/applications && $(SVN) up *; \
	else true; fi
	cd $(SOURCE_DIR)/svn/CROSSENVIROMENT/coolstream && $(SVN) up

update-svn-target:
	make cs-modules includes-and-libs

all:
	@echo "'make all' is not a valid target. Please read the documentation."

# for local extensions, e.g. special plugins or similar...
# put them into $(BASE_DIR)/local since that is ignored in .gitignore
-include ./Makefile.local

.print-phony:
	@echo $(PHONY)

PHONY += all printenv .print-phony
PHONY += update-svn update-svn-target update-neutrino update-self
.PHONY: $(PHONY)

# this makes sure we do not build top-level dependencies in parallel
# (which would not be too helpful anyway, running many configure and
# downloads in parallel...), but the sub-targets are still built in
# parallel, which is useful on multi-processor / multi-core machines
.NOTPARALLEL:
