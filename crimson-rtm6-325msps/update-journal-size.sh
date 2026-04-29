echo "Updating journal log size"
sed -i 's/#Storage=volatile/Storage=persistent/g' /etc/systemd/journald.conf
sed -i 's/#Storage=persistent/Storage=persistent/g' /etc/systemd/journald.conf
sed -i 's/Storage=volatile/Storage=persistent/g' /etc/systemd/journald.conf
sed -i 's/Storage=persistent/Storage=persistent/g' /etc/systemd/journald.conf
sed -i 's/#SystemMaxUse=/SystemMaxUse=100M/g' /etc/systemd/journald.conf 
sed -i 's/#SystemKeepFree=/SystemKeepFree=150M/g' /etc/systemd/journald.conf 
sed -i 's/#SystemMaxFileSize=/SystemMaxFileSize=10M/g' /etc/systemd/journald.conf 
sed -i 's/#SystemMaxFiles=/SystemMaxFiles=10/g' /etc/systemd/journald.conf 