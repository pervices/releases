echo "Updating server binary"
systemctl stop crimson-server; cp firmware/* /usr/bin/;systemctl start crimson-server
