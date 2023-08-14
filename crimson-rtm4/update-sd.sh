if uname -m | grep -v armv7l
then
	echo "ERROR: It appears you're running this update package on a host machine."
	echo "Please use scp to copy the update package onto a Crimson SDR."
	exit 1
fi

sh create_ramdisk.sh;sh update-journal-size.sh; sh update-mcu.sh; sh update-server.sh ; sh update-fpga-sd.sh ; echo "Waiting 2mins for server to come up"; sleep 120; sh checkVersion.sh; sleep 10; echo "Restarting"; mem rw sys0 0;
