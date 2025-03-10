#!/bin/bash -e
# crimson tng fpga update script
echo "Updating SD card FPGA image"
thisDir=$(pwd)
cd fpga
rm /lib/firmware/*rbf
cp ./update.sh /lib/firmware/
cp *.rbf /lib/firmware/

cd /lib/firmware
./update.sh hard

systemctl start crimson-website; 

cd $thisDir
exit 0
