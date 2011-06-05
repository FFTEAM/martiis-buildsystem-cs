# Makefile to define the versions of the packages
# define the version of a package here, so you don't have to write
# it everyvere in different makefiles and its targets

# !!! If you change a version of an package, please check if a patchfile
# !!! is also to addapt. Even if a patch is named with the version 
# !!! inside the string it is expandable with the version variable.

###########################
# Libs; make/system-libs.mk
###########################

# libdid3tag; writing, reading and manipulating ID3 tags
ID3TAG-VER=0.15.1
ID3TAG-SUBVER=b

# libmad; MPEG audio decoder
MAD-VER=0.15.1b

# libungif; converting images
UNGIF-VER=4.1.4

# libiconv; converting encodings
ICONV-VER=1.13.1

# zlib; compression an decompressin library
ZLIB-VER=1.2.5

# util-linux-ng; tools for filesystems, partitions, console und system messages
UTIL_LINUX_NG-VER=2.18

# curl; command line tool for transferring data with URL syntax
CURL-VER=7.20.0

# libpng; reference library for reading and writing PNGs
PNG-VER=1.2.44

# freetype; free, high-quality and portable Font engine
FREETYPE-VER=2.3.12

# libjpeg-turbo; a derivative of libjpeg for x86 and x86-64 processors which uses SIMD instructions (MMX, SSE2, etc.) to accelerate baseline JPEG compression and decompression
JPEG_TURBO-VER=1.1.0

# boost; portable C++ source library
BOOST-MAJOR=1
BOOST-MINOR=42
BOOST-MICRO=0
BOOST-VER=$(BOOST-MAJOR)_$(BOOST-MINOR)_$(BOOST-MICRO)

# openssl; toolkit for the SSL v2/v3 and TLS v1 protocol
OPENSSL-VER=0.9.8
OPENSSL-SUBVER=q

# libffmpeg; complete, cross-platform solution to record, convert and stream audio and video
FFMPEG-VER=0.6

# libogg; encoding, decoding of the ogg file format
OGG-VER=1.1.4

# libvorbis; encoding, decoding fixed or variable bitrates of ogg vorbis formats
VORBIS-VER=1.2.3

# ncurses; software for controlling writing to the console screen
NCURSES-VER=5.6

# DirectFB; thin library that provides hardware graphics acceleration, input device handling and abstraction
DIRECTFB-VER=1.4.3

# libvorbisidec;  libvorbisidec is an Ogg Vorbis audio decoder (also known as "tremor") with no floating point arithmatic
VORBISIDEC-VER=1.0.2+svn16259
VORBISIDEC-VER_APPEND=.orig

# libpcap; system-independent interface for user-level packet capture
PCAP-VER=1.0.0

# libcap2; setting and proofing POSIX.1e functionality
LIBCAP2-VER=2.20

# flex; fast lexical analyser generator
FLEX-VER=2.5.35

# libexpat; XML parser
EXPAT-VER=2.0.1

# attr; setting up extended attributes
ATTR-VER=2.4.44

#############################
# tools; make/system-tools.mk
#############################

# vsftpd; a small, tiny and "v"ery "s"ecure "ftp" deamon
VSFTPD-VER=2.2.2

# rsync; fast and extraordinarily versatile file copying tool
RSYNC-VER=3.0.7

# procps; a bunch of small useful utilities that give information about processes using the /proc filesystem
PROCPS-VER=3.2.8

# busybox; combines tiny versions of many common UNIX utilities into a single binary
BUSYBOX-VER=1.18.4

# e2fsprogs; filesystem utilities for use with the ext[x] filesystem
E2FSPROGS-VER=1.41.12

# xfsprogs; Utilities for managing the XFS filesystem
XFSPROGS-VER=3.1.5

# ntfs-3g; file system driver for the NTFS file system, enabling read/write support of NTFS file systems
NTFS_3G-VER=2011.1.15

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

# systemd; a system and service manager for Linux
SYSTEMD-VER=19

# dbus; message bus system
DBUS-VER=1.4.6

#########################
# extras; make/extras.mk
########################

# links; a text WWW browser, similar to Lynx
LINKS-VER=2.3pre1

# qt-everythere-opensource-src; the Qt4 package contains several C++ libraries with both GUI and non-GUI components
QT-VER=4.6.3

# nbench; a benchmark program that will measure the performance
NBENCH_BYTE-VER=2.2.3

# libupnp; a portable open source UPnP development kit
LIBUPNP-VER=1.6.10

# dropbear; a relatively small SSH 2 server and client
DROPBEAR-VER=0.53.1

# opkg; a lightweight package management system based on Ipkg
OPKG-VER=0.1.8

# glib; the low-level core library that forms the basis for projects such as GTK+ and GNOME
GLIB-MAJOR=2
GLIB-MINOR=24
GLIB-MICRO=1
GLIB-VER=$(GLIB-MAJOR).$(GLIB-MINOR).$(GLIB-MICRO)

# mc; the famous midnight commander
MC-VER=4.6.2

# sg3_utils; a package of utilities for accessing devices that use SCSI command sets
SG3_UTILS-VER=1.30

