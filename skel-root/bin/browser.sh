#!/bin/sh
#
# wrapper script to start the QT demo browser

DFBARGS="cursor,linux-input-devices=/dev/event0,/dev/event1,/dev/event2"
export DFBARGS
/opt/qt/demos/browser/browser -qws -display directfb
