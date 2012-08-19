#!/bin/sh
IFS=/
set $PRODUCT
IFS=
VENDORID=`printf "%.4x" 0x$1`
PRODUCTID=`printf "%.4x" 0x$2`
C="/share/usb_modeswitch/$VENDORID:$PRODUCTID"
if [ -f "$C" ]
then
	usb_modeswitch -v $VENDORID -p $PRODUCTID -c "$C"
	exit 0;
fi
case "$TYPE" in
2/*)
	modprobe -q usbserial
	echo  $VENDORID $PRODUCTID >/sys/bus/usb-serial/drivers/generic/new_id
	;;
esac

