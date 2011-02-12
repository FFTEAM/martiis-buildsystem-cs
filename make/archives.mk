# makefile for tarball download

$(ARCHIVE)/autofs-4.1.4.tar.bz2:
	$(WGET) http://www.kernel.org/pub/linux/daemons/autofs/v4/autofs-4.1.4.tar.bz2

$(ARCHIVE)/crosstool-0.43.tar.gz:
	$(WGET) http://kegel.com/crosstool/crosstool-0.43.tar.gz

$(ARCHIVE)/DirectFB-$(DIRECTFB-VER).tar.gz:
	$(WGET) http://directfb.org/downloads/Core/DirectFB-1.4/DirectFB-$(DIRECTFB-VER).tar.gz

$(ARCHIVE)/libmad-$(MAD-VER).tar.gz:
	$(WGET) http://downloads.sourceforge.net/project/mad/libmad/$(MAD-VER)/libmad-$(MAD-VER).tar.gz

$(ARCHIVE)/libiconv-$(ICONV-VER).tar.gz:
	$(WGET) http://ftp.gnu.org/gnu/libiconv/libiconv-$(ICONV-VER).tar.gz

$(ARCHIVE)/libid3tag-$(ID3TAG-VER).tar.gz:
	$(WGET) http://downloads.sourceforge.net/project/mad/libid3tag/$(ID3TAG-VER)/libid3tag-$(ID3TAG-VER).tar.gz

$(ARCHIVE)/libjpeg-turbo-$(JPEG_TURBO-VER).tar.gz:
	$(WGET) http://sourceforge.net/projects/libjpeg-turbo/files/$(JPEG_TURBO-VER)/libjpeg-turbo-$(JPEG_TURBO-VER).tar.gz

$(ARCHIVE)/libungif-$(UNGIF-VER).tar.bz2:
	$(WGET) http://downloads.sourceforge.net/project/giflib/libungif%204.x/libungif-$(UNGIF-VER)/libungif-$(UNGIF-VER).tar.bz2

$(ARCHIVE)/libupnp-1.6.10.tar.bz2:
	$(WGET) http://downloads.sourceforge.net/project/pupnp/pupnp/libUPnP\ 1.6.10/libupnp-1.6.10.tar.bz2

$(ARCHIVE)/curl-$(CURL-VER).tar.bz2:
	$(WGET) http://curl.haxx.se/download/curl-$(CURL-VER).tar.bz2

$(ARCHIVE)/libpng-$(PNG-VER).tar.bz2:
	$(WGET) http://downloads.sourceforge.net/project/libpng/libpng12/$(PNG-VER)/libpng-$(PNG-VER).tar.bz2

$(ARCHIVE)/dropbear-0.52.tar.bz2:
	$(WGET) http://matt.ucc.asn.au/dropbear/releases/dropbear-0.52.tar.bz2

$(ARCHIVE)/e2fsprogs-1.41.12.tar.gz:
	$(WGET) http://prdownloads.sourceforge.net/e2fsprogs/e2fsprogs-1.41.12.tar.gz

$(ARCHIVE)/fbshot-0.3.tar.gz:
	$(WGET) http://www.sfires.net/stuff/fbshot/fbshot-0.3.tar.gz

$(ARCHIVE)/gdb-7.1.tar.bz2:
	$(WGET) http://ftp.gnu.org/gnu/gdb/gdb-7.1.tar.bz2

$(ARCHIVE)/flex-$(FLEX-VER).tar.gz:
	$(WGET) http://prdownloads.sourceforge.net/flex/flex-$(FLEX-VER).tar.gz

$(ARCHIVE)/freetype-2.1.4.tar.bz2:
	$(WGET) http://heanet.dl.sourceforge.net/sourceforge/freetype/freetype-2.1.4.tar.bz2

$(ARCHIVE)/freetype-2.3.9.tar.bz2:
	$(WGET) http://downloads.sourceforge.net/project/freetype/freetype2/2.3.9/freetype-2.3.9.tar.bz2

$(ARCHIVE)/freetype-2.3.11.tar.bz2:
	$(WGET) http://downloads.sourceforge.net/project/freetype/freetype2/2.3.11/freetype-2.3.11.tar.bz2

$(ARCHIVE)/freetype-$(FREETYPE-VER).tar.bz2:
	$(WGET) http://downloads.sourceforge.net/project/freetype/freetype2/$(FREETYPE-VER)/freetype-$(FREETYPE-VER).tar.bz2

$(ARCHIVE)/glib-2.8.6.tar.bz2:
	$(WGET) http://ftp.se.debian.org/pub/gnome/sources/glib/2.8/glib-2.8.6.tar.bz2

$(ARCHIVE)/jpegsrc.v6b.tar.gz:
	$(WGET) ftp://slackware.su29.ru/pub/linux/slackware/slackware-10.0/source/l/libjpeg/jpegsrc.v6b.tar.gz

$(ARCHIVE)/boost_$(BOOST-VER).tar.bz2:
	$(WGET) http://downloads.sourceforge.net/project/boost/boost/$(BOOST-MAJOR).$(BOOST-MINOR).$(BOOST-MICRO)/boost_$(BOOST-VER).tar.bz2

$(ARCHIVE)/ffmpeg-$(FFMPEG-VER).tar.bz2:
	$(WGET) http://www.ffmpeg.org/releases/ffmpeg-$(FFMPEG-VER).tar.bz2

$(ARCHIVE)/libogg-$(OGG-VER).tar.gz:
	$(WGET) http://downloads.xiph.org/releases/ogg/libogg-$(OGG-VER).tar.gz

$(ARCHIVE)/libvorbis-$(VORBIS-VER).tar.bz2:
	$(WGET) http://downloads.xiph.org/releases/vorbis/libvorbis-$(VORBIS-VER).tar.bz2

$(ARCHIVE)/ncurses-$(NCURSES-VER).tar.gz:
	$(WGET) http://ftp.gnu.org/pub/gnu/ncurses/ncurses-$(NCURSES-VER).tar.gz

$(ARCHIVE)/libvorbisidec_$(VORBISIDEC-VER)$(VORBISIDEC-VER_APPEND).tar.gz:
	$(WGET) http://ftp.de.debian.org/debian/pool/main/libv/libvorbisidec/libvorbisidec_$(VORBISIDEC-VER)$(VORBISIDEC-VER_APPEND).tar.gz

$(ARCHIVE)/libpcap-$(PCAP-VER).tar.gz:
	$(WGET) ftp://ftp.wh8.tu-dresden.de/pub/linux/distributions/gentoo/distfiles/libpcap-$(PCAP-VER).tar.gz

$(ARCHIVE)/links-2.3pre1.tar.bz2:
	$(WGET) http://links.twibright.com/download/links-2.3pre1.tar.bz2

$(ARCHIVE)/mc-4.6.2.tar.gz:
	$(WGET) http://midnight-commander.org/downloads/mc-4.6.2.tar.gz

$(ARCHIVE)/nbench-byte-2.2.3.tar.gz:
	$(WGET) http://www.tux.org/~mayer/linux/nbench-byte-2.2.3.tar.gz

$(ARCHIVE)/ntfs-3g-2011.1.15.tgz:
	$(WGET) http://tuxera.com/opensource/ntfs-3g-2011.1.15.tgz

$(ARCHIVE)/openssl-$(OPENSSL-VER)$(OPENSSL-SUBVER).tar.gz:
	$(WGET) http://www.openssl.org/source/openssl-$(OPENSSL-VER)$(OPENSSL-SUBVER).tar.gz

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

$(ARCHIVE)/u-boot-2009.03.tar.bz2:
	$(WGET) http://ftp.denx.de/pub/u-boot/u-boot-2009.03.tar.bz2

$(ARCHIVE)/unfs3-0.9.22.tar.gz:
	$(WGET) http://downloads.sourceforge.net/unfs3/unfs3-0.9.22.tar.gz

$(ARCHIVE)/util-linux-ng-$(UTIL_LINUX_NG-VER).tar.bz2:
	$(WGET) ftp://ftp.kernel.org/pub/linux/utils/util-linux-ng/v$(UTIL_LINUX_NG-VER)/util-linux-ng-$(UTIL_LINUX_NG-VER).tar.bz2

$(ARCHIVE)/vsftpd-2.2.2.tar.gz:
	$(WGET) ftp://vsftpd.beasts.org/users/cevans/vsftpd-2.2.2.tar.gz

$(ARCHIVE)/xfsprogs-3.1.3.tar.gz:
	$(WGET) ftp://oss.sgi.com/projects/xfs/cmd_tars/xfsprogs-3.1.3.tar.gz

$(ARCHIVE)/zlib-$(ZLIB-VER).tar.bz2:
	$(WGET) http://downloads.sourceforge.net/project/libpng/zlib/$(ZLIB-VER)/zlib-$(ZLIB-VER).tar.bz2
