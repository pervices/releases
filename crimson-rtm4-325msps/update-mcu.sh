echo "Updating mcus"
systemctl stop crimson-website; 
systemctl stop crimson-server; 
systemctl mask crimson-website; 
systemctl mask crimson-server; 
thisDir=$(pwd)
cp mcu/* /lib/mcu/; 
cd /lib/mcu;
./flash w time & PIDTIMEBOARD=$!
./flash w rx & PIDRXBOARD=$!
./flash w tx & PIDTXBOARD=$!
wait $PIDTIMEBOARD
wait $PIDRXBOARD  
wait $PIDTXBOARD  
systemctl unmask crimson-server; 
systemctl unmask crimson-website; 
systemctl start crimson-server; 
systemctl start crimson-website; 
cd $thisDir

