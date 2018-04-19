if [ $# -lt 1 ] || [ $# -gt 1 ]; 
then
    echo "Specify serial number"
    read serial_num
else
    fEx='.version'
    serial_num=$1
fi
if [[ -z "${serial_num// }" ]]
then
    echo "Error, no Serial number"
    exit -1
fi
file_name=$serial_num$fEx

git pull origin master-testing
#update unit
loopDone=0
while [[ $loopDone = 0 ]]; do

echo "Update Unit?: (Y,n)"
read isFlash
if [[ -z "${isFlash// }" ]] || [[ "$isFlash" = "y" ]] || [[ "$isFlash" = "Y" ]] || [[ "$isFlash" = "yes" ]]
then
    echo "Updating unit"
    scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no updateCrimsonRtm4 root@192.168.10.2:~/ 
    ssh root@192.168.10.2  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no '\
    ./updateCrimsonRtm4; \
    exit\
    '
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
tMCU=$(cat crimson-rtm4/versions|grep MCU|tail -c 9)
tFIRM=$(cat crimson-rtm4/versions|grep FIRMWARE|tail -c 9)
tMETAPV=$(cat crimson-rtm4/versions|grep METAPV|tail -c 41)
tWEB=$(cat crimson-rtm4/versions|grep WEB|tail -c 41)
tFPGA=$(cat crimson-rtm4/versions|grep FPGA|tail -c 10)


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
    echo "FRIMWARE Good $CFERM_u8"
else
    echo "FRIMWARE Bad: Crimson   $CFERM_u8  doesnt match $tFIRM"
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
fi
