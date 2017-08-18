#!/bin/bash

function help_summary {
    echo -e "Usage : $0 [w(rite)|v(erify)] [rx | tx | time | all] \n"
    echo -e "Example:"
    echo -e "\t Verify tx board mcu code:"
    echo -e "\t\t $0 v tx\n"
    echo -e "\t Write MCU to all boards:"
    echo -e "\t\t $0 w all\n"
    exit
}

PATH_TIME="/dev/ttycrimson-time"
PATH_RX="/dev/ttycrimson-rx"
PATH_TX="/dev/ttycrimson-tx"

HEXFILE_TIME="/lib/mcu/synth.hex"
HEXFILE_RX="/lib/mcu/rx.hex"
HEXFILE_TX="/lib/mcu/tx.hex"

AVRDUDE_BIN="avrdude"
AVRDUDE_ARGS="-c avr109 -B 8 -p x256a3u -b 115200"

#Note: The current programmer does not support fuses in this mode.
#This line is here only for reference.
AVRDUDE_FUSES="-U fuse2:w:0xBE:m  -U fuse4:w:0xF3:m -U fuse5:w:0xE9:m"

#Bootloader specific functions
BOOTLOADER_LOAD_PATTERN="BOOT"
BOOTLOADER_ENTRY_SEQUENCE="abcdefghijklmnopqrstuvwxyz\r"
#Approximately three times the default watchdog timeout value.
BOOTLOADER_TIMEOUT="19"

#Check permissions to confirm running as root.
CHECKPERM=$(whoami)

# Prep functions to be carried out prior to programming.
function start_prep {
    if [ ! -f /etc/crimson/crimson-mcu ];
    then
            echo -e "WARNING: Unable to determine version."
    else
            version=$(tail -1 /etc/crimson/crimson-mcu | cut -d '-' -f2)
    fi
    if [ ! -c $PATH_TIME ] || [ ! -c $PATH_RX ] || [ ! -c $PATH_TX ]; 
    then
            echo -e "ERROR: Unable to locate crimson ttys."
            exit
    fi

    echo -e "Attempting to disabling crimson-server and crimson-website."
    sudo systemctl stop crimson-server.service
    sudo systemctl stop crimson-website.service
}

# Clean up functions to be executed at the conclusion of programming.
function end_prep {
    echo -e "Attempting to restart crimson-server and crimson-website."
    sudo systemctl start crimson-server.service
    sudo systemctl start crimson-website.service
}

# Enable FPGA programming pin.
function fpga_progpin_enable {
    echo -e "Enable FPGA driven MCU programing pin."
    fpgareg=$(mem rr res_rw3)
    mem rw res_rw3 0 0x1000
}

# Disable FPGA programming pin.
function fpga_progpin_disable {
    echo -e "Disable FPGA driven MCU programing pin."
    mem rw res_rw3 $fpgareg 0xffffffff
}

# Common Programming Sequence
# program_app( $PATH_TO_DEVICE $NAME_OF_HEXFILE)
function program_app() {
        PATH_DEV="$1"
        BOARD_HEX="$2"
        BOARD_OP="$3"

        fpga_progpin_enable;

	#Attempt to exit bootloader, in case we're in it.
	timeout 0.3 echo -e "E\r" > $PATH_DEV

        #Clear buffer
        timeout 0.3 cat $PATH_DEV > /dev/null 

        #Get current time dangerously
        #There needs to be a better method to doing this then
        #using the system time, which is mutable.
        EXIT_TIME=$(( $(date +%s) + $BOOTLOADER_TIMEOUT ))

        echo -e "Using $BOARD_HEX to program $PATH_DEV\n"

        #Restart MCU
        echo -e "Issuing reboot command and polling for bootloader reply to $PATH_DEV..."
        echo -e "boot -e\r" > $PATH_DEV

        #For the next 10s poll the char device and wait for the boot message.
        while [[ $(( $(date +%s) )) -le $(($EXIT_TIME)) ]];
        do
                RESPONSE=$(cat $PATH_DEV)
                echo $RESPONSE
                if [[ "$RESPONSE" = *$BOOTLOADER_LOAD_PATTERN* ]];
                then
                	if [[ "$BOARD_OP" = "w" ]];
                	then
                            echo -e "Start Programming using $BOARD_HEX"
                            echo -e "$BOOTLOADER_ENTRY_SEQUENCE" > $PATH_DEV
                            echo $AVRDUDE_BIN $AVRDUDE_ARGS -P $PATH_DEV -e -U flash:$BOARD_OP:$BOARD_HEX
                            $AVRDUDE_BIN $AVRDUDE_ARGS -P $PATH_DEV -e -U flash:$BOARD_OP:$BOARD_HEX
                            echo "Completed Verifying $PATH_DEV using $BOARD_HEX"
                            RESPONSE="marker"
                        elif [[ "$BOARD_OP" = "v" ]];
                        then
                            echo -e "Start Programming using $BOARD_HEX"
                            echo -e "$BOOTLOADER_ENTRY_SEQUENCE" > $PATH_DEV
                            echo $AVRDUDE_BIN $AVRDUDE_ARGS -P $PATH_DEV -U flash:$BOARD_OP:$BOARD_HEX
                            $AVRDUDE_BIN $AVRDUDE_ARGS -P $PATH_DEV -U flash:$BOARD_OP:$BOARD_HEX
                            echo "Completed Programming $PATH_DEV using $BOARD_HEX"
                            RESPONSE="marker"
                        else 
                            echo -e "ERROR: Invalid Operation specified: $BOARD_OP "
                        fi
                        echo -e "exit\r" > $PATH_DEV
                        echo "[$(date -Ins)] FLASH.SH: Installed  installed-${version}-$BOARD_HEX" >> /etc/crimson/crimson-mcu
                        fpga_progpin_disable
                        break
                fi
        done

        #For safety, redefine the PATH and HEX files to null.
        PATH_DEV="/dev/null"
        BOARD_HEX="/dev/null"

        if [[ "$RESPONSE" != 'marker' ]];
        then
                echo -e "ERROR: Failed to program $PATH_DEV using $BOARD_HEX\n"
                return 1
        else 
            RESPONSE=""
        fi

}

# Check if root.
if [ "$CHECKPERM" != 'root' ];
then
    echo -e "[$(date -Ins)] $0 ERROR: $0 must be run with root permissions, or using:"
    echo -e "\t sudo $0";
    exit 1
fi


# Check number of arguaments
if [ $# -lt 2 ] || [ $# -gt 2 ]; 
then
    help_summary
    exit 1
fi

if [ "$1" != 'w' ] && [ "$1" != 'v' ]
then
    help_summary
    exit 1
fi

if [ "$2" != 'time' ] && [ "$2" != 'tx' ] && [ "$2" != 'rx' ] && [ "$2" != 'all' ]
then
    help_summary
    return 1
fi

# All parameters are considered valid, to avoid contention issues, we need shut down
# the website and server.

# This function MUST preceed all other functions.
start_prep

BOARD_OPERATON="$1"


if [ "$2" = 'time' ] || [ "$2" = 'all' ]
then
        program_app "$PATH_TIME"  "$HEXFILE_TIME" "$BOARD_OPERATON"
fi

if [ "$2" = 'tx' ] || [ "$2" = 'all' ]
then
        program_app "$PATH_TX"  "$HEXFILE_TX" "$BOARD_OPERATON"
fi


if [ "$2" = 'rx' ] || [ "$2" = 'all' ]
then
        program_app "$PATH_RX"  "$HEXFILE_RX" "$BOARD_OPERATON"
fi
#
# This function MUST be the last thing called.
end_prep;

exit
