if uname -m | grep -v armv7l
then
	echo "ERROR: It appears you're running this update package on a host machine."
	echo "Please use scp to copy the update package onto a Crimson SDR."
	exit 1
fi

sh create_ramdisk.sh norestart; sh update-journal-size.sh; sh update-fs.sh; sh update-website.sh norestart; sh update-mcu.sh norestart; sh update-server.sh norestart; sh update-fpga-sd.sh; sync; sh checkVersion.sh;
