echo "Updating journal log size"
rm /etc/systemd/journald.conf
cp journald.conf /etc/systemd
