#!/bin/sh
IFS=/
set $PRODUCT
IFS=
VENDORID=`printf "%.4x" $1`
PRODUCTID=`printf "%.4x" $2`
C="/share/usb_modeswitch/$VENDORID:$PRODUCTID"
[ -f "$C" ] && usb_modeswitch -v $VENDORID -p $PRODUCTID -c "$C"

