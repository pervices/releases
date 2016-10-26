#!/bin/sh

cd /home/root/pv_web
counter = 0
until node server.js; do
   mem rw sys3 0x0
   mem rw sys4 0x3

	echo "Crimson NodeJS crashed with exit code $?. Respawning..." > /home/root/node_crash.log
	sleep 1
   counter=$((counter+1))
   if [[ "$counter" -gt 10 ]]; then
      echo "Crimson NodeJS crashed repeatedly. Rebooting Crimson device..." > /home/root/node_crash.log
      echo "fpga -r" | mcu
   fi

   mem rw sys3 0x1
   mem rw sys4 0x0
done
