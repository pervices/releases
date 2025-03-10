#!/bin/bash -e
# crimson tng fpga update script
red="\e[1;31m"
normal="\e[0m"
green="\e[1;32m"
bold="\e[1m"
yellow="\e[1;33m"
ok="[$green   OK   $normal]"
failed="[$red FAILED $normal]"
warning="[$yellow WARNING$normal]"
mountfolder="/config"
sd_mountfolder="/media/card"
fpga_image_location="/dev/mmcblk0p1"
fpga="/lib/firmware/soc_system.rbf"
overlay="/lib/firmware/update.dtb"
version_path="/etc/crimson"
version=$(tail -1 $version_path/crimson-fpga | cut -d '-' -f2)
lwhps2fpga="/sys/class/fpga_bridge/br0"
hps2fpga="/sys/class/fpga_bridge/br1"
fpga2hps="/sys/class/fpga_bridge/br2"
fpga2sdram="/sys/class/fpga_bridge/br3"
fpga_manager="/sys/class/fpga_manager"
fpga_update="/device-tree/overlays/fpga-update"
fpga_nand="/dev/mtd2"

case "$1" in
soft)
	echo "[        ] Verifying Source files..."
	if [[ -f "$fpga" ]] && [[ -f "$overlay" ]]; then
		echo -e "$ok Verified source files"
	elif [[ -f "$fpga" ]]; then
		echo -e "$failed device tree overlay is missing"
		exit 1
	elif [[ -f "$overlay" ]]; then
		echo -e "$failed FPGA image is missing"
		exit 1
	else
		echo -e "$failed Both FPGA image and device tree overlay are missing"
		exit 1
	fi
	echo "[        ] Verifying FPGA manager's status..."
	grep -Fxq "operating" $fpga_manager/fpga0/state
	rc0=$?
	if [[ $rc0 != 0 ]]; then
		echo -e "$failed FPGA manager is not operating"
		exit $rc0
	else
		echo -e "$ok FPGA manager is operating"
	fi
	echo "[        ] Updating FPGA firmware..."
	if [[ -d $mountfolder ]]
	then
		if [[ $(mountpoint $mountfolder | grep "not") ]]
		then
			if [[ $(ls -A $mountfolder) ]]
			then
				echo -e "$warning ConfigFS is not mounted at $mountfolder. However, $mountfolder is NOT empty"
				echo -e "$warning Will use $mountfolder-tmp instead"
				mountfolder='/config-tmp'
				if [[ -d $mountfolder ]]
				then
					echo -e "$failed /config-tmp is also being used please clean up, exiting..."
					exit 1
				fi
				mkdir $mountfolder
				mount -t configfs configfs $mountfolder
				if [[ -d $mountfolder$fpga_update ]]
				then
					rmdir $mountfolder$fpga_update
				fi
				mkdir -p $mountfolder$fpga_update
				echo -e "$warning Consider cleaning up /config"
			else
				mount -t configfs configfs $mountfolder
				if [[ -d $mountfolder$fpga_update ]]
				then
					rmdir $mountfolder$fpga_update
				fi
				mkdir $mountfolder$fpga_update
			fi
		else
			if [[ $(mount | grep "configfs on /config") ]]
			then
				echo -e "$warning ConfigFS has already been mounted at $mountfolder"
				echo -e "$warning Either previous soft FPGA update wasn't done cleanly"
				echo -e "$warning or other programs are accessing it"
				if [[ -d $mountfolder$fpga_update ]]
				then
					rmdir $mountfolder$fpga_update
				fi
				mkdir -p $mountfolder$fpga_update
			else
				echo -e "$failed $mountfolder is being mounted, exiting..."
				exit 1
			fi
		fi
	else
		mkdir $mountfolder
		mount -t configfs configfs $mountfolder
		if [[ -d $mountfolder$fpga_update ]]
		then
			rmdir $mountfolder$fpga_update
		fi
		mkdir $mountfolder$fpga_update
	fi
	echo "[        ] Stopping server..."
	systemctl stop crimson-server
	rc1=$?
	if [[ $rc1 != 0 ]]; then
		echo -e "$failed Failed to stop server, exiting..."
		exit $rc1
	fi
	echo -e "$ok Successfully stopped server..."
	cd /lib/firmware
	echo update.dtb > $mountfolder$fpga_update/path
	echo "[        ] Verifying component status"
	grep -Fxq "applied" $mountfolder$fpga_update/status
	rc2=$?
	grep -Fxq "enabled" $lwhps2fpga/state
	rc3=$?
	grep -Fxq "enabled" $hps2fpga/state
	rc4=$?
	grep -Fxq "enabled" $fpga2hps/state
	rc5=$?
	grep -Fxq "enabled" $fpga2sdram/state
	rc6=$?
	grep -Fxq "operating" $fpga_manager/fpga0/state
	rc7=$?
	if [[ $rc2 != 0 ]]; then
		echo -e "$failed Update FAILED, device tree overlay is not applied"
	elif [[ $rc3 != 0 ]]; then
		echo -e "$failed Update FAILED, lwhps2fpga bridge is not enabled"
	elif [[ $rc4 != 0 ]]; then
		echo -e "$failed Update FAILED, hps2fpga bridge is not enabled"
	elif [[ $rc5 != 0 ]]; then
		echo -e "$failed Update FAILED, fpga2hps bridge is not enabled"
	elif [[ $rc6 != 0 ]]; then
		echo -e "$failed Update FAILED, fpga2sdram bridge is not enabled"
	elif [[ $rc7 != 0 ]]; then
		echo -e "$failed Update FAILED, FPGA manager is not operating"
	elif [[ $rc2 != 0 || $rc3 != 0 || $rc4 != 0 || $rc5 != 0 || $rc6 != 0 || $rc7 != 0 ]]; then
		echo -e "[        ] Cleaning up..."
		umount $mountfolder
		rmdir $mountfolder
		rc8=$?
		if [[ $rc8 != 0 ]]; then
			echo -e "$failed Failed to unmount the configFS"
		else
			echo -e "$ok Done Cleaning up"
		fi
		exit 1
	else
		echo -e "$ok Updated FPGA firmware"
		echo -e "[        ] Cleaning up..."
		umount $mountfolder
		rmdir $mountfolder
		rc9=$?
		if [[ $rc9 != 0 ]]; then
			echo -e "$failed Failed to unmount the configFS"
		else
			echo -e "$ok Done Cleaning up"
		fi
	fi
	echo "installed-${version}-temp" >> $version_path/crimson-fpga
	echo "[        ] Restarting service..."
	systemctl start crimson-website
	rc10=$?
	if [[ $rc10 != 0 ]]; then
		echo -e "$failed Failed to restart service, exiting..."
		exit $rc10
	else
		echo -e "$ok Successfully restarted service"
	fi
	sleep 10
	echo -e "$ok Soft update Successful"
	;;
hard)
	./$0 soft
	echo -e "[        ] Updating FPGA image on NAND"
		flash_erase $fpga_nand 0 0
		nandwrite -p $fpga_nand $fpga
	echo -e "$ok Done flashing FPGA image on NAND"
	;;
*)
	echo -e "$bold Usage: ./update {soft|hard} $normal"
	echo -e "$bold Soft: Update the FPGA image immediately, will loss it after power off $normal"
	echo -e "$bold Hard: Similar to soft except that the FPGA imgae is updated permanently $normal"
	exit 1
	;;
esac

exit 0
