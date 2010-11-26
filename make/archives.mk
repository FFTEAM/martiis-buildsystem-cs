# makefile for tarball download

$(ARCHIVE)/autofs-4.1.4.tar.bz2:
	$(WGET) http://www.kernel.org/pub/linux/daemons/autofs/v4/autofs-4.1.4.tar.bz2

$(ARCHIVE)/DirectFB-1.4.3.tar.gz:
	$(WGET) http://directfb.org/downloads/Core/DirectFB-1.4/DirectFB-1.4.3.tar.gz

$(ARCHIVE)/libmad-0.15.1b.tar.gz:
	$(WGET) http://downloads.sourceforge.net/project/mad/libmad/0.15.1b/libmad-0.15.1b.tar.gz?use_mirror=switch

$(ARCHIVE)/libiconv-1.13.1.tar.gz:
	$(WGET) http://ftp.gnu.org/gnu/libiconv/libiconv-1.13.1.tar.gz

$(ARCHIVE)/libid3tag-0.15.1b.tar.gz:
	$(WGET) http://downloads.sourceforge.net/project/mad/libid3tag/0.15.1b/libid3tag-0.15.1b.tar.gz?use_mirror=switch

$(ARCHIVE)/libungif-4.1.4.tar.bz2:
	$(WGET) http://downloads.sourceforge.net/project/giflib/libungif%204.x/libungif-4.1.4/libungif-4.1.4.tar.bz2?use_mirror=switch

$(ARCHIVE)/curl-7.20.0.tar.bz2:
	$(WGET) http://curl.haxx.se/download/curl-7.20.0.tar.bz2

$(ARCHIVE)/libpng-1.2.44.tar.bz2:
	$(WGET) http://downloads.sourceforge.net/project/libpng/03-libpng-previous/1.2.44/libpng-1.2.44.tar.bz2

$(ARCHIVE)/e2fsprogs-1.41.12.tar.gz:
	$(WGET) http://prdownloads.sourceforge.net/e2fsprogs/e2fsprogs-1.41.12.tar.gz

$(ARCHIVE)/fbshot-0.3.tar.gz:
	$(WGET) http://www.sfires.net/stuff/fbshot/fbshot-0.3.tar.gz

$(ARCHIVE)/gdb-7.1.tar.bz2:
	$(WGET) http://ftp.gnu.org/gnu/gdb/gdb-7.1.tar.bz2

$(ARCHIVE)/flex-2.5.35.tar.gz:
	$(WGET) http://prdownloads.sourceforge.net/flex/flex-2.5.35.tar.gz

$(ARCHIVE)/freetype-2.1.4.tar.bz2:
	$(WGET) http://heanet.dl.sourceforge.net/sourceforge/freetype/freetype-2.1.4.tar.bz2

$(ARCHIVE)/freetype-2.3.9.tar.bz2:
	$(WGET) http://downloads.sourceforge.net/project/freetype/freetype2/2.3.9/freetype-2.3.9.tar.bz2?use_mirror=switch

$(ARCHIVE)/freetype-2.3.11.tar.bz2:
	$(WGET) http://downloads.sourceforge.net/project/freetype/freetype2/2.3.11/freetype-2.3.11.tar.bz2?use_mirror=switch

$(ARCHIVE)/freetype-2.3.12.tar.bz2:
	$(WGET) http://downloads.sourceforge.net/project/freetype/freetype2/2.3.12/freetype-2.3.12.tar.bz2?use_mirror=switch

$(ARCHIVE)/jpegsrc.v6b.tar.gz:
	$(WGET) ftp://slackware.su29.ru/pub/linux/slackware/slackware-10.0/source/l/libjpeg/jpegsrc.v6b.tar.gz

$(ARCHIVE)/boost_1_42_0.tar.bz2:
	$(WGET) http://downloads.sourceforge.net/project/boost/boost/1.42.0/boost_1_42_0.tar.bz2?use_mirror=switch

$(ARCHIVE)/openssl-0.9.8m.tar.gz:
	$(WGET) http://www.openssl.org/source/openssl-0.9.8m.tar.gz

$(ARCHIVE)/ffmpeg-0.6.tar.bz2:
	$(WGET) http://www.ffmpeg.org/releases/ffmpeg-0.6.tar.bz2

$(ARCHIVE)/libogg-1.1.4.tar.gz:
	$(WGET) http://downloads.xiph.org/releases/ogg/libogg-1.1.4.tar.gz

$(ARCHIVE)/libvorbis-1.2.3.tar.bz2:
	$(WGET) http://downloads.xiph.org/releases/vorbis/libvorbis-1.2.3.tar.bz2

$(ARCHIVE)/ncurses-5.6.tar.gz:
	$(WGET) http://ftp.gnu.org/pub/gnu/ncurses/ncurses-5.6.tar.gz

$(ARCHIVE)/libvorbisidec_1.0.2+svn14261.orig.tar.gz:
	$(WGET) http://ftp.de.debian.org/debian/pool/main/libv/libvorbisidec/libvorbisidec_1.0.2+svn14261.orig.tar.gz

$(ARCHIVE)/libpcap-1.0.0.tar.gz:
	$(WGET) ftp://ftp.wh8.tu-dresden.de/pub/linux/distributions/gentoo/distfiles/libpcap-1.0.0.tar.gz

$(ARCHIVE)/links-2.3pre1.tar.bz2:
	$(WGET) http://links.twibright.com/download/links-2.3pre1.tar.bz2

$(ARCHIVE)/nbench-byte-2.2.3.tar.gz:
	$(WGET) http://www.tux.org/~mayer/linux/nbench-byte-2.2.3.tar.gz

$(ARCHIVE)/rsync-3.0.7.tar.gz:
	$(WGET) http://samba.anu.edu.au/ftp/rsync/src/rsync-3.0.7.tar.gz

$(ARCHIVE)/portmap-6.0.tgz:
	$(WGET) http://neil.brown.name/portmap/portmap-6.0.tgz

$(ARCHIVE)/procps-3.2.8.tar.gz:
	$(WGET) http://procps.sourceforge.net/procps-3.2.8.tar.gz

$(ARCHIVE)/busybox-1.15.2.tar.bz2:
	$(WGET) http://busybox.net/downloads/busybox-1.15.2.tar.bz2

$(ARCHIVE)/busybox-snapshot.tar.bz2:
	$(WGET) http://busybox.net/downloads/snapshots/busybox-snapshot.tar.bz2

$(ARCHIVE)/qt-everywhere-opensource-src-4.6.3.tar.gz:
	$(WGET) http://get.qt.nokia.com/qt/source/qt-everywhere-opensource-src-4.6.3.tar.gz

$(ARCHIVE)/samba-2.0.10.tar.gz:
	$(WGET) http://samba.org/samba/ftp/old-versions/samba-2.0.10.tar.gz

$(ARCHIVE)/samba-2.2.12.tar.gz:
	$(WGET) http://samba.org/samba/ftp/old-versions/samba-2.2.12.tar.gz

$(ARCHIVE)/samba-3.3.9.tar.gz:
	$(WGET) http://download.samba.org/samba/ftp/old-versions/samba-3.3.9.tar.gz

$(ARCHIVE)/strace-4.5.20.tar.bz2:
	$(WGET) http://downloads.sourceforge.net/project/strace/strace/4.5.20/strace-4.5.20.tar.bz2

$(ARCHIVE)/unfs3-0.9.22.tar.gz:
	$(WGET) http://downloads.sourceforge.net/unfs3/unfs3-0.9.22.tar.gz

$(ARCHIVE)/util-linux-ng-2.18.tar.bz2:
	$(WGET) ftp://ftp.kernel.org/pub/linux/utils/util-linux-ng/v2.18/util-linux-ng-2.18.tar.bz2

$(ARCHIVE)/vsftpd-2.2.2.tar.gz:
	$(WGET) ftp://vsftpd.beasts.org/users/cevans/vsftpd-2.2.2.tar.gz

$(ARCHIVE)/xfsprogs-3.1.3.tar.gz:
	$(WGET) ftp://oss.sgi.com/projects/xfs/cmd_tars/xfsprogs-3.1.3.tar.gz

$(ARCHIVE)/zlib-1.2.5.tar.bz2:
	$(WGET) http://downloads.sourceforge.net/project/libpng/zlib/1.2.5/zlib-1.2.5.tar.bz2
