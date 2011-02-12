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
IVONV-VER=1.13.1

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
JPEG_TURBO-VER=1.0.1

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

# flex; fast lexical analyser generator
FLEX-VER=2.5.35

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
BUSYBOX-VER=1.15.2

# e2fsprogs; filesystem utilities for use with the ext[x] filesystem
E2FSPROGS-VER=1.41.12

# xfsprogs; Utilities for managing the XFS filesystem
XFSPROGS-VER=3.1.4

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
