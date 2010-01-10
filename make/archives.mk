# makefile for tarball download

$(ARCHIVE)/autofs-4.1.4.tar.bz2:
	$(WGET) http://www.kernel.org/pub/linux/daemons/autofs/v4/autofs-4.1.4.tar.bz2

$(ARCHIVE)/zlib-1.2.3.tar.bz2:
	$(WGET) http://downloads.sourceforge.net/project/libpng/zlib/1.2.3/zlib-1.2.3.tar.bz2?use_mirror=switch

$(ARCHIVE)/libmad-0.15.1b.tar.gz:
	$(WGET) http://downloads.sourceforge.net/project/mad/libmad/0.15.1b/libmad-0.15.1b.tar.gz?use_mirror=switch

$(ARCHIVE)/libid3tag-0.15.1b.tar.gz:
	$(WGET) http://downloads.sourceforge.net/project/mad/libid3tag/0.15.1b/libid3tag-0.15.1b.tar.gz?use_mirror=switch

$(ARCHIVE)/libungif-4.1.3.tar.bz2:
	$(WGET) ftp://ftp.splack.org/pub/alphaslack/alphaslack-8.3.0/source/l/libungif/libungif-4.1.3.tar.bz2

$(ARCHIVE)/curl-7.19.7.tar.bz2:
	$(WGET) ftp://gentoo.imj.fr/pub/gentoo/distfiles/curl-7.19.7.tar.bz2

$(ARCHIVE)/libpng-1.2.40.tar.bz2:
	$(WGET) http://downloads.sourceforge.net/project/libpng/00-libpng-stable/1.2.40/libpng-1.2.40.tar.bz2?use_mirror=switch

$(ARCHIVE)/freetype-2.3.9.tar.bz2:
	$(WGET) http://downloads.sourceforge.net/project/freetype/freetype2/2.3.9/freetype-2.3.9.tar.bz2?use_mirror=switch

$(ARCHIVE)/jpegsrc.v6b.tar.gz:
	$(WGET) ftp://slackware.su29.ru/pub/linux/slackware/slackware-10.0/source/l/libjpeg/jpegsrc.v6b.tar.gz

$(ARCHIVE)/boost_1_40_0.tar.bz2:
	$(WGET) http://downloads.sourceforge.net/project/boost/boost/1.40.0/boost_1_40_0.tar.bz2?use_mirror=switch

$(ARCHIVE)/openssl-0.9.8l.tar.gz:
	$(WGET) http://www.openssl.org/source/openssl-0.9.8l.tar.gz

$(ARCHIVE)/ffmpeg-0.5.tar.bz2:
	$(WGET) ftp://ftp.wh8.tu-dresden.de/pub/linux/distributions/gentoo/distfiles/ffmpeg-0.5.tar.bz2

$(ARCHIVE)/libogg-1.1.4.tar.gz:
	$(WGET) http://downloads.xiph.org/releases/ogg/libogg-1.1.4.tar.gz

$(ARCHIVE)/libvorbis-1.2.3.tar.bz2:
	$(WGET) http://downloads.xiph.org/releases/vorbis/libvorbis-1.2.3.tar.bz2

$(ARCHIVE)/ncurses-5.6.tar.gz:
	$(WGET) ftp://ftp.informatik.uni-hamburg.de/pub/soft/gnu/ncurses/ncurses-5.6.tar.gz

$(ARCHIVE)/libvorbisidec_1.0.2+svn14261.orig.tar.gz:
	$(WGET) http://ftp.de.debian.org/debian/pool/main/libv/libvorbisidec/libvorbisidec_1.0.2+svn14261.orig.tar.gz

$(ARCHIVE)/libpcap-1.0.0.tar.gz:
	$(WGET) ftp://ftp.wh8.tu-dresden.de/pub/linux/distributions/gentoo/distfiles/libpcap-1.0.0.tar.gz

$(ARCHIVE)/rsync-3.0.6.tar.gz:
	$(WGET) http://samba.anu.edu.au/ftp/rsync/src/rsync-3.0.6.tar.gz

$(ARCHIVE)/procps-3.2.7.tar.gz:
	$(WGET) http://procps.sourceforge.net/procps-3.2.7.tar.gz

$(ARCHIVE)/busybox-1.15.2.tar.bz2:
	$(WGET) http://busybox.net/downloads/busybox-1.15.2.tar.bz2

$(ARCHIVE)/strace-4.5.19.tar.bz2:
	$(WGET) http://downloads.sourceforge.net/project/strace/strace/4.5.19/strace-4.5.19.tar.bz2?use_mirror=switch

$(ARCHIVE)/e2fsprogs-1.41.9.tar.gz:
	$(WGET) http://downloads.sourceforge.net/project/e2fsprogs/e2fsprogs/1.41.9/e2fsprogs-1.41.9.tar.gz?use_mirror=switch

$(ARCHIVE)/gdb-7.0.tar.bz2:
	$(WGET) http://ftp.gnu.org/gnu/gdb/gdb-7.0.tar.bz2
