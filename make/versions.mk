# Makefile to define the versions of the packages
# define the version of a package here, so you don't have to write
# it everyvere in different makefiles and its targets

# !!! If you change a version of an package, please check if a patchfile
# !!! is also to addapt. Even if a patch is named with the version 
# !!! inside the string it is expandable with the version variable.

###########################
# Libs; make/system-libs.mk
###########################

# azbox-dvb-modules
AZBOX_DVB_M_VER=20120629

# libdid3tag; writing, reading and manipulating ID3 tags
ID3TAG_VER=0.15.1
ID3TAG_SUBVER=b

# libmad; MPEG audio decoder
MAD_VER=0.15.1b

# libungif; converting images
UNGIF_VER=4.1.4

# libiconv; converting encodings
ICONV-VER=1.14

# iperf: network performance measurement
IPERF-VER=2.0.5

# zlib; compression an decompressin library
ZLIB_VER=1.2.6

# util-linux-ng; tools for filesystems, partitions, console und system messages
UTIL_LINUX_NG_VER=2.18

# curl; command line tool for transferring data with URL syntax
CURL_VER=7.26.0

# libpng; reference library for reading and writing PNGs
PNG-VER=1.2.44

# freetype; free, high-quality and portable Font engine
FREETYPE_VER=2.3.12

# libjpeg-turbo; a derivative of libjpeg for x86 and x86-64 processors which uses SIMD instructions (MMX, SSE2, etc.) to accelerate baseline JPEG compression and decompression
JPEG_TURBO_VER=1.1.1

# boost; portable C++ source library
BOOST_MAJOR=1
BOOST_MINOR=49
BOOST_MICRO=0
BOOST_VER=$(BOOST_MAJOR)_$(BOOST_MINOR)_$(BOOST_MICRO)

# openssl; toolkit for the SSL v2/v3 and TLS v1 protocol
OPENSSL_VER=0.9.8
OPENSSL_SUBVER=q

# libffmpeg; complete, cross-platform solution to record, convert and stream audio and video
FFMPEG_VER=0.10

# libogg; encoding, decoding of the ogg file format
OGG_VER=1.1.4

# libvorbis; encoding, decoding fixed or variable bitrates of ogg vorbis formats
VORBIS_VER=1.2.3

# libass: ass / ssa subtitle renderer
LIBASS_VER=0.9.11

# azbox kernel
LINUX_AZBOX_VER=3.3.1

# LIRC: linux infrared control
LIRC_VER=0.9.0

# ncurses; software for controlling writing to the console screen
NCURSES_VER=5.6

# DirectFB; thin library that provides hardware graphics acceleration, input device handling and abstraction
DIRECTFB_VER=1.4.3

# libdvdcss: a simple library designed for accessing DVDs like a block device
# without having to bother about the decryption.
DVDCSS_VER=1.2.12

# libvorbisidec;  libvorbisidec is an Ogg Vorbis audio decoder (also known as "tremor") with no floating point arithmatic
VORBISIDEC_VER=1.0.2+svn16259
VORBISIDEC_VER_APPEND=.orig

# libpcap; system-independent interface for user-level packet capture
LIBPCAP_VER=1.2.0

# libcap; setting and proofing POSIX.1e functionality (Version 2!)
LIBCAP2_VER=2.22

# flex; fast lexical analyser generator
FLEX_VER=2.5.35

# libexpat; XML parser
EXPAT_VER=2.0.1

# attr; setting up extended attributes
ATTR_VER=2.4.44

# libdvbsi++; libdvbsi++ is a open source C++ library for parsing DVB Service Information and MPEG-2 Program Specific Information.
LIBDVBSI_VER=0.3.6

#############################
# tools; make/system-tools.mk
#############################

# vsftpd; a small, tiny and "v"ery "s"ecure "ftp" deamon
VSFTPD_VER=2.3.5

# rsync; fast and extraordinarily versatile file copying tool
RSYNC-VER=3.0.7

# pkg-config; a helper tool used when compiling applications and libraries to insert the correct compiler options
PKGCONFIG_VER=0.26

# procps; a bunch of small useful utilities that give information about processes using the /proc filesystem
PROCPS-VER=3.2.8

# busybox; combines tiny versions of many common UNIX utilities into a single binary
#BUSYBOX-VER=1.19.4
BUSYBOX-VER=1.20.2

# e2fsprogs; filesystem utilities for use with the ext[x] filesystem
E2FSPROGS-VER=1.42

# yaffs2utils; filesystem utilities for YAFFS2 filesystems
YAFFS2UTILS-VER=0.2.9

# xfsprogs; Utilities for managing the XFS filesystem
XFSPROGS-VER=3.1.8

# ntfs-3g; file system driver for the NTFS file system, enabling read/write support of NTFS file systems
NTFS_3G_VER=2012.1.15

# autofs; mounting filesystems on demand
AUTOFS-VER=4.1.4

# samba; standard Windows interoperability suite of programs for Linux and Unix
SAMBA2-VER=2.2.12
SAMBA3-VER=

# portmap; an ONC RPC service that runs on network nodes that provide other ONC RPC services
PORTMAP-VER=6.0

# unfs3; a user-space implementation of the NFSv3 server specification
UNFS3-VER=0.9.22

# fbshot;  a small program that allowes you to take screenshots from the framebuffer
FBSHOT-VER=0.3

# tcpdump. if you don't know it, you don't need it.
TCPDUMP-VER=4.2.0

# timezone files
TZ_VER = 2012b

# systemd; a system and service manager for Linux
SYSTEMD-VER=19

# dbus; message bus system
DBUS-VER=1.4.6

# ntp; synchronize system clock over a network
NTP_VER=4.2.6p5

#########################
# extras; make/extras.mk
########################

GSTREAMER_VER=0.10.36
GST_PLUG_GOOD_VER=0.10.31
GST_PLUG_BAD_VER=0.10.23
GST_FFMPEG_VER=0.10.13
GST123_VER=0.3.1

# links; a text WWW browser, similar to Lynx
LINKS-VER=2.3pre1

# qt-everythere-opensource-src; the Qt4 package contains several C++ libraries with both GUI and non-GUI components
QT-VER=4.6.3

# nbench; a benchmark program that will measure the performance
NBENCH_BYTE-VER=2.2.3

# libupnp; a portable open source UPnP development kit
LIBUPNP-VER=1.6.10

LIBXML2_VER=2.8.0

# dropbear; a relatively small SSH 2 server and client
DROPBEAR-VER=0.53.1

# opkg; a lightweight package management system based on Ipkg
OPKG-VER=0.1.8

# for recent versions, the SVN trunk rev is used:
OPKG_SVN=635
OPKG_SVN_VER=$(OPKG-VER)+svnr$(OPKG_SVN)

# glib; the low-level core library that forms the basis for projects such as GTK+ and GNOME
GLIB-MAJOR=2
GLIB-MINOR=26
GLIB-MICRO=1
GLIB-VER=$(GLIB-MAJOR).$(GLIB-MINOR).$(GLIB-MICRO)

# mc; the famous midnight commander
MC-VER=4.6.2

# sg3_utils; a package of utilities for accessing devices that use SCSI command sets
SG3_UTILS-VER=1.33

# FUSE; filesystems in userspace
FUSE_VER=2.8.5

# ALSA, the Advanced Linux Sound Architecture
ALSA_VER=1.0.25

##################################
# devel-tools; make/devel-tools.mk
##################################

# gdb; the GNU debugger
GDB_VER=7.3

# mtd-utils for the host...
MTD_UTILS_VER = 1.4.9
