#Ensure failure if something fails.
set -Eeuo pipefail

#update repository
git pull origin master

#remove host ssh
sed -i '/192.168.10.2/d' ~/.ssh/known_hosts

echo "rtm9, rtm8, rtm7, rtm6, rtm5 or rtm4?: (9,8,7,6,5,4)"
read isrtm

#TOFIX: Do this properly later
if [ -z "$#" ]
	$1 = "0"
fi

if [[ "$isrtm" -eq "9" ]] || [[ "$isrtm" = "rtm9" ]] || [[ "$isrtm" = "RTM9" ]]
then
    echo "Validating RTM9"
    if [ -z "$#" ] ## empty, generate LUT
    then
        sh validateHelper8.sh rtm9
        
        # delete old information including LUT, but this script should run fast
        # enough to delete LUT directory before new LUT is generated and written
        # to /var/calibration-data/ so it is still deleting old information
        ./cleanSDCard.sh
    elif [ "$1" = "nolut" ] ## nolut, do not delete LUT
    then
        sh validateHelper8.sh rtm9 nolut
        ./cleanSDCard.sh nolut
    else # any other than nolut, generate lut
        sh validateHelper8.sh rtm9
       ./cleanSDCard.sh
    fi
elif [[ "$isrtm" -eq "8" ]] || [[ "$isrtm" = "rtm8" ]] || [[ "$isrtm" = "RTM8" ]]
then
    echo "Validating RTM8"
    if [ -z "$1" ]
    then
        sh validateHelper8.sh rtm8
        ./cleanSDCard.sh
    elif [ "$1" = "nolut" ]
    then
        sh validateHelper8.sh rtm8 nolut
        ./cleanSDCard.sh nolut
    else
        sh validateHelper8.sh rtm8
       ./cleanSDCard.sh
    fi
elif [[ "$isrtm" -eq "7" ]] || [[ "$isrtm" = "rtm7" ]] || [[ "$isrtm" = "RTM7" ]]
then
    echo "Validating RTM7"
    if [ -z "$1" ]
    then
        sh validateRTM5.sh rtm6
        ./cleanSDCard.sh
    elif [ "$1" = "nolut" ]
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
    elif [ "$1" = "nolut" ]
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
    elif [ "$1" = "nolut" ]
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

