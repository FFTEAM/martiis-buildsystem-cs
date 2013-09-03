#!/bin/sh
#
# mirror the most important git repositories from gitorious
#
# (C) 2013 Stefan Seyfried
# License: WTFPL v2
#

GITORIOUS=git://gitorious.org
GITORIOUS_RW=ssh://git@gitorious.org

REPOS="	open-duckbox-project-sh4/tdt.git
	seife/td-dvb-wrapper.git
	neutrino-mp/neutrino-mp.git
	neutrino-hd/libstb-hal.git
	neutrino-hd/neutrino-hd-plugins.git
	neutrino-hd/buildsystem-cs.git
	neutrino-mp/tdt-driver.git"
# those are no longer used
#	neutrino-hd/neutrino-hd.git
#	neutrino-hd/neutrino-hd-tripledragon.git

if ! [ -d gitorious ]; then
	mkdir gitorious
fi
cd gitorious
TOP=$PWD
for i in $REPOS; do
	echo "processing $i"
	if [ -d $i ]; then
		cd $i
		git fetch origin master:master
		cd $TOP
	else
		dir=$(dirname $i)
		mkdir -p $dir
		cd $dir
		git clone --bare $GITORIOUS/$i
		cd $(basename $i)
		git remote add origin-rw $GITORIOUS_RW/$i
		cd $TOP
	fi
done
