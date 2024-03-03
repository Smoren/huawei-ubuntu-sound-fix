# Huawei Matebook 14s / 16s soundcard fix for Ubuntu / Fedora / Arch

## Problem

The headphone and speaker channels are mixed up in the sound card driver for Linux distributions.

When headphones are connected, the system considers that sound should be output from the speakers. When the headphones are off, the system tries to output sound through them.

### Problem details (found [here](https://github.com/thesofproject/linux/issues/3350#issuecomment-1301070327))

Looks like there is some weird hardware design, because from my prospective, the interesting widgets are:
* 0x01 - Audio Function Group
* 0x10 - Headphones DAC (really both devices connected here)
* 0x11 - Speaker DAC
* 0x16 - Headphones Jack
* 0x17 - Internal Speaker

And:

* widgets 0x16 and 0x17 simply should be connected to different DACs 0x10 and 0x11, but Internal Speaker 0x17 ignores the connection select command and use the value from Headphones Jack 0x16.
* Headphone Jack 0x16 is controlled with some weird stuff so it should be enabled with GPIO commands for Audio Group 0x01.
* Internal Speaker 0x17 is coupled with Headphone Jack 0x16 so it should be explicitly disabled with EAPD/BTL Enable command.

## Solution

A daemon has been implemented that monitors the connection/disconnection of headphones and accesses the sound card device in order to switch playback to the right place.

## Install

```bash
bash install.sh
```

## Daemon control commands
```bash
systemctl status huawei-soundcard-headphones-monitor
systemctl restart huawei-soundcard-headphones-monitor
systemctl start huawei-soundcard-headphones-monitor
systemctl stop huawei-soundcard-headphones-monitor
```

## Environment

This fix definitely works under Ubuntu 22.04 and Fedora 39 for laptop model Huawei MateBook 14s.

```bash
$ inxi -F
System:
  Host: smorenbook Kernel: 5.15.0-78-generic x86_64 bits: 64
    Desktop: GNOME 42.9 Distro: Ubuntu 22.04.3 LTS (Jammy Jellyfish)
Machine:
  Type: Laptop System: HUAWEI product: HKF-WXX v: M1010
    serial: <superuser required>
  Mobo: HUAWEI model: HKF-WXX-PCB v: M1010 serial: <superuser required>
    UEFI: HUAWEI v: 1.06 date: 07/22/2022
```

## Say thanks

If you want to thank me for this solution, you can subscribe to my [Github profile](https://github.com/Smoren) and also give stars to [my open source projects](https://github.com/Smoren?tab=repositories&q=&type=public&language=&sort=stargazers), e.g.:
* [IterTools TS](https://github.com/Smoren/itertools-ts) — Extended itertools port for TypeScript and JavaScript. Provides a huge set of functions for working with iterable collections (including async ones).
* [Schemator PHP](https://github.com/Smoren/schemator-php) — Schematic data mapper for converting nested data structures (any composition of associative arrays, non-associative arrays and objects) according to the given conversion schema.
* [Encryption Tools for python](https://github.com/Smoren/encryptiontools-pypi) — Tools for encryption and decryption, signing and verification. Use symmetric and asymmetric (RSA-based) encryption.
* [Yii2 Query Relation Manager](https://github.com/Smoren/yii2-query-relation-manager) — Implements the functionality of getting tree data from a database with one-to-one and one-to-many relationships using only one select-query to the database with flexible conditions configuration.
* [Probability Selector PHP](https://github.com/Smoren/probability-selector-php) — Selection manager for choosing next elements to use from data source based on uniform distribution of selections.
* [Event Router PHP](https://github.com/Smoren/event-router-php) — Router for flexible configuring of event handling behaviors.
