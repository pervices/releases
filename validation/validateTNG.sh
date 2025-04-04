#!/bin/bash

#Ensure failure if something fails.
set -Eeuo pipefail

#update repository
git pull origin master

#remove host ssh
sed -i '/192.168.10.2/d' ~/.ssh/known_hosts

#ping crimson to ensure it is connected
echo "Checking connection to crimson..."
ping 192.168.10.2 -c 1 > /dev/null
rc=$?
if [[ $rc -eq 0 ]]; then
	echo "Device found at 192.168.10.2"
else
	echo "ERROR: unable to ping crimson at 192.168.10.2"
	exit
fi

echo "rtm12, rtm10, rtm9, rtm8, rtm7, rtm6, rtm5 or rtm4?: (12,10,9,8,7,6,5,4)"
read isrtm

if [[ $# == "0" ]]
then
	sparg=0
else 
	sparg=$1
fi

if [[ "$isrtm" -eq "12" ]] || [[ "$isrtm" = "rtm12" ]] || [[ "$isrtm" = "RTM12" ]]
then
    echo "Validating RTM12"
    ## changed PLL devices for RTM12. LUT no longer available
    sh validateHelper12.sh rtm12
    ./cleanSDCard.sh
elif [[ "$isrtm" -eq "10" ]] || [[ "$isrtm" = "rtm10" ]] || [[ "$isrtm" = "RTM10" ]]
then
    echo "Validating RTM10"
    if [ -z "$#" ] ## empty, generate LUT
    then
        sh validateHelper8.sh rtm10 lut
        
        # delete old information including LUT, but this script should run fast
        # enough to delete LUT directory before new LUT is generated and written
        # to /var/calibration-data/ so it is still deleting old information
        ./cleanSDCard.sh
    elif [ "$sparg" = "nolut" ] ## nolut, do not delete LUT
    then
        sh validateHelper8.sh rtm10 nolut
        ./cleanSDCard.sh nolut
    else # any other than nolut, generate lut
        sh validateHelper8.sh rtm10 lut
       ./cleanSDCard.sh
    fi
elif [[ "$isrtm" -eq "9" ]] || [[ "$isrtm" = "rtm9" ]] || [[ "$isrtm" = "RTM9" ]]
then
    echo "Validating RTM9"
    if [ -z "$#" ] ## empty, generate LUT
    then
        sh validateHelper8.sh rtm9 lut
        
        # delete old information including LUT, but this script should run fast
        # enough to delete LUT directory before new LUT is generated and written
        # to /var/calibration-data/ so it is still deleting old information
        ./cleanSDCard.sh
    elif [ "$sparg" = "nolut" ] ## nolut, do not delete LUT
    then
        sh validateHelper8.sh rtm9 nolut
        ./cleanSDCard.sh nolut
    else # any other than nolut, generate lut
        sh validateHelper8.sh rtm9 lut
       ./cleanSDCard.sh
    fi
elif [[ "$isrtm" -eq "8" ]] || [[ "$isrtm" = "rtm8" ]] || [[ "$isrtm" = "RTM8" ]]
then
    echo "Validating RTM8"
    if [ -z "$sparg" ]
    then
        sh validateHelper8.sh rtm8 lut
        ./cleanSDCard.sh
    elif [ "$sparg" = "nolut" ]
    then
        sh validateHelper8.sh rtm8 nolut
        ./cleanSDCard.sh nolut
    else
        sh validateHelper8.sh rtm8 lut
       ./cleanSDCard.sh
    fi
elif [[ "$isrtm" -eq "7" ]] || [[ "$isrtm" = "rtm7" ]] || [[ "$isrtm" = "RTM7" ]]
then
    echo "Validating RTM7"
    if [ -z "$sparg" ]
    then
        sh validateRTM5.sh rtm6
        ./cleanSDCard.sh
    elif [ "$sparg" = "nolut" ]
    then
        sh validateRTM5.sh rtm6 nolut
        ./cleanSDCard.sh nolut
    else
        sh validateRTM6.sh rtm6
       ./cleanSDCard.sh
    fi
elif [[ "$isrtm" -eq "6" ]] || [[ "$isrtm" = "rtm6" ]] || [[ "$isrtm" = "RTM6" ]]
then
    echo "Validating RTM6"
    if [ -z "$#" ]
    then
        sh validateRTM5.sh rtm6
        ./cleanSDCard.sh
    elif [ "$sparg" = "nolut" ]
    then
        sh validateRTM5.sh rtm6 nolut
        ./cleanSDCard.sh nolut
    else
        sh validateRTM6.sh rtm6
       ./cleanSDCard.sh
    fi
elif [[ "$isrtm" -eq "5" ]] || [[ "$isrtm" = "rtm5" ]] || [[ "$isrtm" = "RTM5" ]]
then
    echo "Validating RTM5"
    if [ -z "$#" ]
    then
        sh validateRTM5.sh rtm5
        ./cleanSDCard.sh
    elif [ "$sparg" = "nolut" ]
    then
        sh validateRTM5.sh rtm5 nolut
        ./cleanSDCard.sh nolut
    else
        sh validateRTM5.sh rtm5
       ./cleanSDCard.sh
    fi
elif [[ "$isrtm" -eq  "4" ]] || [[ "$isrtm" = "rtm4" ]] || [[ "$isrtm" = "RTM4" ]]
then
    echo "Validating RTM4"
    sh validateRTM4.sh
    ./cleanSDCard.sh
else
    echo "ERROR: selection invalid"

fi

