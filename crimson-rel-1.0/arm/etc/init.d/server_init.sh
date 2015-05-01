#!/bin/sh

cd /home/root/pv_web
counter = 0
until node server.js; do
	echo "Crimson NodeJS crashed with exit code $?. Respawning..." > /home/root/node_crash.log
	sleep 1
   counter=$((counter+1))
   if [[ "$counter" -gt 5 ]]; then
      echo "Crimson NodeJS crashed repeatedly. Rebooting Crimson device..." > /home/root/node_crash.log
      echo "fpga -r" | mcu
   fi
done
