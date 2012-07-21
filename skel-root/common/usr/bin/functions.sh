#!/bin/sh

case $1 in
0)
	;;
1)
	/etc/init.d/cam restart
	;;
2)
	reboot
	;;
*)
	;;
esac

