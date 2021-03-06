#!/bin/bash

# Install Figlet
install_if_not figlet

WANIP6=$(curl -s -k -m 7 https://6.ifcfg.me)
WANIP4=$(curl -s -m 5 ipinfo.io/ip)
ADDRESS=$(hostname -I | cut -d ' ' -f 1)

clear
figlet -f small Nextcloud
echo "     https://www.nextcloud.com"
echo
echo
echo "Hostname: $(hostname -s)"
echo "WAN IPv4: $WANIP4"
echo "WAN IPv6: $WANIP6"
echo "LAN IPv4: $ADDRESS"
echo
exit 0
