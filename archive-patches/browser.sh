#!/bin/sh
#
# wrapper script to start the QT demo browser

modprobe evdev
modprobe usbhid

# hack, but I cannot pass it on the commandline...
sed 's#linux-input-devices=.*#linux-input-devices=/dev/event0,/dev/event1#; s/no-cursor/cursor/;' /etc/directfbrc > /etc/directfbrc.browser
/opt/qt/demos/browser/browser -qws -display directfb
