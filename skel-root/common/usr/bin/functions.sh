#!/bin/sh

case $1 in
0)
	;;
1)
	/etc/init.d/camd restart
	;;
2)
	reboot
	;;
*)
	;;
esac

