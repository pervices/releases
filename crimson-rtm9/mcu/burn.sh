#!/bin/bash

function help_summary {
    echo -e "Usage : $0 [b(ootlader)|a(pplication)|c(complete)] [rx | tx | time] [rtm4 | rtm5 | rtm6 | rtm8 | tate ]\n"
    echo -e "Examples:"
    echo -e "\t Flash RTM4 Tx bootloader code:"
    echo -e "\t\t $0 b tx rtm4\n"
    echo -e "\t Flash RTM5 Rx application code:"
    echo -e "\t\t $0 a rx rtm5\n"
    echo -e "\t Flash RTM6 Time bootloader and application code:"
    echo -e "\t\t $0 c time rtm6\n"
    exit
}

PATH_TIME="/dev/ttycrimson-time"
PATH_RX="/dev/ttycrimson-rx"
PATH_TX="/dev/ttycrimson-tx"

HEXFILE_TIME_APP="/dev/null"
HEXFILE_TIME_BOOT="/dev/null "
HEXFILE_RX_APP="/dev/null"
HEXFILE_RX_BOOT="/dev/null"
HEXFILE_TX_APP="/dev/null"
HEXFILE_TX_BOOT="/dev/null"

AVRDUDE_BIN="sudo avrdude"
AVRDUDE_ARGS="-p atxmega256a3 -P usb -c avrispmkII -B 8 -b 115200"

# Set fuse5 to 0xED when prototyping to set a minimal Brown Out Detection Level
# Fuse4 disables jtag and MUST be programmed first, twice (the first time
# doesn't verify properly), and BEFORE anything else happens, especially the
# first time we bring up boards.
AVRDUDE_FUSES="-U fuse4:w:0xF3:m -U fuse4:w:0xF3:m -U fuse2:w:0xBE:m  -U fuse5:w:0xEA:m"
AVRDUDE_FUSE_REV="-U fuse0:w:0xff:m" #Default Fuse to indicate unprogrammed.

# Fuse2: BoD Settings;
# bit 6 |  0: Reset vector = boot loader, 1: application reset
# bit 1,0 | BoD operation in PowerDown Mode; 01; sample mode, 10: continuously, 11: BoD disabled

# Fuse4:
# Bit4 |External Reset Disable | 0: disable external resets, 1: allow external resets
# bit 3,2 |  Start-up time delay | 00: 64 1kHz ULP osc cycles, 01: 4 1kHz osc cyles, 10 Reserved, 11: 0
# bit 0 | 1: Disable JTAG, 0: Enable JTAG 

# Fuse 5:
# bit 5,4 | BoD operation in Active Mode | 00: reservered, 01: BoD Sample Mode, 10: Continuous, 11, BOD Disabled
# bit 3 | 0: do not erase EEPROM during chip erase.
# bit 2,1,0 | 111 = 1.6V, 101=2.1, 011=2.6, 010=2.9, 001=3.2

# Common Programming Sequence
# program_app( $PATH_TO_DEVICE $NAME_OF_HEXFILE)
function burn_seq() {
        BOARD_OP="$1"
        BOARD_HEX_BOOT="$2"
        BOARD_HEX_APP="$3"
# Fuses MUST be programmed first, prior to bring up, to avoid incorrect JTAG
# bits from preventing the board from booting.
		echo -e "Start fuse programming."
		$AVRDUDE_BIN $AVRDUDE_ARGS $AVRDUDE_FUSES $AVRDUDE_FUSE_REV
		echo -e "Repeat fuse programming as precaution in case first time failed."
		$AVRDUDE_BIN $AVRDUDE_ARGS $AVRDUDE_FUSES $AVRDUDE_FUSE_REV
		
        if [[ "$BOARD_OP" = "b" ]] || [[ "$BOARD_OP" = "c" ]];
        then
            RESPONSE=""
            echo -e "Start bootloader programming using $BOARD_HEX_BOOT"
            #NOTE: The '-e' argument to avrdude performs a chip erase that erases the bootload and application code.
            echo $AVRDUDE_BIN $AVRDUDE_ARGS -e $AVRDUDE_FUSES $AVRDUDE_FUSE_REV -U boot:w:$BOARD_HEX_BOOT
            $AVRDUDE_BIN $AVRDUDE_ARGS -e $AVRDUDE_FUSES $AVRDUDE_FUSE_REV -U boot:w:$BOARD_HEX_BOOT
            echo "Completed bootloader programming using $BOARD_HEX_BOOT"
            RESPONSE="marker"
        fi

        if [[ "$BOARD_OP" = "a" ]] || [[ "$BOARD_OP" = "c" ]];
        then
            RESPONSE=""
            echo -e "Start application programming using $BOARD_HEX_APP"
            echo $AVRDUDE_BIN $AVRDUDE_ARGS $AVRDUDE_FUSES -U application:w:$BOARD_HEX_APP
            $AVRDUDE_BIN $AVRDUDE_ARGS $AVRDUDE_FUSES -U application:w:$BOARD_HEX_APP
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
if [ $# -lt 3 ] || [ $# -gt 3 ]; 
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


if [ "$3" != 'rtm4' ] && [ "$3" != 'rtm5' ] && [ "$3" != 'rtm6' ] && [ "$3" != 'rtm8' ]&& [ "$3" != 'tate' ]
then
    help_summary
    return 1
fi

if [ "$3" == 'rtm4' ]
then
    AVRDUDE_FUSE_REV="-U fuse0:w:0x04:m"
    HEXFILE_TIME_APP="synth.hex"
    HEXFILE_TIME_BOOT="SYNTH-xboot-boot.hex "
    HEXFILE_RX_APP="rx.hex"
    HEXFILE_RX_BOOT="RX-xboot-boot.hex"
    HEXFILE_TX_APP="tx.hex"
    HEXFILE_TX_BOOT="TX-xboot-boot.hex"
fi

if [ "$3" == 'rtm5' ]
then
    AVRDUDE_FUSE_REV="-U fuse0:w:0x05:m"
    HEXFILE_TIME_APP="vaunt-synth.hex"
    HEXFILE_TIME_BOOT="VAUNT_SYNTH-xboot-boot.hex "
    HEXFILE_RX_APP="vaunt-rx.hex"
    HEXFILE_RX_BOOT="VAUNT_RX-xboot-boot.hex"
    HEXFILE_TX_APP="vaunt-tx.hex"
    HEXFILE_TX_BOOT="VAUNT_TX-xboot-boot.hex"
fi

if [ "$3" == 'rtm6' ]
then
    AVRDUDE_FUSE_REV="-U fuse0:w:0x06:m"
    HEXFILE_TIME_APP="vaunt-synth.hex"
    HEXFILE_TIME_BOOT="VAUNT_SYNTH-xboot-boot.hex "
    HEXFILE_RX_APP="vaunt-rx.hex"
    HEXFILE_RX_BOOT="VAUNT_RX-xboot-boot.hex"
    HEXFILE_TX_APP="vaunt-tx.hex"
    HEXFILE_TX_BOOT="VAUNT_TX-xboot-boot.hex"
fi

if [ "$3" == 'rtm8' ]
then
    AVRDUDE_FUSE_REV="-U fuse0:w:0x08:m"
    HEXFILE_TIME_APP="vaunt-synth.hex"
    HEXFILE_TIME_BOOT="VAUNT_SYNTH-xboot-boot.hex "
    HEXFILE_RX_APP="vaunt-rx.hex"
    HEXFILE_RX_BOOT="VAUNT_RX-xboot-boot.hex"
    HEXFILE_TX_APP="vaunt-tx.hex"
    HEXFILE_TX_BOOT="VAUNT_TX-xboot-boot.hex"
fi

if [ "$3" == 'tate' ]
then
    AVRDUDE_FUSE_REV="-U fuse0:w:0x99:m"
    HEXFILE_TIME_APP="tate-synth.hex"
    HEXFILE_TIME_BOOT="TATE_SYNTH-xboot-boot.hex "
    HEXFILE_RX_APP="tate-rx.hex"
    HEXFILE_RX_BOOT="TATE_RX-xboot-boot.hex"
    HEXFILE_TX_APP="tate-tx.hex"
    HEXFILE_TX_BOOT="TATE_TX-xboot-boot.hex"
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
