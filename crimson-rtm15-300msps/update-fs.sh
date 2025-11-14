#!/bin/bash

cp -R fs/* /

# need to install the flash utility from the firmware repo before we try to flash the MCU
cp firmware/flash /usr/bin/
