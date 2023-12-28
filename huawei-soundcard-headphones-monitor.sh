#!/bin/bash

# [COMMENTS]
#
# Looks like there is some weird hardware design, because from my prospective, the interesting widgets are:
# 0x01 - Audio Function Group
# 0x10 - Headphones DAC (really both devices connected here)
# 0x11 - Speaker DAC
# 0x16 - Headphones Jack
# 0x17 - Internal Speaker
#
# And:
#
# widgets 0x16 and 0x17 simply should be connected to different DACs 0x10 and 0x11, but Internal Speaker 0x17 ignores the connection select command and use the value from Headphones Jack 0x16.
# Headphone Jack 0x16 is controlled with some weird stuff so it should be enabled with GPIO commands for Audio Group 0x01.
# Internal Speaker 0x17 is coupled with Headphone Jack 0x16 so it should be explicitly disabled with EAPD/BTL Enable command.
#

function move_output() {
    sudo hda-verb /dev/snd/hwC0D0 0x16 0x701 "$@" > /dev/null 2> /dev/null
}

function move_output_to_speaker() {
    move_output 0x0001
}

function move_output_to_headphones() {
    move_output 0x0000
}

function switch_to_speaker() {
    move_output_to_speaker
    sudo hda-verb /dev/snd/hwC0D0 0x17 0x70C 0x0002 > /dev/null 2> /dev/null # enable speaker
    sudo hda-verb /dev/snd/hwC0D0 0x1 0x715 0x2 > /dev/null 2> /dev/null # disable headphones
}

function switch_to_headphones() {
    move_output_to_headphones
    sudo hda-verb /dev/snd/hwC0D0 0x17 0x70C 0x0000 > /dev/null 2> /dev/null # disable speaker
    sudo hda-verb /dev/snd/hwC0D0 0x1 0x717 0x2 > /dev/null 2> /dev/null # pin output mode
    sudo hda-verb /dev/snd/hwC0D0 0x1 0x716 0x2 > /dev/null 2> /dev/null # pin enable
    sudo hda-verb /dev/snd/hwC0D0 0x1 0x715 0x0 > /dev/null 2> /dev/null # clear pin value
}

old_status=0

while true; do
    if amixer -c 0 get Headphone | grep -q "off"; then
        status=1
        message="Headphones disconnected"
        move_output_to_speaker
    else
        status=2
        message="Headphones connected"
        move_output_to_headphones
    fi

    if [ ${status} -ne ${old_status} ]; then
        case "${status}" in
            1)
                switch_to_headphones
                sleep .1
                switch_to_speaker
                ;;
            2)
                switch_to_speaker
                sleep .1
                switch_to_headphones
                ;;
        esac
        echo "${message}"
        old_status=$status
    fi

    sleep .3
done
