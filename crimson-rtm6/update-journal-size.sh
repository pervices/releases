echo "Updating journal log size"
sed -i 's/#Storage=auto/Storage=volatile/g'  /etc/systemd/journald.conf 
sed -i 's/Storage=auto/Storage=volatile/g' /etc/systemd/journald.conf
sed -i 's/#RuntimeMaxUse=/RuntimeMaxUse=100M/g' /etc/systemd/journald.conf 
sed -i 's/#RuntimeKeepFree=/RuntimeKeepFree=150M/g' /etc/systemd/journald.conf 
sed -i 's/#RuntimeMaxFileSize=/RuntimeMaxFileSize=30M/g' /etc/systemd/journald.conf 
