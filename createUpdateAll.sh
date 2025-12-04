#!/bin/bash

#This is a wrapper to quickly generate all the updates;
rm updateCrimsonRtm*
./createUpdate.sh crimson-rtm6-325msps/ update-crimson-rtm6-325msps && \
./createUpdate.sh crimson-rtm7-325msps/ update-crimson-rtm7-325msps && \
./createUpdate.sh crimson-rtm8-325msps/ update-crimson-rtm8-325msps && \
./createUpdate.sh crimson-rtm9-325msps/ update-crimson-rtm9-325msps && \
./createUpdate.sh crimson-rtm10-325msps/ update-crimson-rtm10-325msps && \
./createUpdate.sh crimson-rtm10-300msps/ update-crimson-rtm10-300msps && \
./createUpdate.sh crimson-rtm12-325msps/ update-crimson-rtm12-325msps && \
./createUpdate.sh crimson-rtm12-300msps/ update-crimson-rtm12-300msps && \
./createUpdate.sh crimson-rtm15-325msps/ update-crimson-rtm15-325msps && \
./createUpdate.sh crimson-rtm15-300msps/ update-crimson-rtm15-300msps
