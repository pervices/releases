if uname -m | grep -v armv7l
then
	echo "ERROR: It appears you're running this update package on a host machine."
	echo "Please use scp to copy the update package onto a Crimson SDR."
	exit 1
fi

if [ -z "$1" ]
  then
    sh create_ramdisk.sh; sh update-journal-size.sh; sh update-fs.sh; sh update-website.sh; sh update-mcu.sh; sh update-server.sh; sh update-fpga-sd.sh; echo "Waiting 1min for server to come up"; sleep 60; sh checkVersion.sh;
    sh adf-lut.sh && sync && sleep 10800 && reboot;
  elif [ "$1" = "nolut" ]; then
    sh create_ramdisk.sh; sh update-journal-size.sh; sh update-fs.sh; sh update-website.sh; sh update-mcu.sh; sh update-server.sh; sh update-fpga-sd.sh; echo "Waiting 1min for server to come up"; sleep 60; sh checkVersion.sh;
  elif [ "$1" = "onlylut" ]; then
    sh adf-lut.sh && sync && sleep 10800 && reboot;
  else
    sh create_ramdisk.sh; sh update-journal-size.sh; sh update-fs.sh; sh update-website.sh; sh update-mcu.sh; sh update-server.sh; sh update-fpga-sd.sh; echo "Waiting 1min for server to come up"; sleep 60; sh checkVersion.sh;
    sh adf-lut.sh && sync && sleep 10800 && reboot;
fi
