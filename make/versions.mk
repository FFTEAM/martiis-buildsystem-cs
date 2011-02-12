# Makefile to define the versions of the packages
# define the version of a package here, so you don't have to write
# it everyvere in different makefiles and its targets

######
# Libs
######

# libdid3tag; writing, reading and manipulating ID3 tags
ID3TAG-VER=0.15.1b

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

