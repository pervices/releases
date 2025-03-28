 echo "Specify serial number"
read serial_num

if [[ -z "${serial_num// }" ]]
then
    echo "Error, no Serial number"
    exit -1
fi
file_name=$serial_num$fEx

BOARD_REV="$1"

if [[ "$BOARD_REV" -eq "8" ]] || [[ "$BOARD_REV" = "rtm8" ]] || [[ "$BOARD_REV" = "RTM8" ]]
    then
        BOARD_REV=8
        UPDATE_BIN="updateCrimsonRtm8-325msps"
        UPDATE_VER="../crimson-rtm8-325msps/versions"
        echo $UPDATE_BIN
elif [[ "$BOARD_REV" -eq "6" ]] || [[ "$BOARD_REV" = "rtm6" ]] || [[ "$BOARD_REV" = "RTM6" ]] || [[ "$BOARD_REV" -eq "7" ]] || [[ "$BOARD_REV" = "rtm7" ]] || [[ "$BOARD_REV" = "RTM7" ]]
    then
        BOARD_REV=6
        UPDATE_BIN="updateCrimsonRtm7-325msps"
        UPDATE_VER="../crimson-rtm6-325msps/versions"
        echo $UPDATE_BIN
elif [[ "$BOARD_REV" -eq "5" ]] || [[ "$BOARD_REV" = "rtm5" ]] || [[ "$BOARD_REV" = "RTM5" ]]
    then
        echo "ERROR: RTM5 currently not supported"
        exit
        BOARD_REV=5
        UPDATE_BIN="updateCrimsonRtm5"
        UPDATE_VER="../crimson-rtm5/versions"
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
    ssh root@192.168.10.2  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "\
        date -Ins -s $DATE; hwclock -w; rm -rf /home/dev0/{*,.bash_history}; rm -rf /home/root/{*,.bash_history}; history -c; exit \
        "

    scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ../$UPDATE_BIN root@192.168.10.2:~/


    if [ -z "$2" ]
    then
        ssh root@192.168.10.2  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "\
        ./$UPDATE_BIN; \
        exit\
        "
    elif [ "$2" = "nolut" ]
    then
        ssh root@192.168.10.2  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "\
        ./$UPDATE_BIN nolut; \
        exit\
        "
    else
        ssh root@192.168.10.2  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "\
        ./$UPDATE_BIN; \
        exit\
        "
    fi
    sleep 120
    echo ""
    loopDone=1
elif [[ "$isFlash" = "n" ]] || [[ "$isFlash" = "N" ]] || [[ "$isFlash" = "n0" ]]
then
    echo ""
    loopDone=1
fi
done
#scp updateCrimsonRtm4 root@192.168.10.2:~/
#ssh root@192.168.10.2  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ./updateCrimsonRtm4 

#Get Versions from versions file
tMCU=$(cat $UPDATE_VER|grep MCU|tail -c 9)
tFIRM=$(cat $UPDATE_VER|grep FIRMWARE|tail -c 9)
tMETAPV=$(cat $UPDATE_VER|grep METAPV|tail -c 41)
tWEB=$(cat $UPDATE_VER|grep WEB|tail -c 41)
tFPGA=$(cat $UPDATE_VER|grep FPGA|tail -c 10)


#Check Versions
echo "Checking Versions"
a="$(ssh root@192.168.10.2  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no '\
rxHash=$(echo board -v |mcu -f r|grep Revision|head -1|tail -c 9); \
txHash=$(echo board -v |mcu -f t|grep Revision|head -1|tail -c 9); \
synthHash=$(echo board -v |mcu -f s|grep Revision|head -1|tail -c 9); \
serverHash=$(server -v|grep Revision|tail -c 9); \
fpgaHash=$(server -v |grep FPGA|tail -c 10); \
echo "RX: $rxHash"; \
echo "TX: $txHash"; \
echo "SYNTH: $synthHash"; \
echo "SERVER: $serverHash"; \
echo "FPGA $fpgaHash"; \
')"
echo $a
CRX_u8=$(echo "$a"|grep RX|tail -c 9)
CTX_u8=$(echo "$a"|grep TX|tail -c 9)
CSYNTH_u8=$(echo "$a"|grep SYNTH|tail -c 9)
CFERM_u8=$(echo "$a"|grep SERVER|tail -c 9)
CFPGA_u9=$(echo "$a"|grep FPGA|tail -c 10)

if [[ "$BOARD_REV" -ge 8 ]];
then
    #Check Versions
    echo "Checking Versions"
    b="$(ssh root@192.168.10.2  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no '\
    rxHW=$(cat /var/volatile/crimson/state/rx_a/about/hw_ver); \
    txHW=$(cat /var/volatile/crimson/state/tx_a/about/hw_ver); \
    synthHW=$(cat /var/volatile/crimson/state/time/about/hw_ver); \
    fpgaHW=$(cat /var/volatile/crimson/state/fpga/about/hw_ver); \
    echo "HW_RX: $rxHW"; \
    echo "HW_TX: $txHW"; \
    echo "HW_SYNTH: $synthHW"; \
    echo "HW_FPGA $fpgaHW"; \
    ')"
    echo $b
fi

error=0
if [[ "$CRX_u8" = "$tMCU" ]];
then
    echo "RX Good $CRX_u8"
else
    echo "RX Bad: Crimson $CRX_u8  doesnt match $tMCU"
    error=1
fi

if [[ "$CTX_u8" = "$tMCU" ]];
then
    echo "TX Good $CTX_u8 "
else
    echo "TX Bad: Crimson $CTX_u8  doesnt match $tMCU"
    error=1
fi

if [[ "$CSYNTH_u8" = "$tMCU" ]];
then
    echo "SYNTH Good $CSYNTH_u8 "
else
    echo "SYNTH Bad: Crimson Crimson  $CSYNTH_u8  doesnt match $tMCU"
    error=1
fi

if [[ "$CFERM_u8" = "$tFIRM" ]];
then
    echo "FIRMWARE Good $CFERM_u8"
else
    echo "FIRMWARE Bad: Crimson   $CFERM_u8  doesnt match $tFIRM"
    error=1
fi

if [[ "$CFPGA_u9" = "$tFPGA" ]];
then
    echo "FPGA Good $CFPGA_u9"
else
    echo "FPGA Bad: Crimson  $CFPGA_u9 doesnt match $tFPGA"
    error=1
fi


if [[ "$error" = "1" ]];
then
    echo ""
    echo "=================="
    echo "VERSION MISMATCH"
    echo "=================="
else
    echo "Serial Number: $serial_num" > $file_name
    echo "MCU_RX: $CRX_u8" >> $file_name
    echo "MCU_TX: $CTX_u8" >> $file_name
    echo "MCU_SYNTH: $CSYNTH_u8" >> $file_name
    echo "SERVER: $CFERM_u8" >> $file_name
    echo "FPGA: $CFPGA_u9" >> $file_name
    
    if [[ "$BOARD_REV" -ge 8 ]];
    then
        RX_HW=$(echo "$b"|grep --line-buffered 'RX')
        TX_HW=$(echo "$b"|grep --line-buffered 'TX')
        SYNTH_HW=$(echo "$b"|grep --line-buffered 'SYNTH')
        FPGA_HW=$(echo "$b"|grep --line-buffered 'FPGA')
        echo "$RX_HW" | tee -a $file_name
        echo "$TX_HW" | tee -a $file_name
        echo "$SYNTH_HW" | tee -a $file_name
        echo "$FPGA_HW" | tee -a $file_name
    fi
fi


