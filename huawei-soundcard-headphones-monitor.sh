#!/bin/bash
set -e  # exit immediately if any command fails

# Prevent multiple instances of the script from running simultaneously
pidof -o %PPID -x "$(basename "$0")" >/dev/null && exit 1

# Path to the HDA audio device used by the Conexant codec
HDA_DEV="/dev/snd/hwC0D0"

# Change the connection selector for the headphone jack
# Argument determines the routing target
move_output() {
    hda-verb "$HDA_DEV" 0x16 0x701 "$1" >/dev/null 2>&1
}

# Route audio output to the internal speakers
move_output_to_speaker() {
    move_output 0x0001
}

# Route audio output to the headphone jack
move_output_to_headphones() {
    move_output 0x0000
}

# Configure hardware when headphones are NOT connected
switch_to_speaker() {

    # Ensure audio is routed to speakers
    move_output_to_speaker

    # Enable internal speakers
    hda-verb "$HDA_DEV" 0x17 0x70C 0x0002 >/dev/null 2>&1

    # Disable headphone output
    hda-verb "$HDA_DEV" 0x1 0x715 0x2 >/dev/null 2>&1
}

# Configure hardware when headphones ARE connected
switch_to_headphones() {

    # Route audio to headphone DAC
    move_output_to_headphones

    # Disable internal speakers
    hda-verb "$HDA_DEV" 0x17 0x70C 0x0000 >/dev/null 2>&1

    # Configure headphone pin output mode
    hda-verb "$HDA_DEV" 0x1 0x717 0x2 >/dev/null 2>&1

    # Enable headphone pin
    hda-verb "$HDA_DEV" 0x1 0x716 0x2 >/dev/null 2>&1

    # Clear previous pin value
    hda-verb "$HDA_DEV" 0x1 0x715 0x0 >/dev/null 2>&1

    # Update PulseAudio sink to use headphones instead of speakers
    pacmd set-sink-port \
    alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__hw_sofhdadsp__sink \
    "[Out] Headphones"
}

# Detect the ALSA sound card index associated with the SOF HDA DSP driver
get_sound_card_index() {
    awk '/sof-hda-dsp/ {print $1; exit}' /proc/asound/cards
}

# Allow the audio subsystem to fully initialize before running detection
sleep 2

# Get the detected sound card index
card_index=$(get_sound_card_index)

# Exit if the expected audio device is not found
if [[ -z "$card_index" ]]; then
    echo "sof-hda-dsp card not found"
    exit 1
fi

# Track the previous headphone connection state
old_status=0

# Main monitoring loop
while true; do

    # Check headphone jack state using ALSA mixer
    # "off" means nothing is plugged into the jack
    if amixer "-c${card_index}" get Headphone | grep -q "off"; then
        status=1
        move_output_to_speaker
    else
        status=2
        move_output_to_headphones
    fi

    # Only reconfigure hardware if the state changed
    if [[ "$status" != "$old_status" ]]; then

        case "$status" in
            1)
                # Headphones disconnected
                switch_to_speaker
                ;;
            2)
                # Headphones connected
                switch_to_headphones
                ;;
        esac

        # Update stored state
        old_status=$status
    fi

    # Poll every second to reduce CPU wakeups
    sleep 1
done
