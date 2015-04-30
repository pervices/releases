#!/bin/sh

cd /home/root/pv_web
until node server.js; do
	echo "Crimson NodeJS crashed with exit code $?. Respawning..." > /home/root/node_crash.log
	sleep 1
done
