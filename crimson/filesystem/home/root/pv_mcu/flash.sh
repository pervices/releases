#!/bin/bash

if [ $# -lt 1 ]
then
	echo "Usage : $0 dig | rx | tx | synth | all"
	exit
fi

if [ "$1" != 'synth' ] && [ "$1" != 'tx' ] && [ "$1" != 'rx' ] && [ "$1" != 'dig' ] && [ "$1" != 'all' ]
then
	echo "- invalid argument"
	echo "- Usage : $0 dig | rx | tx | synth | all"	
	exit
fi


if [ "$1" = 'synth' ] || [ "$1" = 'all' ]
then
	echo "-  Programming the synth board MCU..."
	echo -e "switch -s\r" > /dev/ttyS1
	usleep 300000
	echo -e "boot -e\r" > /dev/ttyS1
	usleep 300000
	echo -e "abcdefghijklmnopqrstuvwxyz\r" > /dev/ttyS1
	avrdude -c avr109 -B 8 -p x256a3u -P /dev/ttyS1 -b 115200 -e -U flash:w:synth.hex
	echo -e "exit\r" > /dev/ttyS1
	echo "- Done programming."
	usleep 300000
fi

if [ "$1" = 'rx' ] || [ "$1" = 'all' ]
then
	echo "-  Programming the rx board MCU..."
	echo -e "switch -r\r" > /dev/ttyS1
	usleep 300000
	echo -e "boot -e\r" > /dev/ttyS1
	usleep 300000
	echo -e "abcdefghijklmnopqrstuvwxyz\r" > /dev/ttyS1
	avrdude -c avr109 -B 8 -p x256a3u -P /dev/ttyS1 -b 115200 -e -U flash:w:rx.hex
	echo -e "exit\r" > /dev/ttyS1
	echo "- Done programming."
	usleep 4000000
fi

if [ "$1" = 'tx' ] || [ "$1" = 'all' ]
then
	echo "-  Programming the tx board MCU..."
	echo -e "switch -t\r" > /dev/ttyS1
	usleep 300000
	echo -e "boot -e\r" > /dev/ttyS1
	usleep 300000
	echo -e "abcdefghijklmnopqrstuvwxyz\r" > /dev/ttyS1
	avrdude -c avr109 -B 8 -p x256a3u -P /dev/ttyS1 -b 115200 -e -U flash:w:tx.hex
	echo -e "exit\r" > /dev/ttyS1
	echo "- Done programming."
	usleep 300000
fi

if [ "$1" = 'dig' ] || [ "$1" = 'all' ]
then
	echo "-  Programming the digital board MCU..."
	echo -e "boot -e\r" > /dev/ttyS1
	usleep 300000
	echo -e "abcdefghijklmnopqrstuvwxyz\r" > /dev/ttyS1
	avrdude -c avr109 -B 8 -p x256a3u -P /dev/ttyS1 -b 115200 -e -U flash:w:dig.hex
	echo "- Done programming. Please wait a few minutes for eLinux to boot-up."
fi
