#update repository
git pull origin ops/val/master

echo "rtm4 or rtm5?: (5,4)"
read isrtm5
if [[ -z "${isrtm5// }" ]] || [[ "$isrtm5" = "5" ]] || [[ "$isFlash" = "rtm5" ]] || [[ "$isFlash" = "RTM5" ]]
then
    sh validateRTM5.sh
elif [[ "$isFlash" = "4" ]] || [[ "$isFlash" = "rtm4" ]] || [[ "$isFlash" = "RTM4" ]]
then
    sh validateRTM4.sh
fi
done
