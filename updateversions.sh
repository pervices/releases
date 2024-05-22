#!/bin/bash

#Saner and safer environment
set -Eeuo pipefail
set -o pipefail -o noclobber -o nounset

debug=y

# #Set flags
# # -e : Exit immediately on command failure
# # -o pipefail : propagate exit codes on pipes to right most.
# # -u : treat unset variables as an error
# # -x : print each command prior to executing it.
# # -E : ensure that errors are caught and cleaned up.

function print_help() {
    echo "$0 -[f|s|m|w|e] REVISION"
    echo " Version Update Helper"
    echo " -----------------------------------------------------------------------------------------------"
    echo "     -h       | --help              | Print this help."
    echo "     -f       | --fpga              | FPGA"
    echo "     -s       | --server            | server"
    echo "              | --firmware          | firmware"
    echo "     -m       | --mcu               | mcu"
    echo "     -w       | --website           | website"
    echo "     -e       | --meta              | metapervices"
}

#####
# Pretty Terminal
#####
bold=$(tput -T xterm-256color bold)
normal=$(tput -T xterm-256color sgr0)

##############################################
# Parse the CmdLine arguments
##############################################
# saner programming env: these switches turn some bugs into errors
set -o pipefail -o noclobber -o nounset

! getopt --test > /dev/null
if [[ ${PIPESTATUS[0]} -ne 4 ]]; then
    echo "I’m sorry, `getopt --test` failed in this environment."
    exit 1
fi

OPTIONS=fsmweh
LONGOPTS=fpga:,server:,firmware:,mcu:,website:,meta:

# -use ! and PIPESTATUS to get exit code with errexit set
# -temporarily store output to be able to check for errors
# -activate quoting/enhanced mode (e.g. by writing out “--options”)
# -pass arguments only via   -- "$@"   to separate them correctly
! PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTS --name "$0" -- "$@")
if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
    # e.g. return value is 1
    #  then getopt has complained about wrong arguments to stdout
    exit 2
fi
# read getopt’s output this way to handle the quoting right:
eval set -- "$PARSED"

help=n
fpga=n
fpga_rev=0
server=n
server_rev=0
mcu=n
mcu_rev=0
website=n
website_rev=0
meta=n
meta_rev=0

# now enjoy the options in order and nicely split until we see --
while true; do
    case "$1" in
        -f|--fpga)
            fpga=y
            fpga_rev="$2"
            shift 2
            ;;
        -s|--server|--firmware)
            server=y
            server_rev="$2"
            shift 2
            ;;
        -m|--mcu)
            mcu=y
            mcu_rev="$2"
            shift 2
            ;;
        -w|--website)
            website=y
            website_rev="$2"
            shift 2
            ;;
        -e|--meta)
            meta=y
            meta_rev="$2"
            shift 2
            ;;
        -h|--help)
            print_help
            exit
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "${bold}ERROR: Invalid option.${normal}"
            echo ""
            print_help
            exit 3
            ;;
    esac
done

###DEBUGvvv
echo fpga: $fpga $fpga_rev
echo server: $server $server_rev
echo mcu: $mcu $mcu_rev
echo meta: $meta $meta_rev
echo website: $website $website_rev

if [ $debug == y ]; then
    if [ $fpga == y ]; then
        echo "INFO: Apply FPGA $fpga_rev"
    fi
    if [ $server == y ]; then
        echo "INFO: Apply FIRMWARE $server_rev"
    fi
    if [ $mcu == y ]; then
        echo "INFO: Apply MCU $mcu_rev"
    fi
    if [ $meta == y ]; then
        echo "INFO: Apply META $meta_rev"
    fi
    if [ $website == y ]; then
        echo "INFO: Apply WEBSITE $website_rev"
    fi
fi


for dir in crimson-rtm*; do

    if [ $dir == crimson-rtm4 ]; then
        echo "INFO: Skipping $dir"
        continue
    fi
    if [ $dir == crimson-rtm5 ]; then
        echo "INFO: Skipping $dir"
        continue
    fi

    if [ $fpga == y ]; then
        sed -i "s/FPGA.*/FPGA $fpga_rev/g" $dir/versions
    fi

    if [ $server == y ]; then
        sed -i "s/FIRMWARE.*/FIRMWARE $server_rev/g" $dir/versions
    fi

    if [ $mcu == y ]; then
        sed -i "s/MCU.*/MCU $mcu_rev/g" $dir/versions
    fi

    if [ $meta == y ]; then
        sed -i "s/META.*/META $meta_rev/g" $dir/versions
    fi

    if [ $website == y ]; then
        sed -i "s/WEBSITE.*/WEBSITE $website_rev/g" $dir/versions
    fi

done
