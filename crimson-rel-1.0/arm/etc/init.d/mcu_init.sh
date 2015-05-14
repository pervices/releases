#!/bin/sh

case "$1" in
  start)
        uart-app "board -l 5"
        uart-app "fpga -o 1"
        ifconfig eth0 up
        ifconfig eth0 192.168.10.2
        ethtool -s eth0 speed 100 duplex full autoneg off
        mem rw sys4 0x3
        server &
        /etc/init.d/server_init.sh &
        mem rw sys3 0x1
        mem rw sys4 0x0
	;;
  stop)
	;;
esac

