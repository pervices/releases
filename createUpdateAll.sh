#!/bin/bash

#This is a wrapper to quickly generate all the updates;
rm updateCrimsonRtm10-325msps updateCrimsonRtm4-325msps updateCrimsonRtm5-325msps updateCrimsonRtm6-325msps updateCrimsonRtm7-325msps updateCrimsonRtm8-325msps updateCrimsonRtm9-325msps
./createUpdate.sh crimson-rtm6-325msps/ updateCrimsonRtm6-325msps && \
./createUpdate.sh crimson-rtm7-325msps/ updateCrimsonRtm7-325msps && \
./createUpdate.sh crimson-rtm8-325msps/ updateCrimsonRtm8-325msps && \
./createUpdate.sh crimson-rtm9-325msps/ updateCrimsonRtm9-325msps && \
./createUpdate.sh crimson-rtm10-325msps/ updateCrimsonRtm10-325msps
