#!/bin/sh

case "$1" in
  start)
        uart-app "board -l 5"
        uart-app "fpga -o 1"
	cp /www/pages/dig/state_default.xml /www/pages/dig/state_current.xml
	cp /www/pages/rx/state_default.xml /www/pages/rx/state_current.xml
	cp /www/pages/tx/state_default.xml /www/pages/tx/state_current.xml
	cp /www/pages/synth/state_default.xml /www/pages/synth/state_current.xml
	ifconfig eth0 up
        ifconfig eth0 192.168.10.2
        ethtool -s eth0 speed 100 duplex full autoneg off
	mem rw sys3 0x1
   cd /home/root/pv_web; node server.js &
   server &
	;;
  stop)
	;;
esac

