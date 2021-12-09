#We need to:
#Clear /home/dev0 directory
#Clear /home/root directory
#Remove history   /var/crimson/history
#Remove LUT lookup table /var/crimson/calibration-data
#clean fpga partition

 if [ -z "$1" ]
then
    sshpass -p "dev0" ssh -t dev0@192.168.10.2  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no '\
        echo dev0 | sudo -S rm -rf /home/dev0/*; \
        sudo rm -rf /home/root/*; \
        sudo rm -rf /var/crimson/history; \
        sudo rm -rf /var/crimson/calibration-data; \
        sudo rm -rf /var/log/journal/*
        sudo sync
        exit\
        '
elif [ "$1" = "nolut" ]
then
    sshpass -p "dev0" ssh -t dev0@192.168.10.2  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no '\
        echo dev0 | sudo -S rm -rf /home/dev0/*; \
        sudo rm -rf /home/root/*; \
        sudo rm -rf /var/crimson/history; \
        sudo rm -rf /var/log/journal/*
        sudo sync
        exit\
        '
else
    sshpass -p "dev0" ssh -t dev0@192.168.10.2  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no '\
        echo dev0 | sudo -S rm -rf /home/dev0/*; \
        sudo rm -rf /home/root/*; \
        sudo rm -rf /var/crimson/history; \
        sudo rm -rf /var/crimson/calibration-data; \
        sudo rm -rf /var/log/journal/*
        sudo sync
        exit\
        '
fi
