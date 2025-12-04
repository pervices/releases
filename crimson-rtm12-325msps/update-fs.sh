#!/bin/bash

echo Updating File System

# avoid warning about updating the service if it not actually changed
if diff fs/lib/systemd/system/crimson-server.service /lib/systemd/system/crimson-server.service > /dev/null;
then
    # the files match so no need to copy it over, remove it from the update directory
    echo server.service already up to date
    rm fs/lib/systemd/system/crimson-server.service
fi

cp -R fs/* /

# if any systemd files changed, we need to reload
systemctl daemon-reload

# need to install the flash utility from the firmware repo before we try to flash the MCU
cp firmware/flash /usr/bin/
