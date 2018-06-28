#We need to:
#Clear /home/dev0 directory
#Clear /home/root directory
#Remove history   /var/crimson/history
#Remove LUT lookup table /var/crimson/calibration-data
#clean fpga partition

 if [ -z "$1" ]
then
    ssh root@192.168.10.2  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no '\
        rm -rf /home/dev0/*; \
        rm -rf /home/root/*; \
        rm -rf /var/crimson/history; \
        rm -rf /var/crimson/calibration-data; \
        rm -rf /var/log/journal/*
        sync
        exit\
        '
elif [ "$1" = "nolut" ]
then
    ssh root@192.168.10.2  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no '\
        rm -rf /home/dev0/*; \
        rm -rf /home/root/*; \
        rm -rf /var/crimson/history; \
        rm -rf /var/log/journal/*
        sync
        exit\
        '
else
    ssh root@192.168.10.2  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no '\
        rm -rf /home/dev0/*; \
        rm -rf /home/root/*; \
        rm -rf /var/crimson/history; \
        rm -rf /var/crimson/calibration-data; \
        rm -rf /var/log/journal/*
        sync
        exit\
        '
fi
