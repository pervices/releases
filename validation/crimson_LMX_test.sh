#!/bin/bash

echo "Run the Simple Ship Test. Set it to 'T5: 2.7GHz'. Press Enter when ready to continue."
read Next

ssh root@192.168.10.2 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "\
    echo 0 > /var/volatile/crimson/state/time/lmx/freq;\
    echo 1 > /var/volatile/crimson/state/tx/a/rf/freq/common_lo; \
    echo 1 > /var/volatile/crimson/state/tx/b/rf/freq/common_lo; \
    echo 1 > /var/volatile/crimson/state/tx/c/rf/freq/common_lo; \
    echo 1 > /var/volatile/crimson/state/tx/d/rf/freq/common_lo; \
    exit\
    " 
echo "TX Test 1: Check no peak above 0dB. Press Enter when ready to continue."
read Next

ssh root@192.168.10.2 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "\
    echo 2725000000 > /var/volatile/crimson/state/time/lmx/freq;\
    echo 1 > /var/volatile/crimson/state/tx/a/rf/freq/common_lo; \
    echo 1 > /var/volatile/crimson/state/tx/b/rf/freq/common_lo; \
    echo 1 > /var/volatile/crimson/state/tx/c/rf/freq/common_lo; \
    echo 1 > /var/volatile/crimson/state/tx/d/rf/freq/common_lo; \
    exit\
    " 
echo "TX Test 2: Check strong peak at 2.7GHz on all channels. Press Enter when ready to continue."
read Next

ssh root@192.168.10.2 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "\
    echo 0 > /var/volatile/crimson/state/time/lmx/freq;\
    echo 1 > /var/volatile/crimson/state/rx/a/rf/freq/common_lo; \
    echo 1 > /var/volatile/crimson/state/rx/b/rf/freq/common_lo; \
    echo 1 > /var/volatile/crimson/state/rx/c/rf/freq/common_lo; \
    echo 1 > /var/volatile/crimson/state/rx/d/rf/freq/common_lo; \
    exit\
    " 
echo "RX Test 1: Check no peak above 0dB. Press Enter when ready to continue."
read Next

ssh root@192.168.10.2 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "\
    echo 2725000000 > /var/volatile/crimson/state/time/lmx/freq;\
    echo 1 > /var/volatile/crimson/state/rx/a/rf/freq/common_lo; \
    echo 1 > /var/volatile/crimson/state/rx/b/rf/freq/common_lo; \
    echo 1 > /var/volatile/crimson/state/rx/c/rf/freq/common_lo; \
    echo 1 > /var/volatile/crimson/state/rx/d/rf/freq/common_lo; \
    exit\
    " 
echo "RX Test 2: Check strong peak at 2.7GHz on all channels. Press Enter when done."
read Next
