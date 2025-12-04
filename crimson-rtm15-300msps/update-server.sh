echo "Updating server binary"
systemctl stop crimson-server; cp firmware/* /usr/bin/;

if [ -z "$1" ]; then
echo restarting services
systemctl start crimson-server
fi
