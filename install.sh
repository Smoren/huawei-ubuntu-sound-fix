#!/bin/bash

if command -v apt &>/dev/null; then
    echo "Using apt to install dependencies..."
    sudo apt update
    sudo apt install -y alsa-tools alsa-utils
else
    if command -v pacman &>/dev/null; then
        echo "Using pacman to install dependencies..."
        sudo pacman -Sy alsa-tools alsa-utils --noconfirm
    else
        echo "Neither apt nor pacman found. Cannot install dependencies."
        exit 1
    fi
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
