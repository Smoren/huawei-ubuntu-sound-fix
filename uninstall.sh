echo "Stopping daemon..."
sudo systemctl stop huawei-soundcard-headphones-monitor.service

echo "Removing program..."
sudo rm /usr/local/bin/huawei-soundcard-headphones-monitor.sh

echo "Removing service..."
sudo rm /etc/systemd/system/huawei-soundcard-headphones-monitor.service

echo "Uninstalled. Goodbye 😿"
