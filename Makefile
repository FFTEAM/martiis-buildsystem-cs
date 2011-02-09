#master makefile
include make/environment.mk

############################################################################
#  A print out of environment variables
#
# maybe a help about all supported targets would be nice here, too...
#
printenv:
	@echo '============================================================================== '
	@echo "Build Environment Varibles:"
	@echo "CROSS_DIR:   $(CROSS_DIR)"
	@echo "CROSS_BASE:  $(CROSS_BASE)"
	@echo "TARGET:      $(TARGET)"
	@echo "BASE_DIR:    $(BASE_DIR)"
	@echo "BUILD:       $(BUILD)"
	@echo "PATH:        `type -p fmt>/dev/null&&echo $(PATH)|sed 's/:/ /g' |fmt -65|sed 's/ /:/g; 2,$$s/^/             /;'||echo $(PATH)`"
	@echo "N_HD_SOURCE: $(N_HD_SOURCE)"
	@echo "BOXARCH:     $(BOXARCH)"
	@echo "PLATFORM:    $(PLATFORM)"
	@echo "MAINTAINER:  $(MAINTAINER)"
	@echo '============================================================================== '
	@echo ""
	@echo "'make help' lists useful targets."
	@echo "The doc/ directory contains documentation. Read it."
	@echo ""
	@make --no-print-directory toolcheck
ifeq ($(MAINTAINER),)
	@echo "##########################################################################"
	@echo "# The MAINTAINER variable is not set. It defaults to your name from the  #"
	@echo "# passwd entry, but this seems to have failed. Please set it in 'config'.#"
	@echo "##########################################################################"
	@echo
endif
	@make -i -s $(TARGETPREFIX)
	@PATH=$(PATH):$(CROSS_DIR)/bin && \
	if type -p $(TARGET)-gcc >/dev/null 2>&1; then \
		echo "$(TARGET)-gcc found in PATH or in \$$CROSS_DIR/bin."; \
	else \
		echo "$(TARGET)-gcc not found in PATH or \$$CROSS_DIR/bin"; \
		echo "=> please check your setup. Maybe you need to 'make crosstool'."; \
	fi
	@if ! LANG=C make -n preqs|grep -q "Nothing to be done"; then \
		echo;echo "Your next target to do is probably 'make preqs'"; fi
	@if ! test -e $(BASE_DIR)/config; then \
		echo;echo "If you want to change the configuration, copy 'doc/config.example' to 'config'"; \
		echo "and edit it to fit your needs. See the comments in there."; echo; fi

help:
	@echo "a few helpful make targets:"
	@echo "* make preqs             - downloads necessary stuff"
	@echo "* make crosstool         - build cross toolchain"
	@echo "* make bootstrap         - prepares for building"
	@echo "* make neutrino          - builds neutrino"
	@echo "* make neutrino-system   - should build enough to have a bootable system"
	@echo "* make devel-tools       - build gdb and strace for the target"
	@echo ""
	@echo "later, you might find those useful:"
	@echo "* make update-self       - update the build system"
	@echo "* make update-neutrino   - update the neutrino source"
ifeq ($(PLATFORM), coolstream)
	@echo "* make update-svn        - update the coolstream svn parts (mainly drivers)"
	@echo "* make update-svn-target - copy updated svn parts into \$$TARGETPREFIX"
endif
	@echo ""
	@echo "cleantargets:"
	@echo "make clean               - clean neutrino build dir"
	@echo "make rebuild-clean       - additionally remove \$$TARGETPREFIX, but keep the toolchain"
	@echo "                           after that you need to restart with 'bootstrap'"
	@echo "make all-clean           - additionally remove the crosscompiler"
	@echo "                           you usually don't want to do that."

include make/prerequisites.mk
include make/bootstrap.mk
include make/system-libs.mk
include make/system-tools.mk
include make/devel-tools.mk
#include make/tuxbox.mk
include make/neutrino.mk
include make/cleantargets.mk
include make/linuxkernel.mk
include make/archives.mk
include make/extras.mk
include make/packages.mk

update-self:
	git pull

ifneq ($(PLATFORM), tripledragon)
# TODO: maybe the more sophisticated mechanism used on TD would
#       be useful here, too? tell me what you think!
update-neutrino:
	make check-repo
	cd $(N_HD_SOURCE) && git pull

# only updates important(?) stuff, no crosstool etc.
# not useful on tripledragon, because that SVN never changes
update-svn: | $(SOURCE_DIR)/svn/THIRDPARTY/lib
	cd $(SOURCE_DIR)/svn/COOLSTREAM && $(SVN) up
	cd $(SVN_TP_LIBS) && $(SVN) up *
	if [ -d $(SVN_TP_APPS) ]; then \
		cd $(SVN_TP_APPS) && $(SVN) up *; \
	else true; fi
	cd $(SOURCE_DIR)/svn/THIRDPARTY/lib && $(SVN) up *
	cd $(SOURCE_DIR)/svn/CROSSENVIROMENT/coolstream && $(SVN) up

update-svn-target:
	make cs-modules includes-and-libs
else
NOW = $(shell date +%Y%m%d-%H%M%S)
N_HD_SOURCE_S = $(subst $(BASE_DIR)/,"",$(N_HD_SOURCE))

update-svn:
	@echo "update-svn is not useful on $(PLATFORM)"

update-neutrino:
	-cd $(N_HD_SOURCE) && { git branch "before-update-$(NOW)"; git stash save "before update $(NOW)" ; git pull; }
	@echo ""
	@echo "Sources updated. Local changes before update were stashed away,"
	@echo "try 'git stash list' in $(N_HD_SOURCE_S) and restore with"
	@echo "'git stash pop' there."
	@echo ""
	@echo "If you had lots of merge errors, then this is probably due to"
	@echo "a rebased upstream tree. In this case, the easiest way to recover"
	@echo "is probably to do 'make update-neutrino-hard', which will do a"
	@echo "'git reset --hard origin/master' in $(N_HD_SOURCE_S)".
	@echo ""
	@echo "The state before update was saved in branch 'before-update-$(NOW)'"

update-neutrino-hard:
	cd $(N_HD_SOURCE) && git reset --hard origin/master
endif


all:
	@echo "'make all' is not a valid target. Please read the documentation."

# target for testing only. not useful otherwise
everything: $(shell sed -n 's/^\$$.D.\/\(.*\):.*/\1/p' make/*.mk)

# for local extensions, e.g. special plugins or similar...
# put them into $(BASE_DIR)/local since that is ignored in .gitignore
-include ./Makefile.local

.print-phony:
	@echo $(PHONY)

PHONY += everything
PHONY += all printenv .print-phony
PHONY += update-svn update-svn-target update-neutrino update-self
.PHONY: $(PHONY)

# this makes sure we do not build top-level dependencies in parallel
# (which would not be too helpful anyway, running many configure and
# downloads in parallel...), but the sub-targets are still built in
# parallel, which is useful on multi-processor / multi-core machines
.NOTPARALLEL:
