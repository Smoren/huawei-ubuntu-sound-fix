#!/bin/bash
set -e

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

# ensures script can run only once at a time
pidof -o %PPID -x $0 >/dev/null && echo "Script $0 already running" && exit 1

function move_output() {
   hda-verb /dev/snd/hwC0D0 0x16 0x701 "$@" > /dev/null 2> /dev/null
}

function move_output_to_speaker() {
    move_output 0x0001
}

function move_output_to_headphones() {
    move_output 0x0000
}

function switch_to_speaker() {
    move_output_to_speaker

    # enable speaker
    hda-verb /dev/snd/hwC0D0 0x17 0x70C 0x0002 > /dev/null 2> /dev/null

    # disable headphones
    hda-verb /dev/snd/hwC0D0 0x1 0x715 0x2 > /dev/null 2> /dev/null
}

function switch_to_headphones() {
    move_output_to_headphones

    # disable speaker
    hda-verb /dev/snd/hwC0D0 0x17 0x70C 0x0000 > /dev/null 2> /dev/null

    # pin output mode
    hda-verb /dev/snd/hwC0D0 0x1 0x717 0x2 > /dev/null 2> /dev/null

    # pin enable
    hda-verb /dev/snd/hwC0D0 0x1 0x716 0x2 > /dev/null 2> /dev/null

    # clear pin value
    hda-verb /dev/snd/hwC0D0 0x1 0x715 0x0 > /dev/null 2> /dev/null

    # sets amixer sink port to headphones instead of the speaker
    pacmd set-sink-port alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__hw_sofhdadsp__sink "[Out] Headphones"
}

function get_sound_card_index() {
    card_index=$(cat /proc/asound/cards | grep sof-hda-dsp | head -n1 | grep -Eo "^\s*[0-9]+")
    # remove leading white spaces
    card_index="${card_index#"${card_index%%[![:space:]]*}"}"
    echo $card_index
}

sleep 2 # allows audio system to initialise first

card_index=$(get_sound_card_index)
if [ $card_index == "" ]; then
    echo "sof-dha-dsp card is not found in /proc/asound/cards"
    return 1
fi

old_status=0

while true; do
    # if headphone jack isn't plugged:
    if amixer "-c${card_index}" get Headphone | grep -q "off"; then
        status=1
	    move_output_to_speaker
    # if headphone jack is plugged:
    else
        status=2
	    move_output_to_headphones
    fi

    if [ ${status} -ne ${old_status} ]; then
        case "${status}" in
            1)
                message="Headphones disconnected"
                switch_to_speaker
                ;;
            2)
                message="Headphones connected"
                switch_to_headphones
                ;;
        esac

        echo "${message}"
        old_status=$status
    fi

    sleep .3
done
