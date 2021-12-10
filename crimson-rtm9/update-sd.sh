if [ -z "$1" ]
  then
    sh create_ramdisk.sh;sh update-journal-size.sh; sh update-website.sh;sh update-mcu.sh; sh update-server.sh ; sh update-fpga-sd.sh ; echo "Waiting 1min for server to come up"; sleep 60; sh checkVersion.sh; 
    sh adf-lut.sh; 
  elif [ "$1" = "nolut" ]; then
    sh create_ramdisk.sh;sh update-journal-size.sh; sh update-website.sh;sh update-mcu.sh; sh update-server.sh ; sh update-fpga-sd.sh ; echo "Waiting 1min for server to come up"; sleep 60; sh checkVersion.sh;
  elif [ "$1" = "onlylut" ]; then
    sh adf-lut.sh; 
  else
    sh create_ramdisk.sh;sh update-journal-size.sh; sh update-website.sh;sh update-mcu.sh; sh update-server.sh ; sh update-fpga-sd.sh ; echo "Waiting 1min for server to come up"; sleep 60; sh checkVersion.sh; 
    sh adf-lut.sh; 
fi
