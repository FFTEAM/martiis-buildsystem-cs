# Makefile for tarball downloads
#
# take a look in versions.mk for version numbers

$(ARCHIVE)/autofs-$(AUTOFS-VER).tar.gz:
	$(WGET) http://www.kernel.org/pub/linux/daemons/autofs/v4/autofs-$(AUTOFS-VER).tar.gz

$(ARCHIVE)/binutils-2.19.50.0.1.tar.bz2:
	$(WGET) http://www.dbox2world.net/download/binutils-2.19.50.0.1.tar.bz2

$(ARCHIVE)/cddfs-0.2.tar.gz:
	$(WGET) http://castet.matthieu.free.fr/cddfs/cddfs-0.2.tar.gz

$(ARCHIVE)/cdparanoia-III-10.2.src.tgz:
	$(WGET) http://downloads.xiph.org/releases/cdparanoia/cdparanoia-III-10.2.src.tgz

$(ARCHIVE)/compcache-0.6.2.tar.gz:
	$(WGET) http://compcache.googlecode.com/files/compcache-0.6.2.tar.gz

$(ARCHIVE)/crosstool-0.43.tar.gz:
	$(WGET) http://kegel.com/crosstool/crosstool-0.43.tar.gz

$(ARCHIVE)/crosstool-ng-1.10.0.tar.bz2:
	$(WGET) http://ymorin.is-a-geek.org/download/crosstool-ng/crosstool-ng-1.10.0.tar.bz2

$(ARCHIVE)/crosstool-ng-1.15.2.tar.bz2:
	$(WGET) http://crosstool-ng.org/download/crosstool-ng/crosstool-ng-1.15.2.tar.bz2

$(ARCHIVE)/DirectFB_$(DIRECTFB_VER).tar.gz:
	$(WGET) http://directfb.org/downloads/Core/DirectFB-1.4/DirectFB-$(DIRECTFB_VER).tar.gz

$(ARCHIVE)/dvdreadfs.tar:
	$(WGET) http://www.daemoninc.com/dvdreadfs/dvdreadfs.tar

$(ARCHIVE)/djmount-0.71.tar.gz:
	$(WGET) http://sourceforge.net/projects/djmount/files/djmount/0.71/djmount-0.71.tar.gz

$(ARCHIVE)/dpfhack_pearl.zip:
	$(WGET) -O $@ https://nodeload.github.com/makefu/dpfhack_pearl/zipball/master

$(ARCHIVE)/evtest_1.29.orig.tar.bz2:
	$(WGET) http://mirror.informatik.uni-mannheim.de/ubuntu/pool/universe/e/evtest/evtest_1.29.orig.tar.bz2

$(ARCHIVE)/libass-$(LIBASS_VER).tar.gz:
	$(WGET) http://libass.googlecode.com/files/libass-$(LIBASS_VER).tar.gz

$(ARCHIVE)/libdvdcss-$(DVDCSS_VER).tar.bz2:
	$(WGET) http://download.videolan.org/pub/libdvdcss/$(DVDCSS_VER)/$(lastword $(subst /, ,$@))

$(ARCHIVE)/libdvdread-4.1.3.tar.bz2:
	$(WGET) http://www1.mplayerhq.hu/MPlayer/releases/dvdnav-old/libdvdread-4.1.3.tar.bz2

$(ARCHIVE)/libmad-$(MAD_VER).tar.gz:
	$(WGET) http://downloads.sourceforge.net/project/mad/libmad/$(MAD_VER)/libmad-$(MAD_VER).tar.gz

$(ARCHIVE)/libiconv-$(ICONV-VER).tar.gz:
	$(WGET) http://ftp.gnu.org/gnu/libiconv/libiconv-$(ICONV-VER).tar.gz

$(ARCHIVE)/libid3tag-$(ID3TAG_VER)$(ID3TAG_SUBVER).tar.gz:
	$(WGET) http://downloads.sourceforge.net/project/mad/libid3tag/$(ID3TAG_VER)$(ID3TAG_SUBVER)/libid3tag-$(ID3TAG_VER)$(ID3TAG_SUBVER).tar.gz

$(ARCHIVE)/libjpeg-turbo-$(JPEG_TURBO_VER).tar.gz:
	$(WGET) http://sourceforge.net/projects/libjpeg-turbo/files/$(JPEG_TURBO_VER)/libjpeg-turbo-$(JPEG_TURBO_VER).tar.gz

$(ARCHIVE)/libungif-$(UNGIF_VER).tar.bz2:
	$(WGET) http://downloads.sourceforge.net/project/giflib/libungif-4.x/libungif-$(UNGIF_VER)/libungif-$(UNGIF_VER).tar.bz2

$(ARCHIVE)/libupnp-$(LIBUPNP_VER).tar.bz2:
	$(WGET) http://downloads.sourceforge.net/project/pupnp/pupnp/libUPnP\ $(LIBUPNP_VER)/libupnp-$(LIBUPNP_VER).tar.bz2

$(ARCHIVE)/libusb-1.0.8.tar.bz2:
	$(WGET) http://downloads.sourceforge.net/project/libusb/libusb-1.0/libusb-1.0.8/libusb-1.0.8.tar.bz2

$(ARCHIVE)/libusb-compat-0.1.3.tar.bz2:
	$(WGET) http://downloads.sourceforge.net/project/libusb/libusb-compat-0.1/libusb-compat-0.1.3/libusb-compat-0.1.3.tar.bz2

$(ARCHIVE)/curl-$(CURL_VER).tar.bz2:
	$(WGET) http://curl.haxx.se/download/$(lastword $(subst /, ,$@))

$(ARCHIVE)/libpng-$(PNG-VER).tar.bz2:
	$(WGET) http://sourceforge.net/projects/libpng/files/libpng12/older-releases/$(PNG-VER)/libpng-$(PNG-VER).tar.bz2

$(ARCHIVE)/lirc-$(LIRC_VER).tar.bz2:
	$(WGET) http://sourceforge.net/projects/lirc/files/LIRC/0.9.0/lirc-0.9.0.tar.bz2

$(ARCHIVE)/dropbear-$(DROPBEAR-VER).tar.bz2:
	$(WGET) http://matt.ucc.asn.au/dropbear/releases/dropbear-$(DROPBEAR-VER).tar.bz2

$(ARCHIVE)/e2fsprogs-$(E2FSPROGS-VER).tar.gz:
	$(WGET) http://prdownloads.sourceforge.net/e2fsprogs/e2fsprogs-$(E2FSPROGS-VER).tar.gz

$(ARCHIVE)/yaffs2utils-$(YAFFS2UTILS-VER).tar.gz:
	$(WGET) -O $@ http://yaffs2utils.googlecode.com/files/$(YAFFS2UTILS-VER).tar.gz

$(ARCHIVE)/fbshot-$(FBSHOT-VER).tar.gz:
	$(WGET) http://www.sfires.net/stuff/fbshot/fbshot-$(FBSHOT-VER).tar.gz

$(ARCHIVE)/gd-2.0.35.tar.gz:
	$(WGET) http://fossies.org/unix/www/gd-2.0.35.tar.gz

$(ARCHIVE)/gdb-$(GDB_VER).tar.bz2:
	$(WGET) ftp://sourceware.org/pub/gdb/releases/gdb-$(GDB_VER).tar.bz2

$(ARCHIVE)/flex-$(FLEX_VER).tar.gz:
	$(WGET) http://prdownloads.sourceforge.net/flex/flex-$(FLEX_VER).tar.gz

$(ARCHIVE)/freetype-2.1.4.tar.bz2:
	$(WGET) http://heanet.dl.sourceforge.net/sourceforge/freetype/freetype-2.1.4.tar.bz2

$(ARCHIVE)/freetype-2.3.9.tar.bz2:
	$(WGET) http://downloads.sourceforge.net/project/freetype/freetype2/2.3.9/freetype-2.3.9.tar.bz2

$(ARCHIVE)/freetype-2.3.11.tar.bz2:
	$(WGET) http://downloads.sourceforge.net/project/freetype/freetype2/2.3.11/freetype-2.3.11.tar.bz2

$(ARCHIVE)/freetype-$(FREETYPE_VER).tar.bz2:
	$(WGET) http://downloads.sourceforge.net/project/freetype/freetype2/$(FREETYPE_VER)/freetype-$(FREETYPE_VER).tar.bz2

$(ARCHIVE)/glib-$(GLIB-VER).tar.bz2:
	$(WGET) http://ftp.gnome.org/pub/gnome/sources/glib/$(GLIB-MAJOR).$(GLIB-MINOR)/$(lastword $(subst /, ,$@))

$(ARCHIVE)/iperf-$(IPERF-VER).tar.gz:
	$(WGET) http://downloads.sourceforge.net/project/iperf/iperf-$(IPERF-VER).tar.gz

$(ARCHIVE)/jpegsrc.v6b.tar.gz:
	$(WGET) http://www.ijg.org/files/jpegsrc.v6b.tar.gz

$(ARCHIVE)/boost_$(BOOST_VER).tar.bz2:
	$(WGET) http://downloads.sourceforge.net/project/boost/boost/$(BOOST_MAJOR).$(BOOST_MINOR).$(BOOST_MICRO)/boost_$(BOOST_VER).tar.bz2

$(ARCHIVE)/ffmpeg-$(FFMPEG_VER).tar.bz2:
	$(WGET) http://www.ffmpeg.org/releases/ffmpeg-$(FFMPEG_VER).tar.bz2

$(ARCHIVE)/flac-1.2.1.tar.gz:
	$(WGET) http://prdownloads.sourceforge.net/sourceforge/flac/flac-1.2.1.tar.gz

$(ARCHIVE)/fuse-$(FUSE_VER).tar.gz:
	$(WGET) http://downloads.sourceforge.net/project/fuse/fuse-2.X/$(FUSE_VER)/fuse-$(FUSE_VER).tar.gz

$(ARCHIVE)/fuse-2.7.5.tar.gz:
	$(WGET) http://downloads.sourceforge.net/project/fuse/fuse-2.X/2.7.5/fuse-2.7.5.tar.gz

$(ARCHIVE)/gst123-$(GST123_VER).tar.bz2:
	$(WGET) http://space.twc.de/~stefan/gst123/$(lastword $(subst /, ,$@))

# this relies on the version starting with 0.
$(ARCHIVE)/gstreamer%.tar.bz2 \
$(ARCHIVE)/gst-%.tar.bz2:
	$(WGET) http://gstreamer.freedesktop.org/src/$(firstword $(subst -0., ,$(lastword $(subst /, ,$@))))/$(lastword $(subst /, ,$@))

$(ARCHIVE)/libogg-$(OGG_VER).tar.gz:
	$(WGET) http://downloads.xiph.org/releases/ogg/libogg-$(OGG_VER).tar.gz

$(ARCHIVE)/libvorbis-$(VORBIS_VER).tar.bz2:
	$(WGET) http://downloads.xiph.org/releases/vorbis/libvorbis-$(VORBIS_VER).tar.bz2

$(ARCHIVE)/libxml2-$(LIBXML2_VER).tar.gz:
	$(WGET) ftp://xmlsoft.org/libxml2/$(lastword $(subst /, ,$@))

$(ARCHIVE)/mtd-utils-$(MTD_UTILS_VER).tar.bz2:
	$(WGET) ftp://ftp.infradead.org/pub/mtd-utils/mtd-utils-$(MTD_UTILS_VER).tar.bz2

$(ARCHIVE)/ncurses-$(NCURSES_VER).tar.gz:
	$(WGET) http://ftp.gnu.org/pub/gnu/ncurses/ncurses-$(NCURSES_VER).tar.gz

$(ARCHIVE)/libvorbisidec_$(VORBISIDEC_VER)$(VORBISIDEC_VER_APPEND).tar.gz:
	$(WGET) http://ftp.de.debian.org/debian/pool/main/libv/libvorbisidec/libvorbisidec_$(VORBISIDEC_VER)$(VORBISIDEC_VER_APPEND).tar.gz

$(ARCHIVE)/libpcap-$(LIBPCAP_VER).tar.gz:
	$(WGET) http://www.tcpdump.org/release/libpcap-$(LIBPCAP_VER).tar.gz

$(ARCHIVE)/libcap-$(LIBCAP2_VER).tar.gz:
	$(WGET) ftp://ftp.de.debian.org/debian/pool/main/libc/libcap2/libcap2_$(LIBCAP2_VER).orig.tar.gz

$(ARCHIVE)/links-$(LINKS-VER).tar.bz2:
	$(WGET) http://links.twibright.com/download/links-$(LINKS-VER).tar.bz2

$(ARCHIVE)/linux-libc-headers-2.6.12.0.tar.bz2:
	$(WGET) http://ftp.lfs-matrix.net/pub/lfs/conglomeration/linux-libc-headers/linux-libc-headers-2.6.12.0.tar.bz2

$(ARCHIVE)/linux-2.6.26.8.tar.bz2:
	$(WGET) http://www.dbox2world.net/download/linux-2.6.26.8.tar.bz2

$(ARCHIVE)/mc-$(MC-VER).tar.gz:
	$(WGET) http://midnight-commander.org/downloads/mc-$(MC-VER).tar.gz

$(ARCHIVE)/nbench-byte-$(NBENCH_BYTE-VER).tar.gz:
	$(WGET) http://www.tux.org/~mayer/linux/nbench-byte-$(NBENCH_BYTE-VER).tar.gz

$(ARCHIVE)/ntfs-3g_ntfsprogs-$(NTFS_3G_VER).tgz:
	$(WGET) http://tuxera.com/opensource/ntfs-3g_ntfsprogs-$(NTFS_3G_VER).tgz

$(ARCHIVE)/openssl-$(OPENSSL_VER)$(OPENSSL_SUBVER).tar.gz:
	$(WGET) http://www.openssl.org/source/openssl-$(OPENSSL_VER)$(OPENSSL_SUBVER).tar.gz

$(ARCHIVE)/rsync-$(RSYNC-VER).tar.gz:
	$(WGET) http://samba.anu.edu.au/ftp/rsync/src/rsync-$(RSYNC-VER).tar.gz

$(ARCHIVE)/pkg-config-$(PKGCONFIG_VER).tar.gz:
	$(WGET) http://pkgconfig.freedesktop.org/releases/pkg-config-$(PKGCONFIG_VER).tar.gz

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

$(ARCHIVE)/opkg-$(OPKG_SVN_VER).tar.gz:
	set -e; cd $(BUILD_TMP); \
		rm -rf opkg-$(OPKG_SVN_VER); \
		svn export -r $(OPKG_SVN) http://opkg.googlecode.com/svn/trunk/ opkg-$(OPKG_SVN_VER); \
		tar cvpzf $@ opkg-$(OPKG_SVN_VER); \
		rm -rf opkg-$(OPKG_SVN_VER)

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

$(ARCHIVE)/tcpdump-$(TCPDUMP-VER).tar.gz:
	$(WGET) http://www.tcpdump.org/release/tcpdump-$(TCPDUMP-VER).tar.gz

$(ARCHIVE)/tzdata$(TZ_VER).tar.gz:
	$(WGET) ftp://ftp.iana.org/tz/releases/tzdata$(TZ_VER).tar.gz

$(ARCHIVE)/u-boot-2009.03.tar.bz2:
	$(WGET) http://ftp.denx.de/pub/u-boot/u-boot-2009.03.tar.bz2

$(ARCHIVE)/unfs3-$(UNFS3-VER).tar.gz:
	$(WGET) http://downloads.sourceforge.net/unfs3/unfs3-$(UNFS3-VER).tar.gz

$(ARCHIVE)/util-linux-ng-$(UTIL_LINUX_NG_VER).tar.bz2:
	$(WGET) ftp://ftp.kernel.org/pub/linux/utils/util-linux/v$(UTIL_LINUX_NG_VER)/util-linux-ng-$(UTIL_LINUX_NG_VER).tar.bz2

$(ARCHIVE)/valgrind-3.3.1.tar.bz2:
	$(WGET) http://valgrind.org/downloads/valgrind-3.3.1.tar.bz2

$(ARCHIVE)/valgrind-3.7.0.tar.bz2:
	$(WGET) http://valgrind.org/downloads/valgrind-3.7.0.tar.bz2

$(ARCHIVE)/vsftpd-$(VSFTPD-VER).tar.gz:
	$(WGET) https://security.appspot.com/downloads/vsftpd-$(VSFTPD-VER).tar.gz

$(ARCHIVE)/xfsprogs-$(XFSPROGS-VER).tar.gz:
	$(WGET) ftp://oss.sgi.com/projects/xfs/cmd_tars/xfsprogs-$(XFSPROGS-VER).tar.gz

$(ARCHIVE)/zlib-$(ZLIB_VER).tar.bz2:
	$(WGET) http://downloads.sourceforge.net/project/libpng/zlib/$(ZLIB_VER)/zlib-$(ZLIB_VER).tar.bz2

$(ARCHIVE)/systemd-$(SYSTEMD-VER).tar.bz2:
	$(WGET) http://www.freedesktop.org/software/systemd/systemd-$(SYSTEMD-VER).tar.bz2

$(ARCHIVE)/dbus-$(DBUS-VER).tar.gz:
	$(WGET) http://dbus.freedesktop.org/releases/dbus/dbus-$(DBUS-VER).tar.gz

$(ARCHIVE)/expat-$(EXPAT_VER).tar.gz:
	$(WGET) http://sourceforge.net/projects/expat/files/expat/$(EXPAT_VER)/expat-$(EXPAT_VER).tar.gz

$(ARCHIVE)/attr-$(ATTR_VER).src.tar.gz:
	$(WGET) http://download.savannah.gnu.org/releases/attr/attr-$(ATTR_VER).src.tar.gz

$(ARCHIVE)/ntp-$(NTP_VER).tar.gz:
	$(WGET) http://www.eecis.udel.edu/~ntp/ntp_spool/ntp4/ntp-4.2/ntp-$(NTP_VER).tar.gz

$(ARCHIVE)/libdvbsi++-$(LIBDVBSI_VER).tar.bz2:
	$(WGET) http://www.saftware.de/libdvbsi++/libdvbsi++-$(LIBDVBSI_VER).tar.bz2

$(ARCHIVE)/alsa-lib-$(ALSA_VER).tar.bz2:
	$(WGET) ftp://ftp.alsa-project.org/pub/lib/alsa-lib-$(ALSA_VER).tar.bz2

$(ARCHIVE)/alsa-utils-$(ALSA_VER).tar.bz2:
	$(WGET) ftp://ftp.alsa-project.org/pub/utils/alsa-utils-$(ALSA_VER).tar.bz2

$(ARCHIVE)/wireless_tools.$(WIRELESSTOOLS_VER).tar.gz:
	$(WGET) http://www.hpl.hp.com/personal/Jean_Tourrilhes/Linux/wireless_tools.$(WIRELESSTOOLS_VER).tar.gz

$(ARCHIVE)/wpa_supplicant-$(WPASUPP_VER).tar.gz:
	$(WGET) http://hostap.epitest.fi/releases/wpa_supplicant-$(WPASUPP_VER).tar.gz

$(ARCHIVE)/libnl-$(LIBNL_VER).tar.gz:
	$(WGET) -O $@ ftp://ftp.de.debian.org/debian/pool/main/libn/libnl/libnl_$(LIBNL_VER).orig.tar.gz

$(ARCHIVE)/graphlcd-base-$(GRAPHLCD_VER).tar.gz:
	$(WGET) -O $@ http://projects.vdr-developer.org/git/graphlcd-base.git/snapshot/graphlcd-base-$(GRAPHLCD_VER).tar.gz

$(ARCHIVE)/lzo-$(LZO_VER).tar.gz:
	$(WGET) -O $@ http://www.oberhumer.com/opensource/lzo/download/lzo-$(LZO_VER).tar.gz

# openazbox.org stuff
$(ARCHIVE)/initramfs-azbox%.tar.bz2 \
$(ARCHIVE)/azbox%-mrua-3.11.tar.gz \
$(ARCHIVE)/azbox%-dvb-modules-$(LINUX_AZBOX_VER)-opensat-$(AZBOX_DVB_M_VER).tar.gz:
	$(WGET) http://azbox-enigma2-project.googlecode.com/files/$(lastword $(subst /, ,$@))

$(ARCHIVE)/linux-azbox-$(LINUX_AZBOX_VER).tar.bz2:
	$(WGET) http://azbox-enigma2-project.googlecode.com/files/$(lastword $(subst /, ,$@))
