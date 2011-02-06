# makefile for tarball download

$(ARCHIVE)/autofs-4.1.4.tar.bz2:
	$(WGET) http://www.kernel.org/pub/linux/daemons/autofs/v4/autofs-4.1.4.tar.bz2

$(ARCHIVE)/crosstool-0.43.tar.gz:
	$(WGET) http://kegel.com/crosstool/crosstool-0.43.tar.gz

$(ARCHIVE)/DirectFB-1.4.3.tar.gz:
	$(WGET) http://directfb.org/downloads/Core/DirectFB-1.4/DirectFB-1.4.3.tar.gz

$(ARCHIVE)/libmad-0.15.1b.tar.gz:
	$(WGET) http://downloads.sourceforge.net/project/mad/libmad/0.15.1b/libmad-0.15.1b.tar.gz?use_mirror=switch

$(ARCHIVE)/libiconv-1.13.1.tar.gz:
	$(WGET) http://ftp.gnu.org/gnu/libiconv/libiconv-1.13.1.tar.gz

$(ARCHIVE)/libid3tag-0.15.1b.tar.gz:
	$(WGET) http://downloads.sourceforge.net/project/mad/libid3tag/0.15.1b/libid3tag-0.15.1b.tar.gz?use_mirror=switch

$(ARCHIVE)/libjpeg-turbo-1.0.1.tar.gz:
	$(WGET) http://sourceforge.net/projects/libjpeg-turbo/files/1.0.1/libjpeg-turbo-1.0.1.tar.gz

$(ARCHIVE)/libungif-4.1.4.tar.bz2:
	$(WGET) http://downloads.sourceforge.net/project/giflib/libungif%204.x/libungif-4.1.4/libungif-4.1.4.tar.bz2?use_mirror=switch

$(ARCHIVE)/libupnp-1.6.10.tar.bz2:
	$(WGET) http://downloads.sourceforge.net/project/pupnp/pupnp/libUPnP\ 1.6.10/libupnp-1.6.10.tar.bz2

$(ARCHIVE)/curl-7.20.0.tar.bz2:
	$(WGET) http://curl.haxx.se/download/curl-7.20.0.tar.bz2

$(ARCHIVE)/libpng-1.2.44.tar.bz2:
	$(WGET) http://downloads.sourceforge.net/project/libpng/libpng12/1.2.44/libpng-1.2.44.tar.bz2

$(ARCHIVE)/dropbear-0.52.tar.bz2:
	$(WGET) http://matt.ucc.asn.au/dropbear/releases/dropbear-0.52.tar.bz2

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

$(ARCHIVE)/glib-2.8.6.tar.bz2:
	$(WGET) http://ftp.se.debian.org/pub/gnome/sources/glib/2.8/glib-2.8.6.tar.bz2

$(ARCHIVE)/jpegsrc.v6b.tar.gz:
	$(WGET) ftp://slackware.su29.ru/pub/linux/slackware/slackware-10.0/source/l/libjpeg/jpegsrc.v6b.tar.gz

$(ARCHIVE)/boost_1_42_0.tar.bz2:
	$(WGET) http://downloads.sourceforge.net/project/boost/boost/1.42.0/boost_1_42_0.tar.bz2?use_mirror=switch

$(ARCHIVE)/ffmpeg-0.6.tar.bz2:
	$(WGET) http://www.ffmpeg.org/releases/ffmpeg-0.6.tar.bz2

$(ARCHIVE)/libogg-1.1.4.tar.gz:
	$(WGET) http://downloads.xiph.org/releases/ogg/libogg-1.1.4.tar.gz

$(ARCHIVE)/libvorbis-1.2.3.tar.bz2:
	$(WGET) http://downloads.xiph.org/releases/vorbis/libvorbis-1.2.3.tar.bz2

$(ARCHIVE)/ncurses-5.6.tar.gz:
	$(WGET) http://ftp.gnu.org/pub/gnu/ncurses/ncurses-5.6.tar.gz

$(ARCHIVE)/libvorbisidec_1.0.2+svn16259.orig.tar.gz:
	$(WGET) http://ftp.de.debian.org/debian/pool/main/libv/libvorbisidec/libvorbisidec_1.0.2+svn16259.orig.tar.gz

$(ARCHIVE)/libpcap-1.0.0.tar.gz:
	$(WGET) ftp://ftp.wh8.tu-dresden.de/pub/linux/distributions/gentoo/distfiles/libpcap-1.0.0.tar.gz

$(ARCHIVE)/links-2.3pre1.tar.bz2:
	$(WGET) http://links.twibright.com/download/links-2.3pre1.tar.bz2

$(ARCHIVE)/mc-4.6.2.tar.gz:
	$(WGET) http://midnight-commander.org/downloads/mc-4.6.2.tar.gz

$(ARCHIVE)/nbench-byte-2.2.3.tar.gz:
	$(WGET) http://www.tux.org/~mayer/linux/nbench-byte-2.2.3.tar.gz

$(ARCHIVE)/ntfs-3g-2011.1.15.tgz:
	$(WGET) http://tuxera.com/opensource/ntfs-3g-2011.1.15.tgz

$(ARCHIVE)/openssl-0.9.8q.tar.gz:
	$(WGET) http://www.openssl.org/source/openssl-0.9.8q.tar.gz

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

$(ARCHIVE)/opkg-0.1.8.tar.gz:
	$(WGET) http://opkg.googlecode.com/files/opkg-0.1.8.tar.gz

$(ARCHIVE)/qt-everywhere-opensource-src-4.6.3.tar.gz:
	$(WGET) http://get.qt.nokia.com/qt/source/qt-everywhere-opensource-src-4.6.3.tar.gz

$(ARCHIVE)/samba-2.0.10.tar.gz:
	$(WGET) http://samba.org/samba/ftp/old-versions/samba-2.0.10.tar.gz

$(ARCHIVE)/samba-2.2.12.tar.gz:
	$(WGET) http://samba.org/samba/ftp/old-versions/samba-2.2.12.tar.gz

$(ARCHIVE)/samba-3.3.9.tar.gz:
	$(WGET) http://download.samba.org/samba/ftp/old-versions/samba-3.3.9.tar.gz

$(ARCHIVE)/sg3_utils-1.30.tar.bz2:
	$(WGET) http://sg.danny.cz/sg/p/sg3_utils-1.30.tar.bz2

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
