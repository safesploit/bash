#!/bin/bash
#Configures the interface to prior state before monitor_mode.sh
#
if [ `whoami` != 'root' ]
  then
    echo "MUST be ROOT!"
    exit
fi
#
ifconfig -a | sed 's/[ \t].*//;/^\(lo:\|\)$/d'
read -p "Enter interface: " int
macchanger $int
read -p "Enter permanent MAC address: " mac
ifconfig $int down
iwconfig $int mode manage
macchanger $int $mac
ifconfig $int up
#
echo "Interface in stock configuration"
echo "Connect to a Wi-Fi network and run 'ping 1.1.1.1'
