#!/bin/bash
version=$(tail -1 /etc/crimson/crimson-mcu | cut -d '-' -f2)

TIMEOUT_RX=5750000
TIMEOUT_TX=5500000
TIMEOUT_SYNTH=5750000

AVRDUDE_FUSES="-U fuse2:w:0xBE:m  -U fuse4:w:0xF3:m -U fuse5:w:0xE9:m -U fuse0:w:0x04:m"

if [ $# -lt 1 ]
then
	echo "Usage : $0 rx | tx | synth | all"
	exit
fi

if [ "$1" != 'synth' ] && [ "$1" != 'tx' ] && [ "$1" != 'rx' ] && [ "$1" != 'all' ]
then
	echo "- invalid argument"
	echo "- Usage : $0 rx | tx | synth | all"	
	exit
fi


if [ "$1" = 'synth' ] || [ "$1" = 'all' ]
then
	echo "- Programming the synth board MCU..."
	echo -e "boot -e\r" > /dev/ttycrimson-time
	usleep $TIMEOUT_SYNTH
	echo -e "abcdefghijklmnopqrstuvwxyz\r" > /dev/ttycrimson-time
	avrdude -c avr109 -B 8 -p x256a3u -P /dev/ttycrimson-time -b 115200 -e -U flash:w:synth.hex -V $AVRDUDE_FUSES
	echo "- Done programming."
	echo "installed-${version}-synth" >> /etc/crimson/crimson-mcu
	usleep 300000
fi

if [ "$1" = 'rx' ] || [ "$1" = 'all' ]
then
	echo "- Programming the rx board MCU..."
	echo -e "boot -e\r" > /dev/ttycrimson-rx
	usleep $TIMEOUT_RX
	echo -e "abcdefghijklmnopqrstuvwxyz\r" > /dev/ttycrimson-rx
	avrdude -c avr109 -B 8 -p x256a3u -P /dev/ttycrimson-rx -b 115200 -e -U flash:w:rx.hex -V $AVRDUDE_FUSES
	echo -e "exit\r" > /dev/ttycrimson-rx
	echo "- Done programming."
	echo "installed-${version}-rx" >> /etc/crimson/crimson-mcu
	usleep 4000000
fi

if [ "$1" = 'tx' ] || [ "$1" = 'all' ]
then
	echo "- Programming the tx board MCU..."
	echo -e "boot -e\r" > /dev/ttycrimson-tx
	usleep $TIMEOUT_SYNTH
	echo -e "abcdefghijklmnopqrstuvwxyz\r" > /dev/ttycrimson-tx
	avrdude -c avr109 -B 8 -p x256a3u -P /dev/ttycrimson-tx -b 115200 -e -U flash:w:tx.hex -V $AVRDUDE_FUSES
	echo -e "exit\r" > /dev/ttycrimson-tx
	echo "- Done programming."
	echo "installed-${version}-rx" >> /etc/crimson/crimson-mcu
	usleep 300000
fi
