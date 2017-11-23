#!/bin/bash

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
	echo "-  Programming the synth board MCU..."
	#usleep 300000
	echo -e "boot -e\r" > /dev/ttycrimson-time
	usleep 5500000
	echo -e "abcdefghijklmnopqrstuvwxyz\r" > /dev/ttycrimson-time
	avrdude -c avr109 -B 8 -p x256a3u -P /dev/ttycrimson-time -b 115200 -e -U flash:w:synth.hex
	echo -e "exit\r" > /dev/ttycrimson-time
	echo "- Done programming."
	usleep 300000
fi

if [ "$1" = 'rx' ] || [ "$1" = 'all' ]
then
	echo "-  Programming the rx board MCU..."
	#usleep 300000
	echo -e "boot -e\r" > /dev/ttycrimson-rx
	usleep 5500000
	echo -e "abcdefghijklmnopqrstuvwxyz\r" > /dev/ttycrimson-rx
	avrdude -c avr109 -B 8 -p x256a3u -P /dev/ttycrimson-rx -b 115200 -e -U flash:w:rx.hex
	echo -e "exit\r" > /dev/ttycrimson-rx
	echo "- Done programming."
	usleep 4000000
fi

if [ "$1" = 'tx' ] || [ "$1" = 'all' ]
then
	echo "-  Programming the tx board MCU..."
	#usleep 300000
	echo -e "boot -e\r" > /dev/ttycrimson-tx
	usleep 5500000
	echo -e "abcdefghijklmnopqrstuvwxyz\r" > /dev/ttycrimson-tx
	avrdude -c avr109 -B 8 -p x256a3u -P /dev/ttycrimson-tx -b 115200 -e -U flash:w:tx.hex
	echo -e "exit\r" > /dev/ttycrimson-tx
	echo "- Done programming."
	usleep 300000
fi
