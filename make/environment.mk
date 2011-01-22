# set up environment for other makefiles

BASE_DIR    = $(shell pwd)
include $(BASE_DIR)/config

ifeq ($(PLATFORM), tripledragon)
TARGET      ?= powerpc-405-linux-gnu
FLAVOUR     ?= neutrino-hd-tripledragon
BOXARCH      = powerpc
else
PLATFORM    ?= coolstream
TARGET      ?= arm-cx2450x-linux-gnueabi
FLAVOUR     ?= neutrino-hd
BOXARCH      = arm
endif

WHOAMI       = $(shell id -un)
MAINTAINER  ?= $(shell sh -c "getent passwd $(WHOAMI)|awk -F: '{print \$$5}'")

## needed for the old Tripledragon crosstool
# crosstool puts "...-glibc-2.3.6-tls" configs still into "...-glibc-2.3.6"
CROSS_BUILD_VER = gcc-3.4.5-glibc-2.3.6-tls
CROSS_BUILD_DIR = $(CROSS_BUILD_VER:-tls=)

ARCHIVE      = $(BASE_DIR)/download
PATCHES      = $(BASE_DIR)/archive-patches
BUILD_TMP    = $(BASE_DIR)/build_tmp
D            = $(BASE_DIR)/deps
# backwards compatibility
DEPDIR       = $(D)

HOSTPREFIX   = $(BASE_DIR)/host
TARGETPREFIX = $(BASE_DIR)/root
PKGPREFIX    = $(BUILD_TMP)/pkg
FROOTFS      = $(BASE_DIR)/root-flash
SOURCE_DIR   = $(BASE_DIR)/source
MAKE_DIR     = $(BASE_DIR)/make
CONTROL_DIR  = $(BASE_DIR)/pkgs/control
PACKAGE_DIR  = $(BASE_DIR)/pkgs/opkg

CROSS_BASE   = $(BASE_DIR)/cross
ifeq ($(PLATFORM), tripledragon)
# old crosstool compatibility
CROSS_DIR   ?= $(CROSS_BASE)/$(CROSS_BUILD_DIR)/$(TARGET)
else
CROSS_DIR   ?= $(CROSS_BASE)
endif

BUILD       ?= $(shell /usr/share/libtool/config.guess 2>/dev/null || /usr/share/libtool/config/config.guess)

TARGETLIB       = $(TARGETPREFIX)/lib
TARGET_CFLAGS   = -pipe -O2 -g -I$(TARGETPREFIX)/include
TARGET_CPPFLAGS = $(TARGET_CFLAGS)
TARGET_CXXFLAGS = $(TARGET_CFLAGS)
TARGET_LDFLAGS  = -Wl,-O1 -L$(TARGETLIB)
LD_FLAGS        = $(TARGET_LDFLAGS)

VPATH = $(D)

ifeq ("$(FLAVOUR)", "neutrino-hd-tripledragon")
N_HD_SOURCE = $(SOURCE_DIR)/neutrino-hd-td
else
N_HD_SOURCE = $(SOURCE_DIR)/neutrino-hd
endif

PATH := $(HOSTPREFIX)/bin:$(CROSS_DIR)/bin:$(PATH)
PKG_CONFIG = /usr/bin/pkg-config
PKG_CONFIG_PATH = $(TARGETPREFIX)/lib/pkgconfig

# helper-"functions":
REWRITE_LIBTOOL = sed -i "s,^libdir=.*,libdir='$(TARGETLIB)'," $(TARGETLIB)
REWRITE_PKGCONF = sed -i "s,^prefix=.*,prefix='$(TARGETPREFIX)',"
REWRITE_LIBTOOL_OPT = sed -i "s,^libdir=.*,libdir='$(TARGETPREFIX)/opt/pkg/lib'," $(TARGETPREFIX)/opt/pkg/lib
REWRITE_PKGCONF_OPT = sed -i "s,^prefix=.*,prefix='$(TARGETPREFIX)/opt/pkg',"

# unpack tarballs, clean up
UNTAR = tar -C $(BUILD_TMP) -xf $(ARCHIVE)
REMOVE = rm -rf $(BUILD_TMP)
PATCH = patch -p1 -i $(PATCHES)
# wget tarballs into archive directory
WGET = wget -t3 -T10 -c -P $(ARCHIVE)

CONFIGURE_OPTS = \
	--build=$(BUILD) --host=$(TARGET)

BUILDENV = \
	CFLAGS="$(TARGET_CFLAGS)" \
	CPPFLAGS="$(TARGET_CPPFLAGS)" \
	CXXFLAGS="$(TARGET_CXXFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS)" \
	PKG_CONFIG_PATH=$(PKG_CONFIG_PATH)

CONFIGURE = \
	test -f ./configure || ./autogen.sh && \
	$(BUILDENV) \
	./configure $(CONFIGURE_OPTS)

ifeq ($(PLATFORM), tripledragon)
SVN   ?= svn --username dragon --password dragon --no-auth-cache
SVNCO ?= $(SVN) export http://www.no-access.de/tdsvn
else
SVN   ?= svn --username coolstream --password coolstream --no-auth-cache
SVNCO ?= $(SVN) co http://www.coolstreamtech.de/coolstream_public_svn
endif

# shortcuts
SVN_TP_LIBS = $(SOURCE_DIR)/svn/THIRDPARTY/libraries
SVN_TP_APPS = $(SOURCE_DIR)/svn/THIRDPARTY/applications
TD_SVN = $(SOURCE_DIR)/tdsvn
