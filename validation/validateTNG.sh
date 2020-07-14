#update repository
git pull origin master

#remove host ssh
sed -i '/192.168.10.2/d' ~/.ssh/known_hosts

echo "rtm8, rtm7, rtm6, rtm5 or rtm4?: (8,7,6,5,4)"
read isrtm
if [[ "$isrtm" -eq "8" ]] || [[ "$isrtm" = "rtm8" ]] || [[ "$isrtm" = "RTM8" ]]
then
    echo "Validating RTM8"
    if [ -z "$1" ]
    then
        sh validateRTM5.sh rtm8
        ./cleanSDCard.sh nolut
    elif [ "$1" = "nolut" ]
    then
        sh validateRTM5.sh rtm8 nolut
        ./cleanSDCard.sh
    else
        sh validateRTM6.sh rtm8
       ./cleanSDCard.sh nolut
    fi
elif [[ "$isrtm" -eq "7" ]] || [[ "$isrtm" = "rtm7" ]] || [[ "$isrtm" = "RTM7" ]]
then
    echo "Validating RTM7"
    if [ -z "$1" ]
    then
        sh validateRTM5.sh rtm6
        ./cleanSDCard.sh nolut
    elif [ "$1" = "nolut" ]
    then
        sh validateRTM5.sh rtm6 nolut
        ./cleanSDCard.sh
    else
        sh validateRTM6.sh rtm6
       ./cleanSDCard.sh nolut
    fi
elif [[ "$isrtm" -eq "6" ]] || [[ "$isrtm" = "rtm6" ]] || [[ "$isrtm" = "RTM6" ]]
then
    echo "Validating RTM6"
    if [ -z "$1" ]
    then
        sh validateRTM5.sh rtm6
        ./cleanSDCard.sh nolut
    elif [ "$1" = "nolut" ]
    then
        sh validateRTM5.sh rtm6 nolut
        ./cleanSDCard.sh
    else
        sh validateRTM6.sh rtm6
       ./cleanSDCard.sh nolut
    fi
elif [[ "$isrtm" -eq "5" ]] || [[ "$isrtm" = "rtm5" ]] || [[ "$isrtm" = "RTM5" ]]
then
    echo "Validating RTM5"
    if [ -z "$1" ]
    then
        sh validateRTM5.sh rtm5
        ./cleanSDCard.sh nolut
    elif [ "$1" = "nolut" ]
    then
        sh validateRTM5.sh rtm5 nolut
        ./cleanSDCard.sh
    else
        sh validateRTM5.sh rtm5
       ./cleanSDCard.sh nolut
    fi
elif [[ "$isrtm" -eq  "4" ]] || [[ "$isrtm" = "rtm4" ]] || [[ "$isrtm" = "RTM4" ]]
then
    echo "Validating RTM4"
    sh validateRTM4.sh
    ./cleanSDCard.sh nolut
else
    echo "No valid selection, please type '5,rtm5,RTM5' for validationg rtm5 OR '4,rtm4,RTM4' for rtm4"

fi

