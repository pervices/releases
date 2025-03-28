#Ensure failure for possible problem indications.
set -Eeuo pipefail

echo "Specify serial number"
read serial_num

if [[ -z "${serial_num// }" ]]
then
    echo "Error, no Serial number"
    exit -1
fi
file_name=$serial_num

BOARD_REV="$1"

if [[ "$BOARD_REV" = 'rtm10' ]]
then
        BOARD_REV=10
        UPDATE_BIN="updateCrimsonRtm10-325msps"
        UPDATE_VER="../crimson-rtm10-325msps/versions"
        echo $UPDATE_BIN
elif [[ "$BOARD_REV" = 'rtm9' ]]
then
        BOARD_REV=9
        UPDATE_BIN="updateCrimsonRtm9-325msps"
        UPDATE_VER="../crimson-rtm9-325msps/versions"
        echo $UPDATE_BIN
elif [[ "$BOARD_REV" = "rtm8" ]]
then
        BOARD_REV=8
        UPDATE_BIN="updateCrimsonRtm8-325msps"
        UPDATE_VER="../crimson-rtm8-325msps/versions"
        echo $UPDATE_BIN
else
    echo "Error, invalid revision."
    exit -1
fi


#git pull origin master-testing
#update unit
loopDone=0
while [[ $loopDone = 0 ]]; do

echo "Update Unit?: (Y,n)"
read isFlash
if [[ -z "${isFlash// }" ]] || [[ "$isFlash" = "y" ]] || [[ "$isFlash" = "Y" ]] || [[ "$isFlash" = "yes" ]]
then
    echo "Updating unit"

    DATE=$(date -Ins); 
    sshpass -p "dev0" ssh -tq dev0@192.168.10.2  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "\
        echo dev0 | sudo -S date -Ins -s $DATE; echo dev0 | sudo -S /sbin/hwclock -w;\
        exit\
        " > /dev/null
    if [ $? -eq 0 ]
    then
        echo hwclock update success
    else
        echo "WARNING: hwclock update failed. This problem MUST be fixed before this unit can be shipped. Do you wish to continue with the validation?: (Y,n)"
        read continue
        if [[ "$continue" = "y" ]] || [[ "$continue" = "Y" ]] || [[ "$continue" = "yes" ]]
        then
            echo "Continuing validation..."
        else
            echo "Aborting validation."
            exit -1
        fi
    fi

    sshpass -p "dev0" ssh -tq dev0@192.168.10.2  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "\
        echo dev0 | sudo -S rm -rf /home/dev0/{*,.bash_history}; echo dev0 | sudo -S rm -rf /home/root/{*,.bash_history}; history -c;\
        exit\
        " > /dev/null

    sshpass -p "dev0" scp -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ../$UPDATE_BIN dev0@192.168.10.2:~/ > /dev/null

    sshpass -p "dev0" ssh -tq dev0@192.168.10.2  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "\
        echo dev0 | sudo -S ./$UPDATE_BIN nolut; \
        exit\
        "

    echo ""
    loopDone=1
elif [[ "$isFlash" = "n" ]] || [[ "$isFlash" = "N" ]] || [[ "$isFlash" = "n0" ]]
then
    echo ""
    loopDone=1
fi
done

#Get Versions from versions file
tMCU=$(cat $UPDATE_VER|grep MCU|tail -c 9)
tFIRM=$(cat $UPDATE_VER|grep FIRMWARE|tail -c 9 | head -c 8)
tMETAPV=$(cat $UPDATE_VER|grep METAPV|tail -c 41)
tWEB=$(cat $UPDATE_VER|grep WEB|tail -c 41)
tFPGA=$(cat $UPDATE_VER|grep FPGA|tail -c 10 | head -c 9)

#Check Versions
echo -n "Checking Versions"
rxHash=$(sshpass -p "dev0" ssh -q dev0@192.168.10.2  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "echo board -v |mcu -f r|grep Revision|head -1|tail -c 9")
echo -n "."
txHash=$(sshpass -p "dev0" ssh -q dev0@192.168.10.2  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "echo board -v |mcu -f t|grep Revision|head -1|tail -c 9")
echo -n "."
synthHash=$(sshpass -p "dev0" ssh -q dev0@192.168.10.2  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "echo board -v |mcu -f s|grep Revision|head -1|tail -c 9")
echo -n "."
serverHash=$(sshpass -p "dev0" ssh -tq dev0@192.168.10.2  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "echo dev0 | sudo -S server -v|grep Revision")
echo -n "."
fpgaHash=$(sshpass -p "dev0" ssh -tq dev0@192.168.10.2  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "echo dev0 | sudo -S sudo server -v |grep FPGA")
echo -n "."
RX_HW=$(sshpass -p "dev0" ssh -tq dev0@192.168.10.2  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "echo dev0 | sudo -S sudo cat /var/volatile/crimson/state/rx_a/about/hw_ver | grep Features")
echo -n "."
TX_HW=$(sshpass -p "dev0" ssh -tq dev0@192.168.10.2  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "echo dev0 | sudo -S sudo cat /var/volatile/crimson/state/tx_a/about/hw_ver | grep Features")
echo -n "."
SYNTH_HW=$(sshpass -p "dev0" ssh -tq dev0@192.168.10.2  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "echo dev0 | sudo -S sudo cat /var/volatile/crimson/state/time/about/hw_ver | grep Features")
echo "."
if FPGA_HW=$(sshpass -p "dev0" ssh -tq dev0@192.168.10.2  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "echo dev0 | sudo -S sudo cat /var/volatile/crimson/state/fpga/about/hw_ver | grep Features")
then
	echo "."
else
        echo "WARNING: Failed to read Digital board EEPROM. Do you wish to continue with the validation?: (Y,n)"
        read continue
        if [[ "$continue" = "y" ]] || [[ "$continue" = "Y" ]] || [[ "$continue" = "yes" ]]
        then
            echo "Continuing validation..."
        else
            echo "Aborting validation."
            exit -1
        fi
fi

firmHash=$(echo $serverHash | tail -c 10 | head -c 8)
fpgaHash=$(echo $fpgaHash | tail -c 11 | head -c 9)

echo Software Versions
error=0
if [[ "$rxHash" = "$tMCU" ]];
then
    echo "RX Good $rxHash"
else
    echo "RX Bad: Crimson $rxHash doesnt match $tMCU"
    error=1
fi

if [[ "$txHash" = "$tMCU" ]];
then
    echo "TX Good $txHash"
else
    echo "TX Bad: Crimson $txHash doesnt match $tMCU"
    error=1
fi

if [[ "$synthHash" = "$tMCU" ]];
then
    echo "SYNTH Good $synthHash"
else
    echo "SYNTH Bad: Crimson $synthHash doesnt match $tMCU"
    error=1
fi

if [[ "$firmHash" = "$tFIRM" ]];
then
    echo "FIRMWARE Good $firmHash"
else
    echo "FIRMWARE Bad: Crimson $firmHash doesnt match $tFIRM"
    error=1
fi

if [[ "$fpgaHash" = "$tFPGA" ]];
then
    echo "FPGA Good $fpgaHash"
else
    echo "FPGA Bad: Crimson $fpgaHash doesnt match $tFPGA"
    error=1
fi

echo ""
echo "Hardware Versions"
echo "Serial Number: $serial_num" > $file_name
echo "Validator: $UPDATE_BIN" >> $file_name
echo "MCU_RX: $rxHash" >> $file_name
echo "MCU_TX: $txHash" >> $file_name
echo "MCU_SYNTH: $synthHash" >> $file_name
echo "SERVER: $firmHash" >> $file_name
echo "FPGA: $fpgaHash" >> $file_name
echo "$RX_HW" | tee -a $file_name
echo "$TX_HW" | tee -a $file_name
echo "$SYNTH_HW" | tee -a $file_name
echo "$FPGA_HW" | tee -a $file_name
echo ""

if [[ "$error" = "1" ]];
then
    echo "==================" | tee -a $file_name
    echo "VERSION MISMATCH"   | tee -a $file_name
    echo "==================" | tee -a $file_name
    if [ -z "$2" ]
        then
            echo "WARNING: Lookup table not generated" | tee -a $file_name
        elif [ "$2" = "nolut" ]
        then
            echo "Lookup table not generated" | tee -a $file_name
            echo ""
        else
            echo "WARNING: Lookup table not generated" | tee -a $file_name
        fi
else
    current_time=$(date "+%Y.%m.%d-%H.%M.%S")
    # update lookup table last, if it is going to be done
    if [[ -z "${isFlash// }" ]] || [[ "$isFlash" = "y" ]] || [[ "$isFlash" = "Y" ]] || [[ "$isFlash" = "yes" ]]
    then
        if [ -z "$2" ]
        then
            echo "Calibration table generation start time: $current_time (UTC)"
            echo "Calibration table is generated when the bottom status LED stops blinking"
            echo "This can take some time (up to 3 hours), please do not turn off the unit until the bottom LED stops blinking"
            sshpass -p "dev0" ssh -tq dev0@192.168.10.2  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "\
            echo dev0 | sudo -S ./$UPDATE_BIN onlylut; \
            exit\
            " > /dev/null
        elif [ "$2" = "nolut" ]
        then
            echo "Lookup table not generated" | tee -a $file_name
            echo ""
        else
            echo "Calibration table generation start time: $current_time (UTC)"
            echo "Calibration table is generated when the bottom status LED stops blinking"
            echo "This can take some time (up to 3 hours), please do not turn off the unit until the bottom LED stops blinking"
            sshpass -p "dev0" ssh -tq dev0@192.168.10.2  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "\
            echo dev0 | sudo -S ./$UPDATE_BIN onlylut; \
            exit\
            " > /dev/null
        fi
    else
        echo "Lookup table not generated" | tee -a $file_name
        echo ""
    fi
fi
