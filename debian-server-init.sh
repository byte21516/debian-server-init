#!/bin/bash

echo 'Make sure to execute this script as root!'

sleep 3

apt install unattended-upgrades -y
apt install ufw -y

systemctl enable unattended-upgrades

echo -e 'Recommended: Do you want to perform a system reboot? (Y/n) \n'
read -r action

if [ "$action" = y ] || [ "$action" = Y ]; then
    reboot
else
    echo "Script execution completed."
fi