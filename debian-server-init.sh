#!/bin/bash

echo 'Make sure to execute this script as root!'

sleep 3

apt install unattended-upgrades -y
apt install ufw -y
apt install sudo -y
apt install curl -y

ufw enable

systemctl enable unattended-upgrades

#-------------------------------------------------------------------------------

# Network here

apt install ipcalc -y

INTERFACES=$(ip -o link show | awk -F': ' '{print $2}' | grep -v lo)

echo "Available interfaces:"
echo "$INTERFACES"


read -p "Choose an interface to configure: " INTERFACE

read -p "Enter static IPv4: " STATIC_IP
read -p "Enter subnetmask: " NETMASK
read -p "Enter gateway: " GATEWAY
read -p "Enter DNS: " DNS

CIDR=$(ipcalc -p $STATIC_IP $NETMASK | awk -F'=' '{print $2}')


if [ -d /etc/netplan ]; then
    CONFIG_FILE="/etc/netplan/01-netcfg.yaml"

    sudo cp $CONFIG_FILE $CONFIG_FILE.bak

    sudo bash -c "cat > $CONFIG_FILE" <<EOL
network:
  version: 2
  renderer: networkd
  ethernets:
    $INTERFACE:
      dhcp4: no
      addresses:
        - $STATIC_IP/$CIDR
      gateway4: $GATEWAY
      nameservers:
          addresses:
          - $DNS
EOL

    sudo netplan apply
    echo "Static IPv4 $STATIC_IP has been configured for $INTERFACE"

elif [ -f /etc/network/interfaces ]; then
    CONFIG_FILE="/etc/network/interfaces"


    sudo cp $CONFIG_FILE $CONFIG_FILE.bak


    sudo bash -c "cat > $CONFIG_FILE" <<EOL
auto $INTERFACE
iface $INTERFACE inet static
    address $STATIC_IP
    netmask $NETMASK
    gateway $GATEWAY
    dns-nameservers $DNS
EOL

    sudo ifdown $INTERFACE && sudo ifup $INTERFACE
    echo "Static IPv4 $STATIC_IP has been configured for $INTERFACE"

else
    echo "ERROR: NEEDED FILES NOT FOUND."
    exit 1
fi

# THIS OUTPUTS:

# ifdown: interface INTERFACE not configures
# RTNETLINK answers: File exists
# ifup: failed to bring ip INTERFACE

# After that starting of the networking system service fails :/

#-------------------------------------------------------------------------------

# Other configs...













#-------------------------------------------------------------------------------

echo -e 'Recommended: Do you want to perform a system reboot? (Y/n) \n'
read -r action

if [ "$action" = y ] || [ "$action" = Y ]; then
    reboot
else
    echo "Script execution completed."
fi

