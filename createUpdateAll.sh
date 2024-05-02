#!/bin/bash

#This is a wrapper to quickly generate all the updates;
rm updateCrimsonRtm10 updateCrimsonRtm4 updateCrimsonRtm5 updateCrimsonRtm6 updateCrimsonRtm7 updateCrimsonRtm8 updateCrimsonRtm9
./createUpdate.sh crimson-rtm6/ updateCrimsonRtm6 && \
./createUpdate.sh crimson-rtm7/ updateCrimsonRtm7 && \
./createUpdate.sh crimson-rtm8/ updateCrimsonRtm8 && \
./createUpdate.sh crimson-rtm9/ updateCrimsonRtm9 && \
./createUpdate.sh crimson-rtm10/ updateCrimsonRtm10
