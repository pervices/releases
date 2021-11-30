 calDir="/var/crimson/calibration-data"
 echo "Calibration table script"
 
 #Disable lut 
 echo 0 > /var/volatile/crimson/state/rx_a/rf/freq/lut_en
 echo 0 > /var/volatile/crimson/state/rx_b/rf/freq/lut_en
 echo 0 > /var/volatile/crimson/state/rx_c/rf/freq/lut_en
 echo 0 > /var/volatile/crimson/state/rx_d/rf/freq/lut_en
 echo 0 > /var/volatile/crimson/state/tx_a/rf/freq/lut_en
 echo 0 > /var/volatile/crimson/state/tx_b/rf/freq/lut_en
 echo 0 > /var/volatile/crimson/state/tx_c/rf/freq/lut_en
 echo 0 > /var/volatile/crimson/state/tx_d/rf/freq/lut_en
 
 #Delete calibration table if it exists
 echo "Deleting existing table"
 calDir="/var/crimson/calibration-data"
if [ -d "$calDir" ]; then
  rm -rf $calDir
fi

#Create table
 echo "Creating ADF cal look up table"
 echo "This can take some time (30-60mins)"
 
 echo 1 > /var/volatile/crimson/state/rx_a/rf/freq/lut_en
 echo "Calibration table is generated when the bottom status LED stops blinking"
