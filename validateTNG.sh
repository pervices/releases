#update repository
git pull origin ops/val/master

#remove host ssh
sed -i '/192.168.10.2/d' ~/.ssh/known_hosts

echo "rtm5 or rtm4?: (5,4)"
read isrtm5
if [[ "$isrtm5" -eq "5" ]] || [[ "$isrtm5" = "rtm5" ]] || [[ "$isrtm5" = "RTM5" ]]
then
    echo "Validating RTM5"
    sh validateRTM5.sh
elif [[ "$isrtm5" -eq  "4" ]] || [[ "$isrtm5" = "rtm4" ]] || [[ "$isrtm5" = "RTM4" ]]
then
    echo "Validating RTM4"
    sh validateRTM4.sh
else
    echo "No valit selection, please type '5,rtm5,RTM5' for validationg rtm5 OR '4,rtm4,RTM4' for rtm4"

fi

