sh create_ramdisk.sh;sh update-website.sh;sh update-mcu.sh; sh update-server.sh ; sh update-fpga-sd.sh ; echo "Waiting 2mins for server to come up"; sleep 120; sh checkVersion.sh; 
if [ -z "$1" ]
  then
    sh adf-lut.sh; 
  elif [ "$1" = "nolut" ]
    exit
  else
    sh adf-lut.sh; 
fi

