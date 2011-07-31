# Makefile for tarball downloads
#
# take a look in versions.mk for version numbers

$(ARCHIVE)/autofs-$(AUTOFS-VER).tar.bz2:
	$(WGET) http://www.kernel.org/pub/linux/daemons/autofs/v4/autofs-$(AUTOFS-VER).tar.bz2

$(ARCHIVE)/crosstool-0.43.tar.gz:
	$(WGET) http://kegel.com/crosstool/crosstool-0.43.tar.gz

$(ARCHIVE)/crosstool-ng-1.10.0.tar.bz2:
	$(WGET) http://ymorin.is-a-geek.org/download/crosstool-ng/crosstool-ng-1.10.0.tar.bz2

$(ARCHIVE)/DirectFB-$(DIRECTFB-VER).tar.gz:
	$(WGET) http://directfb.org/downloads/Core/DirectFB-1.4/DirectFB-$(DIRECTFB-VER).tar.gz

$(ARCHIVE)/djmount-0.71.tar.gz:
	$(WGET) http://sourceforge.net/projects/djmount/files/djmount/0.71/djmount-0.71.tar.gz

$(ARCHIVE)/libmad-$(MAD-VER).tar.gz:
	$(WGET) http://downloads.sourceforge.net/project/mad/libmad/$(MAD-VER)/libmad-$(MAD-VER).tar.gz

$(ARCHIVE)/libiconv-$(ICONV-VER).tar.gz:
	$(WGET) http://ftp.gnu.org/gnu/libiconv/libiconv-$(ICONV-VER).tar.gz

$(ARCHIVE)/libid3tag-$(ID3TAG-VER)$(ID3TAG-SUBVER).tar.gz:
	$(WGET) http://downloads.sourceforge.net/project/mad/libid3tag/$(ID3TAG-VER)$(ID3TAG-SUBVER)/libid3tag-$(ID3TAG-VER)$(ID3TAG-SUBVER).tar.gz

$(ARCHIVE)/libjpeg-turbo-$(JPEG_TURBO-VER).tar.gz:
	$(WGET) http://sourceforge.net/projects/libjpeg-turbo/files/$(JPEG_TURBO-VER)/libjpeg-turbo-$(JPEG_TURBO-VER).tar.gz

$(ARCHIVE)/libungif-$(UNGIF-VER).tar.bz2:
	$(WGET) http://downloads.sourceforge.net/project/giflib/libungif%204.x/libungif-$(UNGIF-VER)/libungif-$(UNGIF-VER).tar.bz2

$(ARCHIVE)/libupnp-$(LIBUPNP-VER).tar.bz2:
	$(WGET) http://downloads.sourceforge.net/project/pupnp/pupnp/libUPnP\ $(LIBUPNP-VER)/libupnp-$(LIBUPNP-VER).tar.bz2

$(ARCHIVE)/curl-$(CURL-VER).tar.bz2:
	$(WGET) http://curl.haxx.se/download/curl-$(CURL-VER).tar.bz2

$(ARCHIVE)/libpng-$(PNG-VER).tar.bz2:
	$(WGET) http://downloads.sourceforge.net/project/libpng/libpng12/$(PNG-VER)/libpng-$(PNG-VER).tar.bz2

$(ARCHIVE)/dropbear-$(DROPBEAR-VER).tar.bz2:
	$(WGET) http://matt.ucc.asn.au/dropbear/releases/dropbear-$(DROPBEAR-VER).tar.bz2

$(ARCHIVE)/e2fsprogs-$(E2FSPROGS-VER).tar.gz:
	$(WGET) http://prdownloads.sourceforge.net/e2fsprogs/e2fsprogs-$(E2FSPROGS-VER).tar.gz

$(ARCHIVE)/fbshot-$(FBSHOT-VER).tar.gz:
	$(WGET) http://www.sfires.net/stuff/fbshot/fbshot-$(FBSHOT-VER).tar.gz

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

$(ARCHIVE)/glib-$(GLIB-VER).tar.bz2:
	$(WGET) ftp://ftp.gtk.org/pub/glib/$(GLIB-MAJOR).$(GLIB-MINOR)/glib-$(GLIB-VER).tar.bz2

$(ARCHIVE)/iperf-$(IPERF-VER).tar.gz:
	$(WGET) http://downloads.sourceforge.net/project/iperf/iperf-$(IPERF-VER).tar.gz

$(ARCHIVE)/jpegsrc.v6b.tar.gz:
	$(WGET) ftp://slackware.su29.ru/pub/linux/slackware/slackware-10.0/source/l/libjpeg/jpegsrc.v6b.tar.gz

$(ARCHIVE)/boost_$(BOOST-VER).tar.bz2:
	$(WGET) http://downloads.sourceforge.net/project/boost/boost/$(BOOST-MAJOR).$(BOOST-MINOR).$(BOOST-MICRO)/boost_$(BOOST-VER).tar.bz2

$(ARCHIVE)/ffmpeg-$(FFMPEG-VER).tar.bz2:
	$(WGET) http://www.ffmpeg.org/releases/ffmpeg-$(FFMPEG-VER).tar.bz2

$(ARCHIVE)/flac-1.2.1.tar.gz:
	$(WGET) http://prdownloads.sourceforge.net/sourceforge/flac/flac-1.2.1.tar.gz

$(ARCHIVE)/fuse-$(FUSE-VER).tar.gz:
	$(WGET) http://downloads.sourceforge.net/project/fuse/fuse-2.X/2.8.5/fuse-2.8.5.tar.gz

$(ARCHIVE)/libogg-$(OGG-VER).tar.gz:
	$(WGET) http://downloads.xiph.org/releases/ogg/libogg-$(OGG-VER).tar.gz

$(ARCHIVE)/libvorbis-$(VORBIS-VER).tar.bz2:
	$(WGET) http://downloads.xiph.org/releases/vorbis/libvorbis-$(VORBIS-VER).tar.bz2

$(ARCHIVE)/mtd-utils-1.4.4.tar.bz2:
	$(WGET) ftp://ftp.infradead.org/pub/mtd-utils/mtd-utils-1.4.4.tar.bz2

$(ARCHIVE)/ncurses-$(NCURSES-VER).tar.gz:
	$(WGET) http://ftp.gnu.org/pub/gnu/ncurses/ncurses-$(NCURSES-VER).tar.gz

$(ARCHIVE)/libvorbisidec_$(VORBISIDEC-VER)$(VORBISIDEC-VER_APPEND).tar.gz:
	$(WGET) http://ftp.de.debian.org/debian/pool/main/libv/libvorbisidec/libvorbisidec_$(VORBISIDEC-VER)$(VORBISIDEC-VER_APPEND).tar.gz

$(ARCHIVE)/libpcap-$(PCAP-VER).tar.gz:
	$(WGET) ftp://ftp.wh8.tu-dresden.de/pub/linux/distributions/gentoo/distfiles/libpcap-$(PCAP-VER).tar.gz

$(ARCHIVE)/libcap-$(LIBCAP2-VER).tar.gz:
	$(WGET) http://www.kernel.org/pub/linux/libs/security/linux-privs/libcap2/libcap-$(LIBCAP2-VER).tar.gz

$(ARCHIVE)/links-$(LINKS-VER).tar.bz2:
	$(WGET) http://links.twibright.com/download/links-$(LINKS-VER).tar.bz2

$(ARCHIVE)/linux-libc-headers-2.6.12.0.tar.bz2:
	$(WGET) http://www.kernel.org/pub/tools/crosstool/files/src/linux-libc-headers-2.6.12.0.tar.bz2

$(ARCHIVE)/linux-2.6.26.8.tar.bz2:
	$(WGET) http://www.kernel.org/pub/linux/kernel/v2.6/linux-2.6.26.8.tar.bz2

$(ARCHIVE)/mc-$(MC-VER).tar.gz:
	$(WGET) http://midnight-commander.org/downloads/mc-$(MC-VER).tar.gz

$(ARCHIVE)/nbench-byte-$(NBENCH_BYTE-VER).tar.gz:
	$(WGET) http://www.tux.org/~mayer/linux/nbench-byte-$(NBENCH_BYTE-VER).tar.gz

$(ARCHIVE)/ntfs-3g-$(NTFS_3G-VER).tgz:
	$(WGET) http://tuxera.com/opensource/ntfs-3g-$(NTFS_3G-VER).tgz

$(ARCHIVE)/openssl-$(OPENSSL-VER)$(OPENSSL-SUBVER).tar.gz:
	$(WGET) http://www.openssl.org/source/openssl-$(OPENSSL-VER)$(OPENSSL-SUBVER).tar.gz

$(ARCHIVE)/rsync-$(RSYNC-VER).tar.gz:
	$(WGET) http://samba.anu.edu.au/ftp/rsync/src/rsync-$(RSYNC-VER).tar.gz

$(ARCHIVE)/pkg-config-0.25.tar.gz:
	$(WGET) http://pkgconfig.freedesktop.org/releases/pkg-config-0.25.tar.gz

$(ARCHIVE)/portmap-$(PORTMAP-VER).tgz:
	$(WGET) http://neil.brown.name/portmap/portmap-$(PORTMAP-VER).tgz

$(ARCHIVE)/procps-$(PROCPS-VER).tar.gz:
	$(WGET) http://procps.sourceforge.net/procps-$(PROCPS-VER).tar.gz

$(ARCHIVE)/busybox-$(BUSYBOX-VER).tar.bz2:
	$(WGET) http://busybox.net/downloads/busybox-$(BUSYBOX-VER).tar.bz2

$(ARCHIVE)/busybox-snapshot.tar.bz2:
	$(WGET) http://busybox.net/downloads/snapshots/busybox-snapshot.tar.bz2

$(ARCHIVE)/opkg-$(OPKG-VER).tar.gz:
	$(WGET) http://opkg.googlecode.com/files/opkg-$(OPKG-VER).tar.gz

$(ARCHIVE)/qt-everywhere-opensource-src-$(QT-VER).tar.gz:
	$(WGET) http://get.qt.nokia.com/qt/source/qt-everywhere-opensource-src-$(QT-VER).tar.gz

$(ARCHIVE)/samba-2.0.10.tar.gz:
	$(WGET) http://samba.org/samba/ftp/old-versions/samba-2.0.10.tar.gz

$(ARCHIVE)/samba-$(SAMBA2-VER).tar.gz:
	$(WGET) http://samba.org/samba/ftp/old-versions/samba-$(SAMBA2-VER).tar.gz

$(ARCHIVE)/samba-3.3.9.tar.gz:
	$(WGET) http://download.samba.org/samba/ftp/old-versions/samba-3.3.9.tar.gz

$(ARCHIVE)/sg3_utils-$(SG3_UTILS-VER).tar.bz2:
	$(WGET) http://sg.danny.cz/sg/p/sg3_utils-$(SG3_UTILS-VER).tar.bz2

$(ARCHIVE)/strace-4.5.20.tar.bz2:
	$(WGET) http://downloads.sourceforge.net/project/strace/strace/4.5.20/strace-4.5.20.tar.bz2

$(ARCHIVE)/u-boot-2009.03.tar.bz2:
	$(WGET) http://ftp.denx.de/pub/u-boot/u-boot-2009.03.tar.bz2

$(ARCHIVE)/unfs3-$(UNFS3-VER).tar.gz:
	$(WGET) http://downloads.sourceforge.net/unfs3/unfs3-$(UNFS3-VER).tar.gz

$(ARCHIVE)/util-linux-ng-$(UTIL_LINUX_NG-VER).tar.bz2:
	$(WGET) ftp://ftp.kernel.org/pub/linux/utils/util-linux-ng/v$(UTIL_LINUX_NG-VER)/util-linux-ng-$(UTIL_LINUX_NG-VER).tar.bz2

$(ARCHIVE)/valgrind-3.3.1.tar.bz2:
	$(WGET) http://valgrind.org/downloads/valgrind-3.3.1.tar.bz2

$(ARCHIVE)/valgrind-3.6.1.tar.bz2:
	$(WGET) http://valgrind.org/downloads/valgrind-3.6.1.tar.bz2

$(ARCHIVE)/vsftpd-$(VSFTPD-VER).tar.gz:
	$(WGET) ftp://vsftpd.beasts.org/users/cevans/vsftpd-$(VSFTPD-VER).tar.gz

$(ARCHIVE)/xfsprogs-$(XFSPROGS-VER).tar.gz:
	$(WGET) ftp://oss.sgi.com/projects/xfs/cmd_tars/xfsprogs-$(XFSPROGS-VER).tar.gz

$(ARCHIVE)/zlib-$(ZLIB-VER).tar.bz2:
	$(WGET) http://downloads.sourceforge.net/project/libpng/zlib/$(ZLIB-VER)/zlib-$(ZLIB-VER).tar.bz2

$(ARCHIVE)/systemd-$(SYSTEMD-VER).tar.bz2:
	$(WGET) http://www.freedesktop.org/software/systemd/systemd-$(SYSTEMD-VER).tar.bz2

$(ARCHIVE)/dbus-$(DBUS-VER).tar.gz:
	$(WGET) http://dbus.freedesktop.org/releases/dbus/dbus-$(DBUS-VER).tar.gz

$(ARCHIVE)/expat-$(EXPAT-VER).tar.gz:
	$(WGET) http://sourceforge.net/projects/expat/files/expat/$(EXPAT-VER)/expat-$(EXPAT-VER).tar.gz

$(ARCHIVE)/attr-$(ATTR-VER).src.tar.gz:
	$(WGET) http://download.savannah.gnu.org/releases/attr/attr-$(ATTR-VER).src.tar.gz
