au1: # To enable a speaker and disable headphones
        sudo hda-verb /dev/snd/hwC0D0 0x16 0x701 0x0001 # move output to speake>
        sudo hda-verb /dev/snd/hwC0D0 0x17 0x70C 0x0002 # enable speaker
        sudo hda-verb /dev/snd/hwC0D0 0x1 0x715 0x2 # disable headphones
au2: # To disable a speaker and enable headphones
        sudo hda-verb /dev/snd/hwC0D0 0x16 0x701 0x0000 # move output to headph>
        sudo hda-verb /dev/snd/hwC0D0 0x17 0x70C 0x0000 # disable speaker
        sudo hda-verb /dev/snd/hwC0D0 0x1 0x717 0x2 # pin output mode
        sudo hda-verb /dev/snd/hwC0D0 0x1 0x716 0x2 # pin enable
        sudo hda-verb /dev/snd/hwC0D0 0x1 0x715 0x0 # clear pin value

# Looks like there is some weird hardware design, because from my prospective, the interesting widgets are:
# 0x01 - Audio Function Group
# 0x10 - Headphones DAC (really both devices connected here)
# 0x11 - Speaker DAC
# 0x16 - Headphones Jack
# 0x17 - Internal Speaker

# And:

# widgets 0x16 and 0x17 simply should be connected to different DACs 0x10 and 0x11, but Internal Speaker 0x17 ignores the connection select command and use the value from Headphones Jack 0x16.
# Headphone Jack 0x16 is controlled with some weird stuff so it should be enabled with GPIO commands for Audio Group 0x01.
# Internal Speaker 0x17 is coupled with Headphone Jack 0x16 so it should be explicitly disabled with EAPD/BTL Enable command.
