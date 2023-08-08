# Huawei Matebook 14s sound card fix for Ubuntu

## Problem

The headphone and speaker channels are mixed up in the sound card driver for Linux distributions.

When headphones are connected, the system considers that sound should be output from the speakers. When the headphones are off, the system tries to output sound through them.

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

This fix definitely works under Ubuntu 22.04 for laptop model Huawei Matebook 14s.

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
