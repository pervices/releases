#!/bin/bash

function help_summary {
    echo -e "Usage : $0 [b(ootlader)|a(pplication)|c(complete)] [rx | tx | time] \n"
    echo -e "Examples:"
    echo -e "\t Flash Tx bootloader code:"
    echo -e "\t\t $0 b tx\n"
    echo -e "\t Flash Rx application code:"
    echo -e "\t\t $0 a rx\n"
    echo -e "\t Flash Time bootloader and application code:"
    echo -e "\t\t $0 c time\n"
    exit
}

PATH_TIME="/dev/ttycrimson-time"
PATH_RX="/dev/ttycrimson-rx"
PATH_TX="/dev/ttycrimson-tx"

HEXFILE_TIME_APP="synth.hex"
HEXFILE_TIME_BOOT="SYNTH-xboot-boot.hex "
HEXFILE_RX_APP="rx.hex"
HEXFILE_RX_BOOT="RX-xboot-boot.hex"
HEXFILE_TX_APP="tx.hex"
HEXFILE_TX_BOOT="TX-xboot-boot.hex"

AVRDUDE_BIN="avrdude"
AVRDUDE_ARGS="-p atxmega256a3 -P usb -c avrispmkII -B 8 -b 115200"
AVRDUDE_FUSES="-U fuse2:w:0xBE:m  -U fuse4:w:0xF3:m -U fuse5:w:0xE9:m"

# Common Programming Sequence
# program_app( $PATH_TO_DEVICE $NAME_OF_HEXFILE)
function burn_seq() {
        BOARD_OP="$1"
        BOARD_HEX_BOOT="$2"
        BOARD_HEX_APP="$3"

        if [[ "$BOARD_OP" = "b" ]] || [[ "$BOARD_OP" = "c" ]];
        then
            RESPONSE=""
            echo -e "Start bootloader programming using $BOARD_HEX_BOOT"
            echo $AVRDUDE_BIN $AVRDUDE_ARGS -e -U boot:w:$BOARD_HEX_BOOT $AVRDUDE_FUSES
            $AVRDUDE_BIN $AVRDUDE_ARGS -e -U boot:w:$BOARD_HEX_BOOT $AVRDUDE_FUSES
            echo "Completed bootloader programming using $BOARD_HEX_BOOT"
            RESPONSE="marker"
        fi

        if [[ "$BOARD_OP" = "a" ]] || [[ "$BOARD_OP" = "c" ]];
        then
            RESPONSE=""
            echo -e "Start application programming using $BOARD_HEX_APP"
            echo $AVRDUDE_BIN $AVRDUDE_ARGS -U application:w:$BOARD_HEX_APP $AVRDUDE_FUSES
            $AVRDUDE_BIN $AVRDUDE_ARGS -U application:w:$BOARD_HEX_APP $AVRDUDE_FUSES
            echo "Completed application programming using $BOARD_HEX_APP"
            RESPONSE="marker"
        fi

        if [[ "$RESPONSE" != 'marker' ]];
        then
                echo -e "ERROR: Failed to program board using $BOARD_HEX_BOOT and $BOARD_HEX_APP\n"
                return 1
        else 
            RESPONSE=""
        fi

        #For safety, redefine the PATH and HEX files to null.
        PATH_DEV="/dev/null"
        BOARD_HEX="/dev/null"
        BOARD_OP="null"
}

# Check number of arguaments
if [ $# -lt 2 ] || [ $# -gt 2 ]; 
then
    help_summary
    return 1
fi

if [ "$1" != 'b' ] && [ "$1" != 'a' ] && [ "$1" != 'c' ]
then
    help_summary
    return 1
fi

if [ "$2" != 'time' ] && [ "$2" != 'tx' ] && [ "$2" != 'rx' ] && [ "$2" != 'all' ]
then
    help_summary
    return 1
fi

BOARD_OPERATON="$1"

if [ "$2" = 'time' ] || [ "$2" = 'all' ]
then
	echo "Ready to program Time board. Press the any key to continue."
	read
        burn_seq "$BOARD_OPERATON" "$HEXFILE_TIME_BOOT" "$HEXFILE_TIME_APP"
	echo "-- Finished programming the synth board --"
fi

if [ "$2" = 'rx' ] || [ "$2" = 'all' ]
then
	echo "Ready to program Rx board. Press the any key to continue."
	read
        burn_seq "$BOARD_OPERATON" "$HEXFILE_RX_BOOT" "$HEXFILE_RX_APP"
	echo "-- Finished programming the Rx board --"
fi

if [ "$2" = 'tx' ] || [ "$2" = 'all' ]
then
	echo "Ready to program Tx board. Press the any key to continue."
	read
        burn_seq "$BOARD_OPERATON" "$HEXFILE_TX_BOOT" "$HEXFILE_TX_APP"
	echo "-- Finished programming the Tx board --"
fi

exit
