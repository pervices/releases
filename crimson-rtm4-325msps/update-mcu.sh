echo "Updating mcus"
systemctl stop crimson-website; 
systemctl stop crimson-server; 
systemctl mask crimson-website; 
systemctl mask crimson-server; 
thisDir=$(pwd)
rm /lib/mcu/*
cp mcu/* /lib/mcu/; 
cd /lib/mcu;
SOURCE_PATH="/dev/ttyUSB3"
SYMLINK_PATH="/dev/ttycrimson-gpio"
if [[ -L "$SYMLINK_PATH" ]]; then
    echo "Symbolic link '$SYMLINK_PATH' exists."
else
    echo "Symbolic link '$SYMLINK_PATH' does not exist. Creating symlink"
    ln -s  "$SOURCE_PATH" "$SYMLINK_PATH"
    echo "Symbolic link created: $SYMLINK_PATH -> $SOURCE_PATH"
fi
flash w time crimson & PIDTIMEBOARD=$!
flash w rx crimson & PIDRXBOARD=$!
flash w tx crimson & PIDTXBOARD=$!
wait $PIDTIMEBOARD
wait $PIDRXBOARD  
wait $PIDTXBOARD  
echo "Waiting for MCUs to boot"
sleep 15;
systemctl unmask crimson-server; 
systemctl unmask crimson-website; 
systemctl start crimson-server; 
systemctl start crimson-website; 
cd $thisDir

