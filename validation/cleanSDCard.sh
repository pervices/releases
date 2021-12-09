#We need to:
#Clear /home/dev0 directory
#Clear /home/root directory
#Remove history   /var/crimson/history
#Remove LUT lookup table /var/crimson/calibration-data
#clean fpga partition

 if [ -z "$1" ]
then
    sshpass -p "dev0" ssh -tq dev0@192.168.10.2  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no '\
        echo dev0 | sudo -S rm -rf /home/dev0/*; \
        sudo rm -rf /home/root/*; \
        sudo rm -rf /var/crimson/history; \
        sudo rm -rf /var/calibration-data; \
        sudo mkdir /var/calibration-data; \
        sudo rm -rf /var/log/journal/*
        sudo sync
        exit\
        ' > /dev/null
elif [ "$1" = "nolut" ]
then
    sshpass -p "dev0" ssh -tq dev0@192.168.10.2  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no '\
        echo dev0 | sudo -S rm -rf /home/dev0/*; \
        sudo rm -rf /home/root/*; \
        sudo rm -rf /var/crimson/history; \
        sudo rm -rf /var/log/journal/*
        sudo sync
        exit\
        ' > /dev/null
else
    sshpass -p "dev0" ssh -tq dev0@192.168.10.2  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no '\
        echo dev0 | sudo -S rm -rf /home/dev0/*; \
        sudo rm -rf /home/root/*; \
        sudo rm -rf /var/crimson/history; \
        sudo rm -rf /var/calibration-data; \
        sudo mkdir /var/calibration-data; \
        sudo rm -rf /var/log/journal/*
        sudo sync
        exit\
        ' > /dev/null
fi
