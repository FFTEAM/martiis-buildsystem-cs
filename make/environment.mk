# set up environment for other makefiles

BASE_DIR    = $(shell pwd)
include $(BASE_DIR)/config

# crosstool puts "...-glibc-2.3.6-tls" configs still into "...-glibc-2.3.6"
CROSS_BUILD_DIR = $(CROSS_BUILD_VERSION:-tls=)

ARCHIVE      = $(BASE_DIR)/download
PATCHES      = $(BASE_DIR)/archive-patches
#TARGET      ?= powerpc-405-linux-gnu
BUILD_TMP    = $(BASE_DIR)/build_tmp
DEPDIR       = $(BASE_DIR)/deps

APPSDIR      = $(BASE_DIR)/tuxbox.org/apps
HOSTPREFIX   = $(BASE_DIR)/host
TARGETPREFIX = $(BASE_DIR)/root
FROOTFS      = $(BASE_DIR)/root-flash
SOURCE_DIR   = $(BASE_DIR)/source

CROSS_BASE   = $(BASE_DIR)/cross
CROSS_DIR   ?= $(CROSS_BASE)/$(CROSS_BUILD_DIR)/$(TARGET)

BUILD       ?= $(shell /usr/share/libtool/config/config.guess)

TARGETLIB       = $(TARGETPREFIX)/lib
TARGET_CFLAGS   = -pipe -O2 -g -I$(TARGETPREFIX)/include
TARGET_CPPFLAGS = $(TARGET_CFLAGS)
TARGET_CXXFLAGS = $(TARGET_CFLAGS)
TARGET_LDFLAGS  = -Wl,-O1 -L$(TARGETLIB)
LD_FLAGS        = $(TARGET_LDFLAGS)

VPATH = $(DEPDIR)

PATH := $(HOSTPREFIX)/bin:$(CROSS_DIR)/bin:$(PATH)
PKG_CONFIG = /usr/bin/pkg-config
PKG_CONFIG_PATH = $(TARGETPREFIX)/lib/pkgconfig

# helper-"functions":
REWRITE_LIBTOOL = sed -i "s,^libdir=.*,libdir='$(TARGETPREFIX)/lib',"
REWRITE_PKGCONF = sed -i "s,^prefix=.*,prefix='$(TARGETPREFIX)',"


CONFIGURE_OPTS = \
	--build=$(BUILD) --host=$(TARGET) \
	--enable-maintainer-mode \

BUILDENV = \
	CFLAGS="-W -Wall $(TARGET_CFLAGS)" \
	CPPFLAGS="$(TARGET_CPPFLAGS)" \
	CXXFLAGS="-W -Wall $(TARGET_CXXFLAGS)" \
	LDFLAGS=" -Wl,-O1 -L$(TARGETPREFIX)/lib" \
	PKG_CONFIG_PATH=$(PKG_CONFIG_PATH)

CONFIGURE = \
	test -f ./configure || ./autogen.sh && \
	$(BUILDENV) \
	./configure $(CONFIGURE_OPTS)

