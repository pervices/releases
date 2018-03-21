rxHash=$(echo board -v |mcu -f r|grep Revision -m 1|tail -c 9); 
txHash=$(echo board -v |mcu -f t|grep Revision -m 1|tail -c 9); 
synthHash=$(echo board -v |mcu -f s|grep Revision -m 1|tail -c 9); 
serverHash=$(server -v|grep Revision|tail -c 9); 
fpgaHash=$(server -v |grep FPGA|tail -c 10); 
metapvHASH=$(cat /etc/crimson/crimson-filesystem|grep meta-pervices|tail -c 41); 
webHASH=$(cat /etc/crimson/crimson-website|tail -c 41); 

#Get Versions from versions file
CMCU=$(cat versions|grep MCU|tail -c 9)
CFIRM=$(cat versions|grep FIRMWARE|tail -c 9)
CMETAPV=$(cat versions|grep METAPV|tail -c 41)
CWEB=$(cat versions|grep WEB|tail -c 41)
CFPGA=$(cat versions|grep FPGA|tail -c 10)

error=0
echo "Checking Version"

if [[ "$CMCU" = "$rxHash" ]];
then
    echo "RX $CMCU"
else
    echo "RX Bad: Crimson $rxHash  doesnt match $CMCU"
    error=1
fi

if [[ "$CMCU" = "$txHash" ]];
then
    echo "TX $CMCU "
else
    echo "TX Bad: Crimson $txHash  doesnt match $CMCU"
    error=1
fi

if [[ "$CMCU" = "$synthHash" ]];
then
    echo "SYNTH $CMCU "
else
    echo "SYNTH Bad: Crimson Crimson  $synthHash  doesnt match $CMCU"
    error=1
fi

if [[ "$CFIRM" = "$serverHash" ]];
then
    echo "FRIMWARE $CFIRM"
else
    echo "FRIMWARE Bad: Crimson $serverHash  doesnt match $CFIRM"
    error=1
fi

if [[ "$CMETAPV" = "$metapvHASH" ]];
then
    echo "FS-METAPV $CMETAPV"
else
    echo "FS-METAPV Bad: Crimson   $metapvHASH  doesnt match $CMETAPV"
    error=1
fi

if [[ "$CWEB" = "$webHASH" ]];
then
    echo "WEBPV $CWEB"
else
    echo "WEBPV Bad: Crimson  $webHASH  doesnt match $CWEB"
    error=1
fi

if [[ "$CFPGA" = "$fpgaHash" ]];
then
    echo "FPGA $CFPGA"
else
    echo "FPGA Bad: Crimson $fpgaHash doesnt match $CFPGA"
    error=1
fi


if [[ "$error" = "1" ]];
then
    echo ""
    echo "=================="
    echo "VERSION MISMATCH"
    echo "=================="
else
    echo ""
    echo "=================="
    echo "VERSION GOOD"
    echo "=================="
fi
