echo "Updating SD card FPGA image"
cd fpga
mkdir fpgamount
mount /dev/mmcblk0p1 fpgamount
cp soc_system.rbf fpgamount
sync
umount fpgamount
rm -rf fpgamount
cd ../
