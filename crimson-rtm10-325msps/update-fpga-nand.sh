echo "Updating NAND FPGA image"
cp fpga/soc_system.rbf /lib/firmware/
sh /lib/firmware/update.sh hard
