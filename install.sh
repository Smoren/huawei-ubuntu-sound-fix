#!/bin/bash

if command -v apt &>/dev/null; then
    echo "Using apt to install dependencies..."
    sudo apt update
    sudo apt install -y alsa-tools alsa-utils
elif 
    command -v pacman &>/dev/null; then
    echo "Using pacman to install dependencies..."
    sudo pacman -Sy alsa-tools alsa-utils --noconfirm
elif
    command -v eopkg &>/dev/null; then
    echo "Using eopkg to install dependencies..."
    sudo eopkg up
    sudo eopkg it alsa-tools alsa-utils -y
elif 
    command -v zypper &>/dev/null; then
    echo "Using zypper to install dependencies..."
    sudo zypper install -y alsa-tools alsa-utils hda-verb
elif 
    command -v dnf &>/dev/null; then
    echo "Using dnf to install dependencies..."
    sudo dnf install -y alsa-tools alsa-utils
else
    echo "Neither apt, pacman, eopkg, zypper, nor dnf found. Cannot install dependencies."
fi

echo "Copying files..."
sudo cp huawei-soundcard-headphones-monitor.sh /usr/local/bin/
sudo cp huawei-soundcard-headphones-monitor.service /etc/systemd/system/

echo "Setting rights..."
sudo chmod +x /usr/local/bin/huawei-soundcard-headphones-monitor.sh
sudo chmod +x /etc/systemd/system/huawei-soundcard-headphones-monitor.service

echo "Setting up daemon..."
sudo systemctl daemon-reload
sudo systemctl enable huawei-soundcard-headphones-monitor
sudo systemctl restart huawei-soundcard-headphones-monitor

echo "Complete!"
